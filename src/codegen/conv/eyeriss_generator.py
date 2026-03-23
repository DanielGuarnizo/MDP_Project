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
    compare_sh = _emit_run_compare_sh(bambu_cfg, tb_sizes)

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

def _classify_levels(mapping: MappingInfo):
    """
    Split spatial_levels into three groups based on whether they are FanoutLevels
    (name contains "SA") or MemLevels:
      - outer_mem: MemLevels before the first FanoutLevel  (DRAM, GlobalBuffer)
      - fanout:    FanoutLevels in order                   (SACols, SARows)
      - inner_mem: MemLevels after the last FanoutLevel    (WRegister, InRegister)
                   (OutRegister excluded -- it's the accumulator, not a loop)
    Returns (outer_mem, fanout, inner_mem) as lists of level names.
    """
    levels = mapping.spatial_levels
    tiling = mapping.tiling

    fa_idx = [i for i, l in enumerate(levels) if "SA" in l]
    if not fa_idx:
        return list(levels), [], []

    first_fa, last_fa = fa_idx[0], fa_idx[-1]
    outer_mem  = [l for l in levels[:first_fa]   if tiling.get(l)]
    fanout     = [levels[i] for i in fa_idx]
    inner_mem  = [l for l in levels[last_fa+1:]
                  if "Register" in l and "Out" not in l and tiling.get(l)]
    return outer_mem, fanout, inner_mem


def _emit_top_level_sa(mapping: MappingInfo, bank: ConvBankSpec) -> str:
    """
    Generalized SA-shaped kernel (Option B):
    - Loop structure derived directly from the FF mapping hierarchy.
    - Outer temporal loops  → MemLevels above FanoutLevels (DRAM, GlobalBuffer).
    - Accumulator           → acc[m_sf][p_sf][q_sf] indexed by SACols output dims.
    - Inner sequential loop → MemLevels below FanoutLevels (WRegister R).
    - Unrolled compute body → FanoutLevel dims (SARows C,S; SACols M,Q)
                              with #pragma GCC unroll N.
    - Output write          → generalized for arbitrary (m_sf, p_sf, q_sf).
    Always emitted (no fallback to seq).
    """
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))
    H = P + R - 1; W = Q + S - 1

    m_sf = bank.m_sf; p_sf = bank.p_sf; q_sf = bank.q_sf
    Ptiles = bank.p_tiles; Qtiles = bank.q_tiles
    in_banks = bank.in_banks  # 2

    hdr = _emit_headers_and_pragmas(bank)
    sig = _emit_top_signature(bank)

    outer_mem, fanout, inner_mem = _classify_levels(mapping)
    tiling = mapping.tiling

    # ---- Outer temporal loops ----
    # Collect (varname, factor) for each dim at each outer MemLevel.
    # Dims that appear at FanoutLevels as output dims (M, P, Q) have corresponding
    # outer tile variables: q_outer (= cq), p_outer (= cp), m_outer (= cm).
    def _level_short(lvl):
        s = {"DRAM": "dram", "GlobalBuffer": "gb", "WRegister": "wr", "InRegister": "ir"}
        return s.get(lvl, lvl.lower()[:3])

    # We need to know which output dims have outer loops and which don't.
    # Outer tile var per output dim:
    outer_q_var = None; outer_q_factor = 1
    outer_p_var = None; outer_p_factor = 1
    outer_m_var = None; outer_m_factor = 1

    outer_loop_specs = []  # [(varname, factor, comment)]
    for lvl in outer_mem:
        til = tiling.get(lvl, {})
        abbr = _level_short(lvl)
        for dim, fac in til.items():
            fac = int(fac)
            vname = f"{dim.lower()}_{abbr}"
            outer_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "Q": outer_q_var = vname; outer_q_factor = fac
            if dim == "P": outer_p_var = vname; outer_p_factor = fac
            if dim == "M": outer_m_var = vname; outer_m_factor = fac

    # ---- Inner sequential loops (WRegister / InRegister) ----
    inner_loop_specs = []  # [(varname, factor, comment)]
    inner_r_var = None
    for lvl in inner_mem:
        til = tiling.get(lvl, {})
        for dim, fac in til.items():
            fac = int(fac)
            vname = dim.lower()
            inner_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "R": inner_r_var = vname

    # ---- SARows (unrolled reduction dims: C, S) ----
    sarows_til = tiling.get("SARows", {}) or {}
    C_sa = int(sarows_til.get("C", 1))  # SARows C factor (= total C if fully at SARows)
    S_sa = int(sarows_til.get("S", 1))

    # Verify: total C/S covered by SA + any outer loops
    # (SARows C) * (outer C if any) should equal total C
    # For now we assume C/S are fully at SARows (standard Eyeriss).

    # ---- Build code ----
    code = [hdr, sig, "{"]
    code.append("    // SA-shaped Eyeriss CONV -- loop structure mirrors FF mapping hierarchy")
    code.append(f"    const int M={M}, P={P}, Q={Q}, C={C}, R={R}, S={S};")
    code.append(f"    const int H={H}, W={W};")
    code.append(f"    const int m_sf={m_sf}, p_sf={p_sf}, q_sf={q_sf};")
    code.append(f"    const int Ptiles={Ptiles}, Qtiles={Qtiles};")
    code.append(f"    const int in_banks={in_banks};")
    code.append("")

    indent = "    "

    # -- Outer temporal loops --
    for vname, fac, cmt in outer_loop_specs:
        code.append(f"{indent}// {cmt}")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    # -- Accumulator declaration + init --
    # Collapse the trivial p-dimension when p_sf==1 to avoid Bambu 3D-array overhead
    if p_sf == 1:
        code.append(f"{indent}// Accumulator: acc[m_sf][q_sf] (p_sf=1, collapsed)")
        code.append(f"{indent}DTYPE acc[{m_sf}][{q_sf}];")
        code.append(f"{indent}#pragma GCC unroll {m_sf}")
        code.append(f"{indent}for (int mi = 0; mi < {m_sf}; ++mi) {{")
        code.append(f"{indent}  #pragma GCC unroll {q_sf}")
        code.append(f"{indent}  for (int qi = 0; qi < {q_sf}; ++qi) {{")
        code.append(f"{indent}    acc[mi][qi] = 0.0f;")
        code.append(f"{indent}  }}")
        code.append(f"{indent}}}")
    else:
        code.append(f"{indent}// Accumulator: SACols output lanes acc[m_sf][p_sf][q_sf]")
        code.append(f"{indent}DTYPE acc[{m_sf}][{p_sf}][{q_sf}];")
        code.append(f"{indent}#pragma GCC unroll {m_sf}")
        code.append(f"{indent}for (int mi = 0; mi < {m_sf}; ++mi) {{")
        code.append(f"{indent}  #pragma GCC unroll {p_sf}")
        code.append(f"{indent}  for (int pi = 0; pi < {p_sf}; ++pi) {{")
        code.append(f"{indent}    #pragma GCC unroll {q_sf}")
        code.append(f"{indent}    for (int qi = 0; qi < {q_sf}; ++qi) {{")
        code.append(f"{indent}      acc[mi][pi][qi] = 0.0f;")
        code.append(f"{indent}    }}")
        code.append(f"{indent}  }}")
        code.append(f"{indent}}}")
    code.append("")

    # -- Inner sequential loops (WRegister R) --
    for vname, fac, cmt in inner_loop_specs:
        code.append(f"{indent}// {cmt} (sequential)")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    r_var = inner_r_var if inner_r_var else "r"

    # -- SARows unrolled: C, S --
    code.append(f"{indent}// SARows C:{C_sa} -- unrolled reduction (channels)")
    code.append(f"{indent}#pragma GCC unroll {C_sa}")
    code.append(f"{indent}for (int c = 0; c < {C_sa}; ++c) {{")
    code.append(f"{indent}  int c_bank = c & 1;")
    code.append(f"{indent}  int c_blk  = c >> 1;  // c / in_banks")
    code.append(f"{indent}  int in_c_base = c_blk * (H * W);")

    # q_base: where this outer q tile starts in the full Q dimension
    if outer_q_var:
        code.append(f"{indent}  int q_base = {outer_q_var} * {q_sf};")
    else:
        code.append(f"{indent}  int q_base = 0;")

    # p_base: where this outer p tile starts in the full P dimension
    if outer_p_var:
        code.append(f"{indent}  // p_sf={p_sf}: p_base covers p_sf output rows per tile")
        code.append(f"{indent}  // SACols P lanes handled by pl loop below")
    code.append("")

    code.append(f"{indent}  // SARows S:{S_sa} -- unrolled (filter cols)")
    code.append(f"{indent}  #pragma GCC unroll {S_sa}")
    code.append(f"{indent}  for (int s = 0; s < {S_sa}; ++s) {{")

    # -- SACols unrolled: ml (M lane), pl (P lane), ql (Q lane) --
    code.append(f"{indent}    // SACols M:{m_sf} -- unrolled (output filter lanes)")
    code.append(f"{indent}    #pragma GCC unroll {m_sf}")
    code.append(f"{indent}    for (int ml = 0; ml < {m_sf}; ++ml) {{")

    # m_total for weight index
    if outer_m_var:
        m_total_expr = f"({outer_m_var} * {m_sf} + ml)"
    else:
        m_total_expr = "ml"

    code.append(f"{indent}      int w_idx = ({m_total_expr} * (C / in_banks) + c_blk) * (R * S) + {r_var} * S + s;")
    code.append(f"{indent}      DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];")
    code.append("")

    if p_sf == 1:
        # p_sf==1: no pl loop, inline p_row directly
        if outer_p_var:
            p_row_expr = f"({outer_p_var} + {r_var})"
        else:
            p_row_expr = f"{r_var}"

        code.append(f"{indent}      int in_row_base = in_c_base + {p_row_expr} * W;")
        code.append("")
        code.append(f"{indent}      // SACols Q:{q_sf} -- unrolled (output col lanes)")
        code.append(f"{indent}      #pragma GCC unroll {q_sf}")
        code.append(f"{indent}      for (int ql = 0; ql < {q_sf}; ++ql) {{")
        code.append(f"{indent}        int in_col = q_base + ql + s;")
        code.append(f"{indent}        DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]")
        code.append(f"{indent}                                : dram_in_b1[in_row_base + in_col];")
        code.append(f"{indent}        acc[ml][ql] += wv * inv;")
        code.append(f"{indent}      }}  // ql")
        code.append(f"{indent}    }}  // ml")
    else:
        code.append(f"{indent}      // SACols P:{p_sf} -- unrolled (output row lanes)")
        code.append(f"{indent}      #pragma GCC unroll {p_sf}")
        code.append(f"{indent}      for (int pl = 0; pl < {p_sf}; ++pl) {{")

        if outer_p_var:
            p_row_expr = f"({outer_p_var} * {p_sf} + pl + {r_var})"
        else:
            p_row_expr = f"(pl + {r_var})"

        code.append(f"{indent}        int in_row_base = in_c_base + {p_row_expr} * W;")
        code.append("")
        code.append(f"{indent}        // SACols Q:{q_sf} -- unrolled (output col lanes)")
        code.append(f"{indent}        #pragma GCC unroll {q_sf}")
        code.append(f"{indent}        for (int ql = 0; ql < {q_sf}; ++ql) {{")
        code.append(f"{indent}          int in_col = q_base + ql + s;")
        code.append(f"{indent}          DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]")
        code.append(f"{indent}                                  : dram_in_b1[in_row_base + in_col];")
        code.append(f"{indent}          acc[ml][pl][ql] += wv * inv;")
        code.append(f"{indent}        }}  // ql")
        code.append(f"{indent}      }}  // pl")
        code.append(f"{indent}    }}  // ml")
    code.append(f"{indent}  }}  // s")
    code.append(f"{indent}}}  // c")
    code.append("")

    # Close inner sequential loops
    for _ in inner_loop_specs:
        indent = indent[:-2]
        code.append(f"{indent}}}  // inner seq")
    code.append("")

    # -- Output write: loop over ml, [pl,] ql and write acc to banked ports --
    code.append(f"{indent}// OutRegister: write acc to banked output ports")
    cm_expr = f"{outer_m_var}" if outer_m_var else "0"
    cq_expr = f"{outer_q_var}" if outer_q_var else "0"

    if p_sf == 1:
        cp_expr = f"{outer_p_var}" if outer_p_var else "0"
        code.append(f"{indent}#pragma GCC unroll {m_sf}")
        code.append(f"{indent}for (int ml = 0; ml < {m_sf}; ++ml) {{")
        code.append(f"{indent}  #pragma GCC unroll {q_sf}")
        code.append(f"{indent}  for (int ql = 0; ql < {q_sf}; ++ql) {{")
        code.append(f"{indent}    int out_bank = ml * {q_sf} + ql;")
        code.append(f"{indent}    int cm = {cm_expr};")
        code.append(f"{indent}    int cp = {cp_expr};")
        code.append(f"{indent}    int cq = {cq_expr};")
        code.append(f"{indent}    int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;")
        code.append(f"{indent}    DTYPE v = acc[ml][ql];")
        code.append(_emit_out_store_switch_fixed("out_bank", bank.out_banks,
                                                 "out_idx_b", "v", f"{indent}    "))
        code.append(f"{indent}  }}  // ql")
        code.append(f"{indent}}}  // ml")
    else:
        if outer_p_var:
            cp_expr = f"{outer_p_var}"
        else:
            cp_expr = "pl"
        code.append(f"{indent}#pragma GCC unroll {m_sf}")
        code.append(f"{indent}for (int ml = 0; ml < {m_sf}; ++ml) {{")
        code.append(f"{indent}  #pragma GCC unroll {p_sf}")
        code.append(f"{indent}  for (int pl = 0; pl < {p_sf}; ++pl) {{")
        code.append(f"{indent}    #pragma GCC unroll {q_sf}")
        code.append(f"{indent}    for (int ql = 0; ql < {q_sf}; ++ql) {{")
        code.append(f"{indent}      int out_bank = (ml * {p_sf} + pl) * {q_sf} + ql;")
        code.append(f"{indent}      int cm = {cm_expr};")
        code.append(f"{indent}      int cp = {cp_expr};")
        code.append(f"{indent}      int cq = {cq_expr};")
        code.append(f"{indent}      int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;")
        code.append(f"{indent}      DTYPE v = acc[ml][pl][ql];")
        code.append(_emit_out_store_switch_fixed("out_bank", bank.out_banks,
                                                 "out_idx_b", "v", f"{indent}      "))
        code.append(f"{indent}    }}  // ql")
        code.append(f"{indent}  }}  // pl")
        code.append(f"{indent}}}  // ml")

    # Close outer temporal loops
    for _ in outer_loop_specs:
        indent = indent[:-2]
        code.append(f"{indent}}}  // outer")

    code.append("}")
    code.append("")
    return "\n".join(code)


# =========================
# Scripts
# =========================

def _extract_float_mul(extra_args: list) -> Tuple[str, list]:
    """Split extra_args into (float_mul_val, other_args).
    float_mul_val is '' if no -C=__float_mul=N flag is present."""
    import re
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
    """
    A generalistic compile script:
      ./compile_bambu.sh [top_file.c [N_MUL]]
    Defaults to top_level_sa.c if top omitted; N_MUL overrides -C=__float_mul.
    """
    clock = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt = bambu_cfg.get("opt_level", 3)
    v = bambu_cfg.get("v", 4)
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
    """
    One-command runner:
      - CPU correctness for seq + sa
      - Bambu cosim for seq + sa
      - prints only cycle counts
      - stores ALL bambu-generated files under Bambu_outputs/{seq,sa}
      - stores logs under Bambu_outputs/{seq,sa}/bambu_{seq,sa}.log
    """
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

  # Run Bambu inside its output directory so ALL generated files land there,
  # and write the log there too.
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