#!/usr/bin/env python3
"""Eyeriss GEMM code generator: sequential baseline + SA-shaped kernel."""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple, Any

from mapping_types import MappingInfo
from harness.gemm_harness import make_gemm_testbench, gemm_tb_param_sizes


# =========================
# Public API
# =========================

def generate_experiment(mapping: MappingInfo, config: Dict[str, Any], out_dir: Path) -> None:
    """
    Eyeriss-GEMM generator runner.

    Writes into out_dir:
      - top_level_seq.c
      - top_level_sa.c
      - testbench_common.c
      - compile_bambu.sh
      - run_compare.sh
    """
    arch = (getattr(mapping, "arch", "") or "").lower().strip()
    wl   = (getattr(mapping, "workload", "") or "").upper().strip()
    if arch != "eyeriss" or wl != "GEMM":
        raise ValueError(
            f"[eyeriss_gemm_generator] Expected arch='eyeriss' workload='GEMM', "
            f"got arch={arch!r} workload={wl!r}"
        )

    bank = _infer_gemm_bank_spec(mapping)
    seq_c = _emit_top_level_seq(mapping, bank)
    sa_c  = _emit_top_level_sa(mapping, bank)
    tb_c  = make_gemm_testbench(mapping, bank)
    tb_sizes = gemm_tb_param_sizes(mapping, bank)

    bambu_cfg  = config.get("bambu", {}) or {}
    compile_sh = _emit_compile_bambu_sh(bambu_cfg, tb_sizes)
    compare_sh = _emit_run_compare_sh(bambu_cfg, tb_sizes)

    _write(out_dir / "top_level_seq.c",     seq_c)
    _write(out_dir / "top_level_sa.c",      sa_c)
    _write(out_dir / "testbench_common.c",  tb_c)
    _write(out_dir / "compile_bambu.sh",    compile_sh, make_executable=True)
    _write(out_dir / "run_compare.sh",      compare_sh, make_executable=True)

    for name in ("top_level_seq.c", "top_level_sa.c", "testbench_common.c",
                 "compile_bambu.sh", "run_compare.sh"):
        print(f"Wrote: {out_dir / name}")


# =========================
# Internal types / helpers
# =========================

@dataclass(frozen=True)
class GemmBankSpec:
    """
    Banked memory layout for Eyeriss GEMM:
      - A[M×K] → 2 weight banks split by k%2
      - B[K×N] → 2 input  banks split by k%2
      - C[M×N] → m_sf output banks split by m%m_sf
    """
    in_banks: int        # 2 (B matrix)
    w_banks: int         # 2 (A matrix)
    m_sf: int            # m_sacols * m_sarows (total M spatial factor)
    m_sacols: int        # M factor at SACols
    m_sarows: int        # M factor at SARows
    k_sa: int            # K factor at SACols (all K unrolled)
    out_banks: int       # = m_sf
    M_tiles: int         # ceil(M / m_sf) — outer M tile count
    N: int               # total N
    K: int               # total K
    k_blks: int          # ceil(K/2) — per-bank K elements
    in_bank_elems: int   # k_blks * N
    w_bank_elems: int    # M * k_blks
    out_bank_elems: int  # M_tiles * N


def _infer_gemm_bank_spec(mapping: MappingInfo) -> GemmBankSpec:
    d = mapping.dims
    M = int(d["M"]); K = int(d["K"]); N = int(d["N"])

    sacols   = mapping.tiling.get("SACols", {}) or {}
    sarows   = mapping.tiling.get("SARows", {}) or {}
    m_sacols = int(sacols.get("M", 1))
    k_sa     = int(sacols.get("K", 1))
    m_sarows = int(sarows.get("M", 1))
    m_sf     = m_sacols * m_sarows

    k_blks         = (K + 1) // 2
    in_bank_elems  = k_blks * N
    w_bank_elems   = M * k_blks
    M_tiles        = (M + m_sf - 1) // m_sf
    out_bank_elems = M_tiles * N

    return GemmBankSpec(
        in_banks=2, w_banks=2,
        m_sf=m_sf, m_sacols=m_sacols, m_sarows=m_sarows,
        k_sa=k_sa, out_banks=m_sf,
        M_tiles=M_tiles, N=N, K=K,
        k_blks=k_blks,
        in_bank_elems=in_bank_elems,
        w_bank_elems=w_bank_elems,
        out_bank_elems=out_bank_elems,
    )


def _top_signature(bank: GemmBankSpec) -> str:
    args = [
        "DTYPE *dram_w_b0", "DTYPE *dram_w_b1",
        "DTYPE *dram_in_b0", "DTYPE *dram_in_b1",
    ]
    for i in range(bank.out_banks):
        args.append(f"DTYPE *dram_out_b{i}")
    return "void top_level(" + ", ".join(args) + ")"


def _headers_and_pragmas(mapping: MappingInfo, bank: GemmBankSpec) -> str:
    d = mapping.dims
    M = int(d["M"]); K = int(d["K"]); N = int(d["N"])
    lines = [
        "#define DTYPE float",
        f"#define M_TOTAL {M}",
        f"#define K_TOTAL {K}",
        f"#define N_TOTAL {N}",
        "",
        "/* AXI pragmas for parallel memory buses */",
        "#pragma HLS interface port = dram_w_b0  mode = m_axi offset = direct bundle = gmem_w0",
        "#pragma HLS interface port = dram_w_b1  mode = m_axi offset = direct bundle = gmem_w1",
        "#pragma HLS interface port = dram_in_b0 mode = m_axi offset = direct bundle = gmem_in0",
        "#pragma HLS interface port = dram_in_b1 mode = m_axi offset = direct bundle = gmem_in1",
    ]
    for i in range(bank.out_banks):
        lines.append(
            f"#pragma HLS interface port = dram_out_b{i}"
            f" mode = m_axi offset = direct bundle = gmem_out{i}"
        )
    lines.append("")
    return "\n".join(lines)


def _out_store_switch(bank_expr: str, out_banks: int,
                      idx_expr: str, val_expr: str, indent: str) -> str:
    s = [f"{indent}switch({bank_expr}) {{"]
    for i in range(out_banks):
        s.append(f"{indent}  case {i}: dram_out_b{i}[{idx_expr}] = {val_expr}; break;")
    s.append(f"{indent}  default: break;")
    s.append(f"{indent}}}")
    return "\n".join(s)


# =========================
# top_level_seq.c
# =========================

def _emit_top_level_seq(mapping: MappingInfo, bank: GemmBankSpec) -> str:
    d = mapping.dims
    M = int(d["M"]); K = int(d["K"]); N = int(d["N"])
    m_sf    = bank.m_sf
    k_blks  = bank.k_blks
    M_tiles = bank.M_tiles

    hdr = _headers_and_pragmas(mapping, bank)
    sig = _top_signature(bank)

    code = [hdr, sig, "{"]
    code.append("    // Sequential GEMM baseline (banked I/O, write-only outputs)")
    code.append(f"    const int M={M}, K={K}, N={N};")
    code.append(f"    const int m_sf={m_sf}, k_blks={k_blks}, M_tiles={M_tiles};")
    code.append("")
    code.append("    for (int m = 0; m < M; ++m) {")
    code.append("      for (int n = 0; n < N; ++n) {")
    code.append("        DTYPE acc = 0.0f;")
    code.append("        for (int k = 0; k < K; ++k) {")
    code.append("          int k_bank = k & 1;")
    code.append("          int k_blk  = k >> 1;")
    code.append("          DTYPE wv = (k_bank==0) ? dram_w_b0[m * k_blks + k_blk]")
    code.append("                                 : dram_w_b1[m * k_blks + k_blk];")
    code.append("          DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + n]")
    code.append("                                 : dram_in_b1[k_blk * N + n];")
    code.append("          acc += wv * iv;")
    code.append("        }")
    code.append("        int out_bank = m % m_sf;")
    code.append("        int m_tile   = m / m_sf;")
    code.append("        int out_idx  = m_tile * N + n;")
    code.append(_out_store_switch("out_bank", bank.out_banks, "out_idx", "acc", "        "))
    code.append("      }")
    code.append("    }")
    code.append("}")
    code.append("")
    return "\n".join(code)


# =========================
# top_level_sa.c
# =========================

def _emit_top_level_sa(mapping: MappingInfo, bank: GemmBankSpec) -> str:
    from codegen.conv.eyeriss_generator import _classify_levels  # reuse level classifier

    d = mapping.dims
    M = int(d["M"]); K = int(d["K"]); N = int(d["N"])
    m_sf     = bank.m_sf
    m_sacols = bank.m_sacols
    m_sarows = bank.m_sarows
    k_sa     = bank.k_sa
    k_blks   = bank.k_blks
    M_tiles  = bank.M_tiles

    hdr = _headers_and_pragmas(mapping, bank)
    sig = _top_signature(bank)

    outer_mem, _fanout, inner_mem = _classify_levels(mapping)
    tiling = mapping.tiling

    def _level_short(lvl: str) -> str:
        s = {"DRAM": "dram", "GlobalBuffer": "gb", "WRegister": "wr", "InRegister": "ir"}
        return s.get(lvl, lvl.lower()[:3])

    # Collect outer temporal loop specs
    outer_n_var: str | None = None
    outer_m_var: str | None = None
    outer_k_var: str | None = None
    outer_loop_specs: list[tuple[str, int, str]] = []

    for lvl in outer_mem:
        til  = tiling.get(lvl, {})
        abbr = _level_short(lvl)
        for dim, fac in til.items():
            fac   = int(fac)
            vname = f"{dim.lower()}_{abbr}"
            outer_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "N": outer_n_var = vname
            if dim == "M": outer_m_var = vname
            if dim == "K": outer_k_var = vname

    # Inner sequential loops (InRegister / WRegister — usually empty for GEMM)
    inner_loop_specs: list[tuple[str, int, str]] = []
    for lvl in inner_mem:
        til = tiling.get(lvl, {})
        for dim, fac in til.items():
            fac   = int(fac)
            vname = dim.lower()
            inner_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))

    code = [hdr, sig, "{"]
    code.append("    // SA-shaped Eyeriss GEMM -- loop structure mirrors FF mapping hierarchy")
    code.append(f"    const int M={M}, K={K}, N={N};")
    code.append(f"    const int m_sf={m_sf}, m_sacols={m_sacols}, m_sarows={m_sarows};")
    code.append(f"    const int k_sa={k_sa}, k_blks={k_blks}, M_tiles={M_tiles};")
    code.append("")

    indent = "    "

    # Outer temporal loops
    for vname, fac, cmt in outer_loop_specs:
        code.append(f"{indent}// {cmt}")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    # Accumulator: acc[m_sf] (one scalar per M lane)
    code.append(f"{indent}// Accumulator: one element per M lane (N handled by outer loop)")
    code.append(f"{indent}DTYPE acc[{m_sf}];")
    code.append(f"{indent}#pragma GCC unroll {m_sf}")
    code.append(f"{indent}for (int mi = 0; mi < {m_sf}; ++mi) acc[mi] = 0.0f;")
    code.append("")

    # Inner sequential loops (usually none)
    for vname, fac, cmt in inner_loop_specs:
        code.append(f"{indent}// {cmt} (sequential)")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    # N index expression (always from outer loop — N is never in SA for GEMM)
    n_global_expr = outer_n_var if outer_n_var else "0"

    # SA unrolled body: SARows(m_sarows) × SACols(m_sacols, k_sa)
    code.append(f"{indent}// SARows M:{m_sarows} × SACols M:{m_sacols} × SACols K:{k_sa} — unrolled")
    code.append(f"{indent}#pragma GCC unroll {m_sarows}")
    code.append(f"{indent}for (int mri = 0; mri < {m_sarows}; ++mri) {{")
    code.append(f"{indent}  #pragma GCC unroll {m_sacols}")
    code.append(f"{indent}  for (int mci = 0; mci < {m_sacols}; ++mci) {{")
    code.append(f"{indent}    int acc_m = mri * {m_sacols} + mci;")
    if outer_m_var:
        code.append(f"{indent}    int m_global = {outer_m_var} * {m_sf} + acc_m;")
    else:
        code.append(f"{indent}    int m_global = acc_m;")
    code.append(f"{indent}    #pragma GCC unroll {k_sa}")
    code.append(f"{indent}    for (int kci = 0; kci < {k_sa}; ++kci) {{")
    if outer_k_var:
        code.append(f"{indent}      int k_global = {outer_k_var} * {k_sa} + kci;")
    else:
        code.append(f"{indent}      int k_global = kci;")
    code.append(f"{indent}      int k_bank = k_global & 1;")
    code.append(f"{indent}      int k_blk  = k_global >> 1;")
    code.append(f"{indent}      DTYPE wv = (k_bank==0) ? dram_w_b0[m_global * k_blks + k_blk]")
    code.append(f"{indent}                             : dram_w_b1[m_global * k_blks + k_blk];")
    code.append(f"{indent}      DTYPE iv = (k_bank==0) ? dram_in_b0[k_blk * N + {n_global_expr}]")
    code.append(f"{indent}                             : dram_in_b1[k_blk * N + {n_global_expr}];")
    code.append(f"{indent}      acc[acc_m] += wv * iv;")
    code.append(f"{indent}    }}  // kci")
    code.append(f"{indent}  }}  // mci")
    code.append(f"{indent}}}  // mri")
    code.append("")

    # Close inner sequential loops
    for _ in inner_loop_specs:
        indent = indent[:-2]
        code.append(f"{indent}}}  // inner seq")
    code.append("")

    # Output write: loop over m lanes and write acc to banked ports
    code.append(f"{indent}// Write accumulator to banked output ports")
    m_tile_expr = outer_m_var if outer_m_var else "0"
    code.append(f"{indent}#pragma GCC unroll {m_sf}")
    code.append(f"{indent}for (int ml = 0; ml < {m_sf}; ++ml) {{")
    code.append(f"{indent}  int out_idx = {m_tile_expr} * N + {n_global_expr};")
    code.append(_out_store_switch("ml", bank.out_banks, "out_idx", "acc[ml]", f"{indent}  "))
    code.append(f"{indent}}}  // ml")

    # Close outer temporal loops
    for _ in outer_loop_specs:
        indent = indent[:-2]
        code.append(f"{indent}}}  // outer")

    code.append("}")
    code.append("")
    return "\n".join(code)


# =========================
# Bambu scripts
# =========================

def _extract_float_mul(extra_args: list) -> Tuple[str, list]:
    pat = re.compile(r"^-C=__float_mul=(\d+)$")
    val = ""
    other = []
    for a in extra_args:
        m = pat.match(a.strip())
        if m:
            val = m.group(1)
        else:
            other.append(a)
    return val, other


def _emit_compile_bambu_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int]) -> str:
    clock    = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt      = bambu_cfg.get("opt_level", 3)
    v        = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []

    float_mul_default, other_args = _extract_float_mul(extra_args)

    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f"  --tb-param-size={name}:{sz} \\\n"

    other_flags = ""
    for a in other_args:
        other_flags += f"  {a} \\\n"

    return f"""#!/bin/bash
set -euo pipefail

TOP="${{1:-top_level_sa.c}}"
TB="testbench_common.c"
N_MUL_DEFAULT="{float_mul_default}"
N_MUL="${{2:-$N_MUL_DEFAULT}}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mul=$N_MUL"
fi

bambu "$TOP" \\
  --top-fname=top_level \\
  --generate-interface=INFER \\
  --compiler={compiler} \\
  --clock-period={clock} \\
  -O{opt} -v{v} \\
  --generate-tb="$TB" \\
{tb_flags}{other_flags}${{FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG}} \\
  --simulate
"""


def _emit_run_compare_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int]) -> str:
    clock    = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt      = bambu_cfg.get("opt_level", 3)
    v        = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []

    float_mul_default, other_args = _extract_float_mul(extra_args)

    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f'      --tb-param-size={name}:{sz} \\\n'

    other_flags = ""
    for a in other_args:
        other_flags += f'      {a} \\\n'

    return f"""#!/bin/bash
set -euo pipefail

SEQ="top_level_seq.c"
SA="top_level_sa.c"
TB="testbench_common.c"

BAMBU_OUT_ROOT="Bambu_outputs"

# Optional first argument: N_MUL overrides -C=__float_mul=N
N_MUL_DEFAULT="{float_mul_default}"
N_MUL="${{1:-$N_MUL_DEFAULT}}"

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

  local float_mul_flag=""
  if [[ -n "$N_MUL" ]]; then
    float_mul_flag="-C=__float_mul=$N_MUL"
  fi

  rm -rf "${{outdir}}"
  mkdir -p "${{outdir}}"

  (
    cd "${{outdir}}"
    bambu "../../${{top}}" \\
      --top-fname=top_level \\
      --generate-interface=INFER \\
      --compiler={compiler} \\
      --clock-period={clock} \\
      -O{opt} -v{v} \\
      --generate-tb="../../${{TB}}" \\
{tb_flags}{other_flags}${{float_mul_flag:+${{float_mul_flag}}}} \\
      --simulate
  ) > "${{log}}" 2>&1

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
    if not content.endswith("\n"):
        content += "\n"
    path.write_text(content)
    if make_executable:
        mode = path.stat().st_mode
        path.chmod(mode | 0o111)
