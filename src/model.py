#!/usr/bin/env python3
"""
Analytical Bambu cycle predictor for SA-shaped Eyeriss-CONV kernels.

Usage:
    python src/model.py --ff <path/to/FF_output.txt> [--n-mul 1 2 4 8 16] [--measured N_mul:cycles ...]

The model estimates Bambu cycle counts given a FactorFlow mapping and the
number of float multiplier units (-C=__float_mul=N in Bambu).

Model variables (all derived from the FF mapping):
  U       = unroll depth = product of all FanoutLevel (SACols + SARows) factors
  T_seq   = product of inner MemLevel (WRegister) factors  [innermost sequential loop]
  T_outer = product of outer MemLevel (DRAM x GlobalBuffer) factors [outer tile loops]
  total_MACs = M*P*Q*C*R*S   (sanity: U * T_seq * T_outer == total_MACs)

  reads_per_weight_bank = (C/in_banks) * S_sa * m_sf   [per r-iteration]
  reads_per_input_bank  = (C/in_banks) * S_sa * q_sf   [per r-iteration]
  max_reads_per_port    = max(reads_per_weight_bank, reads_per_input_bank)

Compute-bound II per r-iter: ceil(U / N_mul)
Memory-bound  II per r-iter: max_reads_per_port   (assuming BW=1 word/cycle/port)

Crossover N_mul*: U / max_reads_per_port  (below: compute-bound; above: memory-bound)

Total predicted cycles:
  T_predicted = alpha * T_outer * T_seq * max(ceil(U/N_mul), II_memory)

alpha is calibrated from a known (N_mul, measured_cycles) data point if provided,
otherwise defaults to 1 (gives theoretical lower bound).
"""
from __future__ import annotations

import argparse
import json
import math
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Insert src/ on the path so ff_parser / mapping_types are importable when
# running as "python src/model.py" from repo root.
# ---------------------------------------------------------------------------
_src = Path(__file__).resolve().parent
if str(_src) not in sys.path:
    sys.path.insert(0, str(_src))

from ff_parser import parse_ff_output
from mapping_types import MappingInfo
from model_profiles import get_profile

# ---------------------------------------------------------------------------
# Calibration store
# ---------------------------------------------------------------------------

_CALIBRATION_FILE = Path(__file__).resolve().parent / "bambu_calibration.json"
_CALIBRATION_TMP  = Path(__file__).resolve().parent / ".calibration_tmp"

# Canonical reference workload per arch_workload (M P Q C R S for FactorFlow).
# eyeriss-conv canonical = ex2 workload (gives good serial/parallel separation).
_PROFILE_REGISTRY: Dict[str, Dict] = {
    "eyeriss-conv": {
        "ff_args": ["4", "4", "4", "4", "3", "3"],  # M P Q C R S
    },
    "eyeriss": {
        "ff_args": ["4", "4", "4"],  # M K N
    },
}

# Must mirror the dispatch table in src/main.py _dispatch_and_generate().
# Add an arch here ONLY after implementing its generator — checked BEFORE any I/O
# in _auto_calibrate so failures are instant with a clear message.
_GENERATOR_SUPPORTED: frozenset = frozenset({"eyeriss-conv", "eyeriss"})


def _calibration_key(arch_workload: str, compiler: str, clock_period: int) -> str:
    return f"{arch_workload}__{compiler}__{clock_period}"


def _load_calibration(arch_workload: str,
                      compiler: str = "I386_GCC8",
                      clock_period: int = 5) -> Optional[Dict[str, float]]:
    """Return {alpha_s, alpha_p} for (arch_workload, compiler, clock_period), or None."""
    if not _CALIBRATION_FILE.exists():
        return None
    data = json.loads(_CALIBRATION_FILE.read_text())
    return data.get(_calibration_key(arch_workload, compiler, clock_period))


def _save_calibration(arch_workload: str, compiler: str, clock_period: int,
                      alpha_s: float, alpha_p: float, source: str,
                      measured_cycles: Optional[Dict[int, int]] = None) -> None:
    """Write (alpha_s, alpha_p) to the calibration store."""
    data: Dict = {}
    if _CALIBRATION_FILE.exists():
        data = json.loads(_CALIBRATION_FILE.read_text())
    key = _calibration_key(arch_workload, compiler, clock_period)
    entry: Dict = {"alpha_s": round(alpha_s, 4), "alpha_p": round(alpha_p, 4),
                   "source": source}
    if measured_cycles:
        entry["measured_cycles"] = {str(k): v for k, v in sorted(measured_cycles.items())}
    data[key] = entry
    _CALIBRATION_FILE.write_text(json.dumps(data, indent=2) + "\n")


def _parse_cycles_from_log(text: str) -> Optional[int]:
    """Extract cycle count from 'Run 1 execution time N cycles;' line."""
    m = re.search(r"Run 1 execution time\s+(\d+)\s+cycles", text)
    return int(m.group(1)) if m else None


def _run_bambu_calibration(tmp: Path, compiler: str, clock_period: int,
                            n_mul: int) -> int:
    """Run Bambu for top_level_sa.c with given N_mul; return cycle count."""
    out_dir = tmp / f"bambu_n{n_mul}"
    out_dir.mkdir(exist_ok=True)

    # Parse --tb-param-size flags from the generated compile_bambu.sh
    compile_sh = tmp / "compile_bambu.sh"
    tb_flags = re.findall(r"--tb-param-size=\S+", compile_sh.read_text())

    cmd = [
        "bambu", "../../top_level_sa.c",
        "--top-fname=top_level",
        "--generate-interface=INFER",
        f"--compiler={compiler}",
        f"--clock-period={clock_period}",
        "-O3", "-v4",
        "--generate-tb=../../testbench_common.c",
    ] + tb_flags + [f"-C=__float_mul={n_mul}", "--simulate"]

    log_path = out_dir / f"bambu_n{n_mul}.log"
    result = subprocess.run(cmd, cwd=str(out_dir),
                            capture_output=True, text=True)
    combined = result.stdout + result.stderr
    log_path.write_text(combined)

    cycles = _parse_cycles_from_log(combined)
    if cycles is None:
        raise RuntimeError(
            f"Auto-calibration: could not parse cycle count from Bambu "
            f"N_mul={n_mul} run. Log: {log_path}"
        )
    return cycles


_N_MUL_SWEEP = [1, 2, 4, 8, 16]   # N_mul values run during auto-calibration


def _auto_calibrate(arch_workload: str, compiler: str,
                    clock_period: int) -> Dict[str, float]:
    """
    Run a canonical reference Bambu experiment to derive alpha_s and alpha_p.
    Artifacts land in src/.calibration_tmp/ (gitignored), cleaned on success.
    """
    # Step 0a — model registry: do we have canonical ff_args for this arch?
    if arch_workload not in _PROFILE_REGISTRY:
        raise ValueError(
            f"arch_workload {arch_workload!r} not in _PROFILE_REGISTRY. "
            f"Available: {list(_PROFILE_REGISTRY)}. "
            f"Add an entry with 'ff_args' to enable auto-calibration."
        )

    # Step 0b — generator support: can we actually produce C code for this arch?
    # This check is BEFORE any I/O so failure is instant and leaves no tmp dir.
    if arch_workload not in _GENERATOR_SUPPORTED:
        raise ValueError(
            f"arch_workload {arch_workload!r} is not supported by the C code generator "
            f"(not in _GENERATOR_SUPPORTED). "
            f"Implement the generator in src/main.py _dispatch_and_generate(), "
            f"then add {arch_workload!r} to _GENERATOR_SUPPORTED."
        )

    profile = _PROFILE_REGISTRY[arch_workload]
    tmp = _CALIBRATION_TMP
    tmp.mkdir(parents=True, exist_ok=True)

    print(f"[calibration] No entry for {arch_workload!r} / {compiler} / "
          f"clock={clock_period}ns in calibration store.")
    print(f"[calibration] Running canonical reference experiment "
          f"({arch_workload} {' '.join(profile['ff_args'])}) ...")

    try:
        # 1. Synthetic config.json for the canonical reference workload
        config = {
            "factorflow": {
                "main_cli": "./FactorFlow/main_cli.py",
                "architecture": arch_workload,
                "args": profile["ff_args"],
                "force": True,
            },
            "bambu": {
                "clock_period": clock_period,
                "compiler": compiler,
                "opt_level": 3,
                "v": 4,
                "extra_args": [],
            },
        }
        (tmp / "config.json").write_text(json.dumps(config, indent=2))

        # 2. Generate C files via main.py (runs FF + eyeriss_generator)
        repo_root = Path(__file__).resolve().parents[1]
        main_py   = Path(__file__).resolve().parent / "main.py"
        print("[calibration] Generating C files ...")
        subprocess.check_call(
            [sys.executable, str(main_py), "--config", str(tmp / "config.json")],
            cwd=str(repo_root),
        )

        # 3. Build BambuCycleModel from the canonical FF output
        ff_txt = tmp / "FF_output" / "FF_output.txt"
        cal_mapping = parse_ff_output(str(ff_txt))
        cal_model   = BambuCycleModel(cal_mapping)

        # 4. Sweep N_mul values (serial + parallel plateau)
        measured_cycles: Dict[int, int] = {}
        for n_mul in _N_MUL_SWEEP:
            print(f"[calibration] Running Bambu N_mul={n_mul} ...")
            try:
                c = _run_bambu_calibration(tmp, compiler, clock_period, n_mul)
                measured_cycles[n_mul] = c
                print(f"[calibration]   N_mul={n_mul} → {c:,} cycles")
            except RuntimeError as e:
                print(f"[calibration]   N_mul={n_mul} FAILED ({e}), stopping sweep.")
                break

        if 1 not in measured_cycles:
            raise RuntimeError("Auto-calibration: N_mul=1 run failed — cannot calibrate.")

        # 5. Derive alphas
        alpha_s = cal_model.calibrate_alpha_s(measured_cycles[1])
        parallel_pts = {n: c for n, c in measured_cycles.items()
                        if n >= cal_model.n_threshold}
        n_p = min(parallel_pts) if parallel_pts else None
        alpha_p = (cal_model.calibrate_alpha_p(n_p, parallel_pts[n_p]) if n_p
                   else alpha_s * (cal_model.heaviest_port_reads
                                   / cal_model.total_reads_all_ports))
        print(f"[calibration] alpha_s={alpha_s:.4f}  alpha_p={alpha_p:.4f}")

        # 6. Persist with full sweep data
        source = ("auto-calibrated " + arch_workload +
                  " " + " ".join(f"N_mul={n}:{c}"
                                 for n, c in sorted(measured_cycles.items())))
        _save_calibration(arch_workload, compiler, clock_period,
                          alpha_s, alpha_p, source,
                          measured_cycles=measured_cycles)
        print(f"[calibration] Saved to {_CALIBRATION_FILE}")

        # 7. Clean up (keep tmp on failure for debugging)
        shutil.rmtree(tmp, ignore_errors=True)

        return {"alpha_s": alpha_s, "alpha_p": alpha_p,
                "measured_cycles": measured_cycles}

    except Exception:
        print(f"[calibration] FAILED — artifacts kept in {tmp} for debugging.")
        raise


# ---------------------------------------------------------------------------
# Core model
# ---------------------------------------------------------------------------

class BambuCycleModel:
    """
    Analytical cycle model for a Bambu-synthesized SA-shaped conv kernel.

    All quantities derived from the FF mapping and the number of float
    multiplier units (N_mul).
    """

    def __init__(self, mapping: MappingInfo):
        self.mapping = mapping
        self._parse()

    # ------------------------------------------------------------------
    def _parse(self):
        d = self.mapping.dims
        self.M = int(d["M"])
        # CONV dims — default to 1 for workloads that don't have them (e.g. GEMM)
        self.P = int(d.get("P", 1)); self.Q = int(d.get("Q", 1))
        self.C = int(d.get("C", 1)); self.R = int(d.get("R", 1)); self.S = int(d.get("S", 1))
        # total_MACs is the product of all dims regardless of workload
        self.total_MACs = 1
        for v in d.values():
            self.total_MACs *= int(v)

        tiling = self.mapping.tiling

        # SACols: output spatial dims (M, P, Q for CONV; M, K for GEMM)
        sacols = tiling.get("SACols", {}) or {}
        self.m_sf = int(sacols.get("M", 1))
        self.p_sf = int(sacols.get("P", 1))
        self.q_sf = int(sacols.get("Q", 1))

        # SARows: reduction dims (C, S for CONV; M for GEMM)
        sarows = tiling.get("SARows", {}) or {}
        self.C_sa = int(sarows.get("C", 1))
        self.S_sa = int(sarows.get("S", 1))

        # Unroll depth U = product of ALL FanoutLevel (SA) factors, workload-agnostic
        self.U = 1
        for lvl, til in tiling.items():
            if "SA" in lvl:
                for fac in til.values():
                    self.U *= int(fac)

        # Inner sequential loops (WRegister, InRegister)
        self.T_seq = 1
        for lvl, til in tiling.items():
            if "Register" in lvl and "Out" not in lvl and "SA" not in lvl:
                for fac in til.values():
                    self.T_seq *= int(fac)

        # Outer temporal tile loops (DRAM, GlobalBuffer)
        self.T_outer = 1
        for lvl, til in tiling.items():
            if "SA" not in lvl and "Register" not in lvl:
                for fac in til.values():
                    self.T_outer *= int(fac)

        # --- Delegate AXI read formulas to ArchProfile ---
        profile = get_profile(self.mapping.arch_workload)
        port_r  = profile.port_reads(self.mapping, self.T_seq, self.T_outer)
        self._port_reads           = port_r
        self.total_reads_all_ports = sum(port_r.values())
        self.heaviest_port_reads   = max(port_r.values())
        self.n_chains              = profile.n_chains(self.mapping)
        self.n_threshold           = 2  # min N_mul for parallel scheduling

        # Per-iteration reads (for crossover threshold + summary display)
        n = self.T_seq * self.T_outer
        self.reads_w_b  = port_r.get("dram_w_b0", 0)   # representative weight bank
        self.reads_in_b = port_r.get("dram_in_b0", 0)   # representative input bank
        self.reads_per_weight_bank = self.reads_w_b  // n if n else 0
        self.reads_per_input_bank  = self.reads_in_b // n if n else 0
        self.max_reads_per_port    = max(self.reads_per_weight_bank,
                                         self.reads_per_input_bank)

        # Crossover N_mul (compute-bound vs memory-bound threshold)
        self.N_mul_crossover = (self.U / self.max_reads_per_port
                                if self.max_reads_per_port > 0 else float("inf"))

    # ------------------------------------------------------------------
    # Two-regime methods
    # ------------------------------------------------------------------
    def regime(self, N_mul: int) -> str:
        """Return 'serial' for N_mul < n_threshold, else 'parallel'."""
        return "serial" if N_mul < self.n_threshold else "parallel"

    def cycles_serial(self) -> int:
        """Theoretical baseline for serial regime (alpha=1): sum of all port reads."""
        return self.total_reads_all_ports

    def cycles_parallel(self, N_mul: int) -> int:
        """Theoretical baseline for parallel regime (alpha=1): heaviest AXI port reads.
        Always memory-bound because Bambu pipelines across R iterations."""
        return self.heaviest_port_reads

    # ------------------------------------------------------------------
    def theoretical_cycles(self, N_mul: int) -> int:
        """Theoretical lower bound (alpha=1). Kept for backward compatibility."""
        II_compute = math.ceil(self.U / N_mul)
        II_memory  = self.max_reads_per_port  # BW = 1 word/cycle/port
        II = max(II_compute, II_memory)
        return self.T_outer * self.T_seq * II

    def predict(self, N_mul: int, alpha_s: float = 1.0, alpha_p: float = 1.0) -> int:
        """Regime-aware prediction using two-alpha model."""
        if N_mul < self.n_threshold:
            return int(round(alpha_s * self.cycles_serial()))
        else:
            return int(round(alpha_p * self.cycles_parallel(N_mul)))

    def regime_label(self, N_mul: int) -> str:
        return self.regime(N_mul)

    def calibrate_alpha_s(self, measured_cycles: int) -> float:
        """Fit alpha_s from a N_mul=1 measurement."""
        base = self.cycles_serial()
        return measured_cycles / base if base else 1.0

    def calibrate_alpha_p(self, N_mul: int, measured_cycles: int) -> float:
        """Fit alpha_p from any N_mul >= n_threshold measurement."""
        base = self.cycles_parallel(N_mul)
        return measured_cycles / base if base else 1.0

    # ------------------------------------------------------------------
    # Backward-compatible wrappers
    # ------------------------------------------------------------------
    def bound_label(self, N_mul: int) -> str:
        return self.regime_label(N_mul)

    def calibrate_alpha(self, N_mul: int, measured_cycles: int) -> float:
        """Legacy single-alpha calibration (kept for backward compatibility)."""
        th = self.theoretical_cycles(N_mul)
        return measured_cycles / th if th else 1.0

    # ------------------------------------------------------------------
    def summary(self) -> str:
        lines = []
        m = self.mapping
        dims_str = "  ".join(f"{k}={v}" for k, v in m.dims.items())
        lines.append(f"Mapping : {m.arch_workload}  {dims_str}")
        sa_str = "  ".join(
            f"{lvl}={dict(til)}"
            for lvl, til in m.tiling.items() if "SA" in lvl and til
        ) or "(none)"
        lines.append(f"SA tiling: {sa_str}")
        lines.append(f"Unroll depth U = {self.U}  "
                     f"(T_seq={self.T_seq}, T_outer={self.T_outer})")
        lines.append(f"total_MACs = {self.total_MACs}  "
                     f"(sanity U*T_seq*T_outer = {self.U*self.T_seq*self.T_outer})")
        lines.append(f"AXI ports (total reads) : "
                     f"w_b0={self.reads_w_b}  w_b1={self.reads_w_b}  "
                     f"in_b0={self.reads_in_b}  in_b1={self.reads_in_b}")
        lines.append(f"total_reads_all_ports = {self.total_reads_all_ports}  "
                     f"heaviest_port = {self.heaviest_port_reads}  "
                     f"n_chains = {self.n_chains}")
        lines.append(f"Regime threshold      : n_threshold={self.n_threshold}  "
                     f"(serial if N_mul<{self.n_threshold}, parallel otherwise)")
        return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _parse_measured(args) -> Dict[int, int]:
    """Parse --measured N_mul:cycles pairs."""
    out: Dict[int, int] = {}
    for token in (args.measured or []):
        try:
            k, v = token.split(":")
            out[int(k)] = int(v)
        except Exception:
            print(f"[warn] Could not parse --measured {token!r}, expected N_mul:cycles")
    return out


def main():
    ap = argparse.ArgumentParser(
        description="Predict Bambu cycle counts for SA-shaped conv kernels.")
    ap.add_argument("--ff", required=True,
                    help="Path to FF_output.txt")
    ap.add_argument("--n-mul", type=int, nargs="+", default=[1, 2, 4, 8, 16],
                    help="Float multiplier counts to evaluate (powers of 2, default: 1 2 4 8 16)")
    ap.add_argument("--measured", nargs="*", metavar="N_MUL:CYCLES",
                    help="Measured cycles for calibration, e.g. --measured 1:23660 2:4148")
    ap.add_argument("--compiler", default="I386_GCC8",
                    help="Bambu compiler flag (default: I386_GCC8)")
    ap.add_argument("--clock", type=int, default=5,
                    help="Bambu clock period in ns (default: 5)")
    args = ap.parse_args()

    mapping = parse_ff_output(args.ff)
    model = BambuCycleModel(mapping)
    measured = _parse_measured(args)

    # --- Alpha resolution (priority: --measured > calibration store > auto-calibrate > heuristic) ---
    alpha_s = 1.0
    alpha_p = 1.0
    serial_src = None
    parallel_src = None
    calibration_src = None

    serial_pts   = {n: v for n, v in measured.items() if n < model.n_threshold}
    parallel_pts = {n: v for n, v in measured.items() if n >= model.n_threshold}

    if serial_pts:
        serial_src = min(serial_pts)
        alpha_s = model.calibrate_alpha_s(serial_pts[serial_src])
    if parallel_pts:
        parallel_src = min(parallel_pts)
        alpha_p = model.calibrate_alpha_p(parallel_src, parallel_pts[parallel_src])

    # If --measured didn't supply both, try the calibration store
    arch_wl = mapping.arch_workload
    cal = _load_calibration(arch_wl, args.compiler, args.clock)

    # If not in store and arch is supported → auto-calibrate
    if cal is None and not measured:
        if arch_wl in _PROFILE_REGISTRY:
            cal = _auto_calibrate(arch_wl, args.compiler, args.clock)
        elif arch_wl:
            print(f"[warn] arch_workload {arch_wl!r} not in PROFILE_REGISTRY; "
                  f"cannot auto-calibrate. Using alpha=1 (theoretical lower bound).")

    if cal:
        if serial_src is None:
            alpha_s = cal["alpha_s"]
            calibration_src = _calibration_key(arch_wl, args.compiler, args.clock)
        if parallel_src is None:
            alpha_p = cal["alpha_p"]
            calibration_src = _calibration_key(arch_wl, args.compiler, args.clock)
        # Surface stored sweep measurements in the table (don't overwrite --measured entries)
        for k, v in cal.get("measured_cycles", {}).items():
            n = int(k)
            if n not in measured:
                measured[n] = v

    # Last resort heuristic (only if calibration store also missing)
    if serial_src is None and cal is None:
        if parallel_src is not None:
            alpha_s = alpha_p * (model.total_reads_all_ports / model.heaviest_port_reads)
        # else both stay at 1.0 (theoretical lower bound)
    if parallel_src is None and cal is None:
        if serial_src is not None:
            alpha_p = alpha_s * (model.heaviest_port_reads / model.total_reads_all_ports)

    print()
    print(model.summary())
    print()

    def _alpha_src(from_measured_src, regime_label):
        if from_measured_src is not None:
            return f"calibrated from --measured N_mul={from_measured_src}"
        if calibration_src:
            return f"loaded from calibration store ({calibration_src})"
        return "heuristic estimate (no calibration data)"

    if serial_src is not None:
        print(f"alpha_s = {alpha_s:.4f}  (calibrated from N_mul={serial_src},"
              f" serial: {model.cycles_serial()} base reads)")
    else:
        print(f"alpha_s = {alpha_s:.4f}  ({_alpha_src(serial_src, 'serial')})")

    if parallel_src is not None:
        print(f"alpha_p = {alpha_p:.4f}  (calibrated from N_mul={parallel_src},"
              f" parallel: {model.heaviest_port_reads} base reads)")
    else:
        print(f"alpha_p = {alpha_p:.4f}  ({_alpha_src(parallel_src, 'parallel')})")

    print()
    n_muls = sorted(set(args.n_mul) | set(measured.keys()))
    header = f"{'N_mul':>6}  {'Regime':>8}  {'Theory':>8}  {'Predicted':>10}  {'Measured':>10}  {'Error':>7}  {'Speedup':>8}"
    print(header)
    print("-" * len(header))

    base_pred = None
    for n in n_muls:
        pred    = model.predict(n, alpha_s, alpha_p)
        theory  = model.cycles_serial() if n < model.n_threshold else model.cycles_parallel(n)
        regime  = model.regime(n)
        if base_pred is None:
            base_pred = pred
        speedup = base_pred / pred if pred > 0 else float("inf")

        meas_str  = f"{measured[n]:>10,}" if n in measured else f"{'—':>10}"
        error_str = ""
        if n in measured and pred > 0:
            err = (pred - measured[n]) / measured[n] * 100
            error_str = f"{err:>+6.1f}%"
        else:
            error_str = f"{'—':>7}"

        print(f"{n:>6}  {regime:>8}  {theory:>8,}  {pred:>10,}  {meas_str}  {error_str}  {speedup:>7.2f}x")

    print()
    print("Note: N_mul must be a power of 2 for Bambu (-C=__float_mul=N).")
    print("      Parallel regime: AXI port bandwidth limits throughput regardless of N_mul.")


if __name__ == "__main__":
    main()
