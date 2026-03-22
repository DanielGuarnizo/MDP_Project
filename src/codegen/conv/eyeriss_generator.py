#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple, Any

from mapping_types import MappingInfo, ConvBankSpec
from harness.conv_harness import make_conv_testbench, conv_tb_param_sizes



# =========================
# Public API (contract)
# =========================

def generate_experiment(mapping: MappingInfo, config: Dict[str, Any], out_dir: Path) -> None:
    """
    Eyeriss-CONV generator runner.

    Writes into out_dir:
      - top_level_seq.c
      - top_level_sa.c
      - testbench_common.c
      - compile_bambu.sh
      - run_compare.sh

    Must keep correctness:
      - testbench_common.c compares against golden conv
      - run_compare.sh runs CPU correctness for both seq/sa
      - run_compare.sh runs Bambu cosim for both seq/sa and prints cycles
    """
    # VALIDATION (correct fields)
    arch = (getattr(mapping, "arch", "") or "").lower().strip()
    wl   = (getattr(mapping, "workload", "") or "").upper().strip()
    aw   = (getattr(mapping, "arch_workload", "") or "").lower().strip()

    if arch != "eyeriss" or wl != "CONV":
        raise ValueError(
            f"[eyeriss_generator] Expected arch='eyeriss' and workload='CONV', "
            f"got arch={arch!r}, workload={wl!r}, arch_workload={aw!r}"
        )

    # Optional extra safety:
    if aw and not aw.endswith("-conv"):
        raise ValueError(
            f"[eyeriss_generator] Expected arch_workload to end with '-conv', got {aw!r}"
        )

    # --- Build bank spec (Eyeriss CONV assumptions) ---
    bank = _infer_eyeriss_bank_spec(mapping)

    # --- Generate files ---
    seq_c = _emit_top_level_seq(mapping, bank)
    sa_c  = _emit_top_level_sa(mapping, bank)

    tb_c  = make_conv_testbench(mapping, bank)  # common TB used for CPU and Bambu
    tb_sizes = conv_tb_param_sizes(mapping, bank)

    bambu_cfg = config.get("bambu", {}) or {}
    compile_sh = _emit_compile_bambu_sh(bambu_cfg, tb_sizes)
    compare_sh = _emit_run_compare_sh(tb_sizes)

    _write(out_dir / "top_level_seq.c", seq_c)
    _write(out_dir / "top_level_sa.c",  sa_c)
    _write(out_dir / "testbench_common.c", tb_c)
    _write(out_dir / "compile_bambu.sh", compile_sh, make_executable=True)
    _write(out_dir / "run_compare.sh", compare_sh, make_executable=True)

    print(f"Wrote: {out_dir/'top_level_seq.c'}")
    print(f"Wrote: {out_dir/'top_level_sa.c'}")
    print(f"Wrote: {out_dir/'testbench_common.c'}")
    print(f"Wrote: {out_dir/'compile_bambu.sh'}")
    print(f"Wrote: {out_dir/'run_compare.sh'}")


# =========================
# Internal types/helpers
# =========================

@dataclass(frozen=True)
class ConvBankSpec:
    """
    Describes the banked memory layout we generate against.
    For this Eyeriss-CONV path we assume:
      - in_banks = 2  (split by c%2, blk=c>>1)
      - w_banks  = 2  (split by c%2, blk=c>>1)
      - out banks = m_sf * p_sf * q_sf (from SACols output dims)
    """
    in_banks: int
    w_banks: int
    out_banks: int
    m_sf: int
    p_sf: int
    q_sf: int
    p_tiles: int
    q_tiles: int


def _infer_eyeriss_bank_spec(mapping: MappingInfo) -> ConvBankSpec:
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])

    # For Eyeriss, output banking should be driven by the *spatial array* levels,
    # especially SACols (M,Q) in your mapping.
    m_sf, p_sf, q_sf = _out_bank_factors_eyeriss(mapping)

    p_tiles = (P + p_sf - 1) // p_sf
    q_tiles = (Q + q_sf - 1) // q_sf

    out_banks = max(1, m_sf * p_sf * q_sf)

    return ConvBankSpec(
        in_banks=2,
        w_banks=2,
        out_banks=out_banks,
        m_sf=m_sf,
        p_sf=p_sf,
        q_sf=q_sf,
        p_tiles=p_tiles,
        q_tiles=q_tiles,
    )


def _out_bank_factors_eyeriss(mapping: MappingInfo) -> Tuple[int, int, int]:
    """
    Eyeriss-specific policy:
      - Prefer SACols factors for M/P/Q if present
      - Fall back to spatial_levels filtered to 'SA' levels
      - Final fallback: (1,1,1)
    """
    tiling = getattr(mapping, "tiling", {}) or {}

    # 1) Best: SACols directly
    sacols = tiling.get("SACols", {}) or {}
    m_sf = int(sacols.get("M", 1))
    p_sf = int(sacols.get("P", 1))
    q_sf = int(sacols.get("Q", 1))

    if m_sf * p_sf * q_sf > 1:
        return max(1, m_sf), max(1, p_sf), max(1, q_sf)

    # 2) Otherwise: multiply factors from spatial levels that look like SA
    m_sf = p_sf = q_sf = 1
    for lvl in getattr(mapping, "spatial_levels", []) or []:
        if "SA" not in lvl:  # keep Eyeriss policy tight to avoid exploding banks
            continue
        lt = tiling.get(lvl, {}) or {}
        if "M" in lt: m_sf *= int(lt["M"])
        if "P" in lt: p_sf *= int(lt["P"])
        if "Q" in lt: q_sf *= int(lt["Q"])

    return max(1, m_sf), max(1, p_sf), max(1, q_sf)


def _emit_headers_and_pragmas(bank: ConvBankSpec) -> str:
    # Minimal macros + pragmas
    lines = []
    lines.append("#define DTYPE float")
    lines.append("#define M_TOTAL 4")
    lines.append("#define P_TOTAL 4")
    lines.append("#define Q_TOTAL 4")
    lines.append("#define C_TOTAL 4")
    lines.append("#define R_TOTAL 3")
    lines.append("#define S_TOTAL 3")
    lines.append("")
    lines.append("/* AXI pragmas for parallel memory buses */")
    lines.append("#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0")
    lines.append("#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1")
    lines.append("#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0")
    lines.append("#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1")
    for i in range(bank.out_banks):
        lines.append(f"#pragma HLS interface port = dram_out_b{i} mode = m_axi offset = direct bundle = gmem_out{i}")
    lines.append("")
    return "\n".join(lines)


def _emit_top_signature(bank: ConvBankSpec) -> str:
    args = [
        "DTYPE *dram_in_b0", "DTYPE *dram_in_b1",
        "DTYPE *dram_w_b0",  "DTYPE *dram_w_b1",
    ]
    for i in range(bank.out_banks):
        args.append(f"DTYPE *dram_out_b{i}")
    return "void top_level(" + ", ".join(args) + ")"


def _emit_out_store_switch(bank: ConvBankSpec, idx_expr: str, val_expr: str, indent: str) -> str:
    s = []
    s.append(f"{indent}switch(out_bank) {{")
    for i in range(bank.out_banks):
        s.append(f"{indent}  case {i}: dram_out_b{i}[{idx_expr}] = {val_expr}; break;")
    s.append(f"{indent}  default: break;")
    s.append(f"{indent}}}")
    return "\n".join(s)


def _emit_out_store_switch_fixed(bank_index: int, out_banks: int, idx_expr: str, val_expr: str, indent: str) -> str:
    # Used in SA version where out_bank is known (lane_m*2 + lane_q)
    s = []
    s.append(f"{indent}switch({bank_index}) {{")
    for i in range(out_banks):
        s.append(f"{indent}  case {i}: dram_out_b{i}[{idx_expr}] = {val_expr}; break;")
    s.append(f"{indent}  default: break;")
    s.append(f"{indent}}}")
    return "\n".join(s)


# =========================
# top_level_seq.c
# =========================

def _emit_top_level_seq(mapping: MappingInfo, bank: ConvBankSpec) -> str:
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))
    H = P + R - 1
    W = Q + S - 1

    hdr = _emit_headers_and_pragmas(bank)
    sig = _emit_top_signature(bank)

    # Sequential baseline: natural nested loops; outputs write-only (acc starts at 0)
    # Output banking computed from (m_sf,p_sf,q_sf) in bank spec.
    code = [hdr, sig, "{"]

    code.append("    // Sequential baseline (banked I/O, write-only outputs)")
    code.append(f"    const int M={M}, P={P}, Q={Q}, C={C}, R={R}, S={S};")
    code.append(f"    const int H={H}, W={W};")
    code.append(f"    const int m_sf={bank.m_sf}, p_sf={bank.p_sf}, q_sf={bank.q_sf};")
    code.append(f"    const int Ptiles={bank.p_tiles}, Qtiles={bank.q_tiles};")
    code.append("")

    code.append("    for (int m = 0; m < M; ++m) {")
    code.append("      for (int p = 0; p < P; ++p) {")
    code.append("        for (int q = 0; q < Q; ++q) {")

    code.append("          int lane_m = (m_sf==1)?0:(m % m_sf);")
    code.append("          int lane_p = (p_sf==1)?0:(p % p_sf);")
    code.append("          int lane_q = (q_sf==1)?0:(q % q_sf);")
    code.append("          int out_bank = (lane_m*p_sf + lane_p)*q_sf + lane_q;")
    code.append("          int cm = (m_sf==1)?m:(m / m_sf);")
    code.append("          int cp = (p_sf==1)?p:(p / p_sf);")
    code.append("          int cq = (q_sf==1)?q:(q / q_sf);")
    code.append("          int out_idx_b = (cm*Ptiles + cp)*Qtiles + cq;")
    code.append("          DTYPE acc = 0.0f;")

    code.append("          for (int c = 0; c < C; ++c) {")
    code.append("            int c_bank = c & 1;")
    code.append("            int c_blk  = c >> 1;")
    code.append("            for (int r = 0; r < R; ++r) {")
    code.append("              for (int s = 0; s < S; ++s) {")
    code.append("                int in_idx = c_blk*(H*W) + (p+r)*W + (q+s);")
    code.append("                int w_idx  = (m*(C/2) + c_blk)*(R*S) + r*S + s;")
    code.append("                DTYPE in_v = (c_bank==0) ? dram_in_b0[in_idx] : dram_in_b1[in_idx];")
    code.append("                DTYPE w_v  = (c_bank==0) ? dram_w_b0[w_idx]  : dram_w_b1[w_idx];")
    code.append("                acc += w_v * in_v;")
    code.append("              }")
    code.append("            }")
    code.append("          }")
    code.append(_emit_out_store_switch(bank, "out_idx_b", "acc", "          "))

    code.append("        }")
    code.append("      }")
    code.append("    }")

    code.append("}")
    code.append("")
    return "\n".join(code)


# =========================
# top_level_sa.c  (Eyeriss SA)
# =========================

def _emit_top_level_sa(mapping: MappingInfo, bank: ConvBankSpec) -> str:
    """
    SA-shaped code for Eyeriss-CONV:
      DRAM ----------> Q: 2     (q_dram tiles)
      GlobalBuffer --> P: 4     (p loop)
      SACols --------> Q: 2, M: 4   (compute 8 outputs per (p,q_dram))
      SARows --------> S: 3, C: 4   (unroll s and c)
      WRegister -----> R: 3         (keep r sequential; matches the best 20996 result)
      OutRegister ---             (write once per output)

    IMPORTANT:
      - This SA generator is specific to your current Eyeriss conv assumptions:
          p_sf == 1, q_sf == 2, and m_sf == M (M lanes inside SACols)
      - If mapping differs, we fall back to seq code.
    """
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))
    H = P + R - 1
    W = Q + S - 1

    hdr = _emit_headers_and_pragmas(bank)
    sig = _emit_top_signature(bank)

    # Guard: only apply “fast SA” when it matches Eyeriss mapping we tuned.
    # Otherwise, fall back to seq baseline.
    if not (bank.q_sf == 2 and bank.p_sf == 1 and bank.m_sf == M):
        # fallback: still produce a valid top_level_sa.c, but sequential
        return _emit_top_level_seq(mapping, bank).replace("top_level_seq", "top_level_sa")

    code = [hdr, sig, "{"]

    code.append("    // SA-shaped Eyeriss CONV (write-only outputs)")
    code.append(f"    const int M={M}, P={P}, Q={Q}, C={C}, R={R}, S={S};")
    code.append(f"    const int H={H}, W={W};")
    code.append(f"    const int m_sf={bank.m_sf}, p_sf={bank.p_sf}, q_sf={bank.q_sf};")
    code.append(f"    const int Ptiles={bank.p_tiles}, Qtiles={bank.q_tiles};")
    code.append("")

    # q_dram = coarse q tile (Q/2)
    code.append("    // DRAM level: Q tiles (q_sf==2 => Qtiles=Q/2)")
    code.append("    for (int q_dram = 0; q_dram < Qtiles; ++q_dram) {")
    code.append("      // GlobalBuffer level: P tiles (p_sf==1 => full P)")
    code.append("      for (int p = 0; p < P; ++p) {")

    # acc[m_lane][q_lane]
    code.append("        // SACols: compute M lanes x 2 q-lanes per tile")
    code.append("        DTYPE acc[4][2];")
    code.append("        #pragma HLS unroll")
    code.append("        for (int mi = 0; mi < 4; ++mi) {")
    code.append("          #pragma HLS unroll")
    code.append("          for (int qi = 0; qi < 2; ++qi) {")
    code.append("            acc[mi][qi] = 0.0f;")
    code.append("          }")
    code.append("        }")
    code.append("")

    # r sequential
    code.append("        // WRegister: R sequential (this is the best-performing setting you measured)")
    code.append("        for (int r = 0; r < R; ++r) {")
    # c unrolled
    code.append("          #pragma HLS unroll")
    code.append("          for (int c = 0; c < C; ++c) {")
    code.append("            int c_bank = c & 1;")
    code.append("            int c_blk  = c >> 1;")
    code.append("            int in_c_base  = c_blk * (H * W);")
    code.append("            int in_row_base = in_c_base + (p + r) * W;")
    code.append("            int q_base = q_dram * 2;  // global_q = q_base + q_lane")
    code.append("")
    # s unrolled
    code.append("            #pragma HLS unroll")
    code.append("            for (int s = 0; s < S; ++s) {")
    code.append("              DTYPE in_q0 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 0 + s)]")
    code.append("                                        : dram_in_b1[in_row_base + (q_base + 0 + s)];")
    code.append("              DTYPE in_q1 = (c_bank==0) ? dram_in_b0[in_row_base + (q_base + 1 + s)]")
    code.append("                                        : dram_in_b1[in_row_base + (q_base + 1 + s)];")
    code.append("")
    # m_lane unrolled
    code.append("              #pragma HLS unroll")
    code.append("              for (int m_lane = 0; m_lane < 4; ++m_lane) {")
    code.append("                int w_idx = (m_lane * (C/2) + c_blk) * (R * S) + r * S + s;")
    code.append("                DTYPE wv  = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];")
    code.append("                acc[m_lane][0] += wv * in_q0;")
    code.append("                acc[m_lane][1] += wv * in_q1;")
    code.append("              }")
    code.append("            }")
    code.append("          }")
    code.append("        }")
    code.append("")

    # Write outputs for this (p,q_dram)
    code.append("        // OutRegister: write once per output (banked by lane_m and lane_q)")
    code.append("        for (int m_lane = 0; m_lane < 4; ++m_lane) {")
    code.append("          int lane_m = m_lane;")
    code.append("          int cm = 0;            // m_sf==M => cm always 0")
    code.append("          int cp = p;            // p_sf==1")
    code.append("          int cq = q_dram;       // q_sf==2")
    code.append("          int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;")
    code.append("          int out_bank0 = (lane_m * 1 + 0) * 2 + 0;")
    code.append("          int out_bank1 = (lane_m * 1 + 0) * 2 + 1;")
    code.append("          DTYPE v0 = acc[m_lane][0];")
    code.append("          DTYPE v1 = acc[m_lane][1];")
    code.append(_emit_out_store_switch_fixed("out_bank0", bank.out_banks, "out_idx_b", "v0", "          "))
    code.append(_emit_out_store_switch_fixed("out_bank1", bank.out_banks, "out_idx_b", "v1", "          "))
    code.append("        }")

    code.append("      }")
    code.append("    }")

    code.append("}")
    code.append("")
    return "\n".join(code)


# =========================
# Scripts
# =========================

def _emit_compile_bambu_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int]) -> str:
    """
    A generalistic compile script:
      ./compile_bambu.sh [top_file.c]
    Defaults to top_level_sa.c if omitted.
    """
    clock = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt = bambu_cfg.get("opt_level", 3)
    v = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []

    extra = ""
    for name, sz in tb_sizes.items():
        extra += f"  --tb-param-size={name}:{sz} \\\n"

    extra2 = ""
    for a in extra_args:
        extra2 += f"  {a} \\\n"

    return f"""#!/bin/bash
set -euo pipefail

TOP="${{1:-top_level_sa.c}}"
TB="testbench_common.c"

bambu "$TOP" \\
  --top-fname=top_level \\
  --generate-interface=INFER \\
  --compiler={compiler} \\
  --clock-period={clock} \\
  -O{opt} -v{v} \\
  --generate-tb="$TB" \\
{extra}{extra2}  --simulate \\
  "${{@:2}}"
"""




def _emit_run_compare_sh(tb_sizes: Dict[str, int]) -> str:
    """
    One-command runner:
      - CPU correctness for seq + sa
      - Bambu cosim for seq + sa
      - prints only cycle counts
      - stores ALL bambu-generated files under Bambu_outputs/{seq,sa}
      - stores logs under Bambu_outputs/{seq,sa}/bambu_{seq,sa}.log
    """
    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f'      --tb-param-size={name}:{sz} \\\n'

    return f"""#!/bin/bash
set -euo pipefail

SEQ="top_level_seq.c"
SA="top_level_sa.c"
TB="testbench_common.c"

BAMBU_OUT_ROOT="Bambu_outputs"

echo
echo "============================================================"
echo "[CPU] correctness for $SEQ"
echo "============================================================"
gcc -O2 -o cpu_seq "$SEQ" "$TB" -lm
./cpu_seq

echo
echo "============================================================"
echo "[CPU] correctness for $SA"
echo "============================================================"
gcc -O2 -o cpu_sa "$SA" "$TB" -lm
./cpu_sa

run_bambu () {{
  local tag="$1"   # seq / sa
  local top="$2"   # top_level_*.c

  local outdir="${{BAMBU_OUT_ROOT}}/${{tag}}"
  local log="${{outdir}}/bambu_${{tag}}.log"

  rm -rf "${{outdir}}"
  mkdir -p "${{outdir}}"

  # Run Bambu inside its output directory so ALL generated files land there,
  # and write the log there too.
  (
    cd "${{outdir}}"
    bambu "../../${{top}}" \\
      --top-fname=top_level \\
      --generate-interface=INFER \\
      --compiler=I386_GCC8 \\
      --clock-period=5 \\
      -O3 -v4 \\
      --generate-tb="../../${{TB}}" \\
{tb_flags}      --simulate 
  ) > "${{log}}" 2>&1

  # Extract cycles from the log inside outdir
  grep -E "Run 1 execution time" -m1 "${{log}}" | awk '{{print $(NF-1)}}'
}}

echo
echo "============================================================"
echo "[BAMBU] cycles (seq)"
echo "============================================================"
SEQ_CYCLES="$(run_bambu "seq" "$SEQ")"
echo "seq cycles: $SEQ_CYCLES"

echo
echo "============================================================"
echo "[BAMBU] cycles (sa)"
echo "============================================================"
SA_CYCLES="$(run_bambu "sa" "$SA")"
echo "sa cycles: $SA_CYCLES"

echo
echo "==================== SUMMARY ===================="
echo "seq cycles: $SEQ_CYCLES"
echo " sa cycles: $SA_CYCLES"
echo "================================================="
echo "Logs:"
echo "  $BAMBU_OUT_ROOT/seq/bambu_seq.log"
echo "  $BAMBU_OUT_ROOT/sa/bambu_sa.log"
echo "Bambu outputs:"
echo "  $BAMBU_OUT_ROOT/seq"
echo "  $BAMBU_OUT_ROOT/sa"
"""

def _write(path: Path, content: str, make_executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # ensure trailing newline
    if not content.endswith("\n"):
        content += "\n"
    path.write_text(content)
    if make_executable:
        mode = path.stat().st_mode
        path.chmod(mode | 0o111)
        

def _write_text(path: Path, content: str) -> None:
    _write(path, content, make_executable=False)