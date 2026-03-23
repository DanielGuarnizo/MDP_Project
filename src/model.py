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
import math
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


# ---------------------------------------------------------------------------
# Core model
# ---------------------------------------------------------------------------

class BambuCycleModel:
    """
    Analytical cycle model for a Bambu-synthesized SA-shaped conv kernel.

    All quantities derived from the FF mapping and the number of float
    multiplier units (N_mul).
    """

    def __init__(self, mapping: MappingInfo, in_banks: int = 2):
        self.mapping = mapping
        self.in_banks = in_banks
        self._parse()

    # ------------------------------------------------------------------
    def _parse(self):
        d = self.mapping.dims
        self.M = int(d["M"]); self.P = int(d["P"]); self.Q = int(d["Q"])
        self.C = int(d.get("C", 1))
        self.R = int(d.get("R", 1))
        self.S = int(d.get("S", 1))
        self.total_MACs = self.M * self.P * self.Q * self.C * self.R * self.S

        tiling = self.mapping.tiling

        # SACols: output spatial dims (M, P, Q)
        sacols = tiling.get("SACols", {}) or {}
        self.m_sf = int(sacols.get("M", 1))
        self.p_sf = int(sacols.get("P", 1))
        self.q_sf = int(sacols.get("Q", 1))

        # SARows: reduction dims (C, S)
        sarows = tiling.get("SARows", {}) or {}
        self.C_sa = int(sarows.get("C", 1))
        self.S_sa = int(sarows.get("S", 1))

        # Unroll depth U = product of all FanoutLevel factors
        self.U = self.m_sf * self.p_sf * self.q_sf * self.C_sa * self.S_sa

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

        # Memory reads per inner-seq-loop body (e.g. per r-iteration)
        # Weight bank: for each (c_in_SARows, s_in_SARows, m_lane)
        self.reads_per_weight_bank = (self.C_sa // self.in_banks) * self.S_sa * self.m_sf
        # Input bank: for each (c_in_SARows, s_in_SARows, q_lane)
        self.reads_per_input_bank  = (self.C_sa // self.in_banks) * self.S_sa * self.q_sf
        self.max_reads_per_port = max(self.reads_per_weight_bank,
                                      self.reads_per_input_bank)

        # Crossover N_mul (compute-bound vs memory-bound threshold)
        self.N_mul_crossover = (self.U / self.max_reads_per_port
                                if self.max_reads_per_port > 0 else float("inf"))

    # ------------------------------------------------------------------
    def theoretical_cycles(self, N_mul: int) -> int:
        """Theoretical lower bound (alpha=1)."""
        II_compute = math.ceil(self.U / N_mul)
        II_memory  = self.max_reads_per_port  # BW = 1 word/cycle/port
        II = max(II_compute, II_memory)
        return self.T_outer * self.T_seq * II

    def predict(self, N_mul: int, alpha: float = 1.0) -> int:
        return int(round(alpha * self.theoretical_cycles(N_mul)))

    def bound_label(self, N_mul: int) -> str:
        II_compute = math.ceil(self.U / N_mul)
        II_memory  = self.max_reads_per_port
        if II_compute > II_memory:
            return "compute"
        elif II_compute < II_memory:
            return "memory"
        else:
            return "compute=memory"

    # ------------------------------------------------------------------
    def calibrate_alpha(self, N_mul: int, measured_cycles: int) -> float:
        """Fit alpha so predict(N_mul, alpha) == measured_cycles."""
        th = self.theoretical_cycles(N_mul)
        if th == 0:
            return 1.0
        return measured_cycles / th

    # ------------------------------------------------------------------
    def summary(self) -> str:
        lines = []
        m = self.mapping
        lines.append(f"Mapping : {m.arch_workload}  "
                     f"M={self.M} P={self.P} Q={self.Q} "
                     f"C={self.C} R={self.R} S={self.S}")
        lines.append(f"SACols  : M:{self.m_sf} P:{self.p_sf} Q:{self.q_sf}")
        lines.append(f"SARows  : C:{self.C_sa} S:{self.S_sa}")
        lines.append(f"Unroll depth U = {self.U}  "
                     f"(T_seq={self.T_seq}, T_outer={self.T_outer})")
        lines.append(f"total_MACs = {self.total_MACs}  "
                     f"(sanity U*T_seq*T_outer = {self.U*self.T_seq*self.T_outer})")
        lines.append(f"Reads/port/r-iter : weight={self.reads_per_weight_bank}  "
                     f"input={self.reads_per_input_bank}  "
                     f"max={self.max_reads_per_port}")
        lines.append(f"Crossover N_mul*  : {self.N_mul_crossover:.1f}  "
                     f"(powers-of-2: N_mul>={2**math.ceil(math.log2(self.N_mul_crossover))} "
                     f"is memory-bound)")
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
                    help="Known measured cycles for calibration, e.g. --measured 1:22895 4:6000")
    args = ap.parse_args()

    mapping = parse_ff_output(args.ff)
    model = BambuCycleModel(mapping)
    measured = _parse_measured(args)

    # Calibrate alpha from first measured point (or default to 1)
    alpha = 1.0
    if measured:
        ref_nmul = sorted(measured.keys())[0]
        alpha = model.calibrate_alpha(ref_nmul, measured[ref_nmul])

    print()
    print(model.summary())
    print(f"\nalpha = {alpha:.4f}  "
          f"({'calibrated from N_mul=' + str(sorted(measured.keys())[0]) if measured else 'default (theoretical lower bound, alpha=1)'})")
    print()

    n_muls = sorted(set(args.n_mul) | set(measured.keys()))
    header = f"{'N_mul':>6}  {'Bound':>15}  {'Predicted':>12}  {'Speedup vs N=1':>15}"
    print(header)
    print("-" * len(header))

    base = None
    for n in n_muls:
        pred = model.predict(n, alpha)
        lbl  = model.bound_label(n)
        if base is None:
            base = pred
        speedup = base / pred if pred > 0 else float("inf")
        meas_str = ""
        if n in measured:
            meas_str = f"  [measured: {measured[n]:,}]"
        print(f"{n:>6}  {lbl:>15}  {pred:>12,}  {speedup:>14.2f}x{meas_str}")

    print()
    print("Note: N_mul must be a power of 2 for Bambu (-C=__float_mul=N).")
    print("      Memory-bound regime: adding more multipliers gives no speedup.")


if __name__ == "__main__":
    main()
