#!/usr/bin/env python3
from __future__ import annotations

import math
from dataclasses import dataclass
from itertools import product as iprod
from pathlib import Path
from typing import Dict, List, Tuple, Any

from mapping_types import MappingInfo
from harness.conv_harness import make_conv_testbench, conv_tb_param_sizes


# =========================
# SA dimension spec
# =========================

@dataclass
class SADimSpec:
    """SA spatial partition specification derived from a FF mapping.

    all_dims: SARows partitions first (FF order), then SACols partitions (FF order).
    Each entry: (dim_name, factor, level) where level ∈ {"SARows", "SACols"}.

    Naming convention for generated C loop variables:
      sarows_0, sarows_1, … for SARows partitions in FF order
      sacols_0, sacols_1, … for SACols partitions in FF order
    """
    all_dims: List[Tuple[str, int, str]]

    @property
    def N_PE(self) -> int:
        """Total PE count = product of all spatial partition factors."""
        return math.prod(f for _, f, _ in self.all_dims)

    @property
    def red_dims(self) -> List[Tuple[str, int, str]]:
        """Reduction partitions: dim ∉ {M,P,Q} — PEs with different indices
        compute partial sums for the SAME output element and must be summed."""
        return [(d, f, l) for d, f, l in self.all_dims if d not in {'M', 'P', 'Q'}]

    @property
    def out_dims(self) -> List[Tuple[str, int, str]]:
        """Output partitions: dim ∈ {M,P,Q} — PEs with different indices
        compute results for DIFFERENT output elements, no summation needed."""
        return [(d, f, l) for d, f, l in self.all_dims if d in {'M', 'P', 'Q'}]

    @property
    def N_red(self) -> int:
        """Number of partial-sum inputs per output element (scalar tree size)."""
        return math.prod(f for _, f, _ in self.red_dims) if self.red_dims else 1

    @property
    def N_out(self) -> int:
        """Number of distinct output elements handled by the SA per tile."""
        return math.prod(f for _, f, _ in self.out_dims) if self.out_dims else 1

    def loop_vars(self) -> List[str]:
        """C variable names following level-partition indexing.

        For each (dim, fac, level) in all_dims the variable is '{lname}_{k}'
        where lname = level.lower() with spaces removed, and k = running index
        within that level (0-based, in FF mapping order).

        Ex5: [("S",5,"SARows"),("C",2,"SARows"),("Q",2,"SACols"),("M",4,"SACols")]
             → ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
        Ex6: [("C",4,"SARows"),("M",2,"SARows"),("Q",6,"SACols"),("M",2,"SACols")]
             → ["sarows_0", "sarows_1", "sacols_0", "sacols_1"]
        """
        counter: Dict[str, int] = {}
        names = []
        for dim, fac, level in self.all_dims:
            lname = level.lower().replace(" ", "")
            k = counter.get(lname, 0)
            counter[lname] = k + 1
            names.append(f"{lname}_{k}")
        return names

    def loop_var_comments(self) -> List[str]:
        """One comment line per loop var: '// {var} → {Level}_{k} = {Dim}:{factor}'"""
        counter: Dict[str, int] = {}
        lines = []
        for dim, fac, level in self.all_dims:
            lname = level.lower().replace(" ", "")
            k = counter.get(lname, 0)
            counter[lname] = k + 1
            lines.append(f"// {lname}_{k} \u2192 {level}_{k} = {dim}:{fac}")
        return lines


def _classify_sa_dims(mapping: MappingInfo) -> SADimSpec:
    """Build SADimSpec from a FF mapping.

    Reads SARows and SACols tiling in FF mapping order (dict iteration order,
    preserved in Python 3.7+). SARows partitions come first, SACols second.
    """
    tiling = getattr(mapping, "tiling", {}) or {}
    sarows = tiling.get("SARows", {}) or {}
    sacols = tiling.get("SACols", {}) or {}

    all_dims: List[Tuple[str, int, str]] = []
    for dim, fac in sarows.items():
        all_dims.append((dim, int(fac), "SARows"))
    for dim, fac in sacols.items():
        all_dims.append((dim, int(fac), "SACols"))

    return SADimSpec(all_dims=all_dims)



def _scalar_tree(values: List[str]) -> Tuple[List[str], str]:
    """Left-leaning binary tree over any N values. Works for non-power-of-2.
    Returns (list_of_stmt_strings, final_result_variable_name).
    If N==1 returns ([], values[0]) — no temps emitted."""
    stmts: List[str] = []
    level = 0
    while len(values) > 1:
        nxt = []
        for i in range(0, len(values), 2):
            if i + 1 < len(values):
                v = f"_t{level}_{i//2}"
                stmts.append(f"DTYPE {v} = {values[i]} + {values[i+1]};")
                nxt.append(v)
            else:
                nxt.append(values[i])  # odd element passes to next level unchanged
        values, level = nxt, level + 1
    return stmts, values[0]


def _mixed_radix(dim_vars: List[Tuple[str, int]]) -> str:
    """[(var0,f0),(var1,f1),...] → 'var0*(f1*f2*...)+var1*(f2*...)+...+var_{n-1}'.
    Used for DRAM address computation only (not for acc[]/p[] subscripts)."""
    if not dim_vars:
        return "0"
    remaining = math.prod(f for _, f in dim_vars)
    parts = []
    for var, f in dim_vars:
        remaining //= f
        parts.append(f"{var}*{remaining}" if remaining > 1 else var)
    return " + ".join(parts)


# =========================
# Public API (contract)
# =========================

def _verify_sa_structure(spec: "SADimSpec", sa_text: str, name: str) -> None:
    """Verify the generated SA C text matches the mapping's PE structure.

    Raises ValueError if any check fails (blocks generation).

    Checks:
    1. DTYPE acc line exists and bracket product == spec.N_PE
    2. DTYPE p line has same bracket product as acc
    3. 'reduction' appears in text OR spec.N_red == 1
    """
    import re

    # Check 1+2: parse acc and p bracket shapes
    acc_match = re.search(r'DTYPE\s+acc(\[\d+\])+', sa_text)
    p_match   = re.search(r'DTYPE\s+p(\[\d+\])+',   sa_text)

    if not acc_match:
        raise ValueError(f"[verify_sa] {name}: 'DTYPE acc[...]' not found in generated SA code")

    acc_nums = [int(x) for x in re.findall(r'\[(\d+)\]', acc_match.group(0))]
    code_N_PE = math.prod(acc_nums)

    if code_N_PE != spec.N_PE:
        raise ValueError(
            f"[verify_sa] {name}: acc shape product={code_N_PE} != mapping N_PE={spec.N_PE} "
            f"(acc brackets: {acc_nums}, spec.all_dims={spec.all_dims})"
        )

    if not p_match:
        raise ValueError(f"[verify_sa] {name}: 'DTYPE p[...]' not found in generated SA code")

    p_nums = [int(x) for x in re.findall(r'\[(\d+)\]', p_match.group(0))]
    if p_nums != acc_nums:
        raise ValueError(
            f"[verify_sa] {name}: p shape {p_nums} != acc shape {acc_nums}"
        )

    # Check 3: reduction block present when N_red > 1
    if spec.N_red > 1 and 'reduction' not in sa_text:
        raise ValueError(
            f"[verify_sa] {name}: N_red={spec.N_red} > 1 but no 'reduction' comment in SA code"
        )

    print(f"[struct_check] {name} sa: PASS  "
          f"({spec.N_PE}-PE, N_red={spec.N_red} × N_out={spec.N_out})")


def _gen_gather_bank_c(spec: "SADimSpec", lvars: List[str],
                       N_M_sp: int, N_Q_sp: int, N_P_sp: int,
                       Ptiles: int, Qtiles: int) -> str:
    """Generate C statements for testbench gather: decompose (m,p,q) → per-level
    vars, compute bank in FF order (must match kernel write-back exactly)."""
    out_loop_vars_f = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims)
                       if d in {'M', 'P', 'Q'}]
    m_ann = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'M']
    q_ann = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'Q']
    p_ann = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'P']

    def decompose(ann, total, local_var):
        stmts = []
        remaining = total
        for i, (var, fac) in enumerate(ann):
            remaining //= fac
            if len(ann) == 1:
                stmts.append(f"int {var} = {local_var};")
            elif remaining > 1:
                stmts.append(f"int {var} = {local_var} / {remaining};")
            else:
                stmts.append(f"int {var} = {local_var} % {fac};")
        return stmts

    lines = []
    if N_M_sp > 1:
        lines.append(f"int m_local = m % {N_M_sp};")
        lines += decompose(m_ann, N_M_sp, "m_local")
    elif m_ann:
        lines.append(f"int {m_ann[0][0]} = 0;")
    if N_Q_sp > 1:
        lines.append(f"int q_local = q % {N_Q_sp};")
        lines += decompose(q_ann, N_Q_sp, "q_local")
    elif q_ann:
        lines.append(f"int {q_ann[0][0]} = 0;")
    if N_P_sp > 1:
        lines.append(f"int p_local = p % {N_P_sp};")
        lines += decompose(p_ann, N_P_sp, "p_local")
    elif p_ann:
        lines.append(f"int {p_ann[0][0]} = 0;")

    bank_expr = _mixed_radix(out_loop_vars_f)
    lines.append(f"int bank = {bank_expr};")
    lines.append(f"int cm = m / {N_M_sp};")
    lines.append(f"int cq = q / {N_Q_sp};")
    lines.append(f"int cp = p;")
    lines.append(f"int idx_b = (cm * {Ptiles} + cp) * {Qtiles} + cq;")
    return "\n          ".join(lines)


def _cpu_golden_check(out_dir: Path, name: str) -> None:
    import subprocess
    tb = out_dir / "testbench_common.c"
    for variant in ("seq", "sa"):
        src = out_dir / f"top_level_{variant}.c"
        exe = out_dir / f"cpu_{variant}"
        r = subprocess.run(
            ["gcc", "-O2", "-o", str(exe), str(src), str(tb), "-lm"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            raise RuntimeError(
                f"[cpu_check] {name} {variant}: compile FAILED\n{r.stderr}"
            )
        r = subprocess.run([str(exe)], capture_output=True, text=True)
        ok = "SUCCESS" in r.stdout
        print(f"[cpu_check] {name} {variant}: {'PASS' if ok else 'FAIL'}")
        if not ok:
            raise RuntimeError(
                f"[cpu_check] {name} {variant}: golden mismatch\n{r.stdout}"
            )


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
    spec  = _classify_sa_dims(mapping)
    seq_c = _emit_top_level_seq(mapping, bank)
    sa_c  = _emit_top_level_sa(mapping, bank)

    # Build gather bank C code for testbench (FF order, matches kernel write-back)
    lvars = spec.loop_vars()
    N_M_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'M') or 1
    N_Q_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'Q') or 1
    N_P_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'P') or 1
    d = mapping.dims
    M_d, P_d, Q_d = int(d["M"]), int(d["P"]), int(d["Q"])
    Qtiles_tb = Q_d // N_Q_sp
    Ptiles_tb = P_d // N_P_sp
    out_bank_elems_tb = (M_d // N_M_sp) * Ptiles_tb * Qtiles_tb
    gather_bank_c = _gen_gather_bank_c(spec, lvars, N_M_sp, N_Q_sp, N_P_sp,
                                       Ptiles_tb, Qtiles_tb)
    tb_c  = make_conv_testbench(mapping, bank, gather_bank_c=gather_bank_c,
                                out_banks_n=spec.N_out,
                                out_bank_elems_n=out_bank_elems_tb)
    tb_sizes = conv_tb_param_sizes(mapping, bank, spec)

    bambu_cfg = config.get("bambu", {}) or {}
    compile_sh = _emit_compile_bambu_sh(bambu_cfg, tb_sizes, n_pe=spec.N_PE)
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
    _verify_sa_structure(spec, sa_c, out_dir.name)
    _cpu_golden_check(out_dir, out_dir.name)


# =========================
# Internal types/helpers
# =========================

@dataclass(frozen=True)
class ConvBankSpec:
    """Input/weight banking only. Output banking derived from spec (SADimSpec.N_out)."""
    in_banks: int
    w_banks: int


def _infer_eyeriss_bank_spec(mapping: MappingInfo) -> ConvBankSpec:
    return ConvBankSpec(in_banks=2, w_banks=2)


def _emit_headers_and_pragmas(N_out: int) -> str:
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
    for i in range(N_out):
        lines.append(f"#pragma HLS interface port = dram_out_b{i} mode = m_axi offset = direct bundle = gmem_out{i}")
    lines.append("")
    return "\n".join(lines)


def _emit_top_signature(N_out: int) -> str:
    args = [
        "DTYPE *dram_in_b0", "DTYPE *dram_in_b1",
        "DTYPE *dram_w_b0",  "DTYPE *dram_w_b1",
    ]
    for i in range(N_out):
        args.append(f"DTYPE *dram_out_b{i}")
    return "void top_level(" + ", ".join(args) + ")"


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
    """Sequential baseline: mirrors the SA loop structure but all-nounroll, no weight preload.
    Delegates to _emit_top_level_sa with unroll=False."""
    return _emit_top_level_sa(mapping, bank, unroll=False)


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


def _emit_top_level_sa(mapping: MappingInfo, bank: ConvBankSpec, unroll: bool = True) -> str:
    """
    Generalized SA-shaped kernel (Option B):
    - Loop structure derived directly from the FF mapping hierarchy.
    - Accumulator: flat 1D DTYPE acc[spec.N_out] at FUNCTION SCOPE.
      GCC SROA at -O3 with spatial loops fully unrolled → acc becomes independent
      scalar registers (no BRAM port contention).
    - Outer temporal loops  → MemLevels above FanoutLevels (DRAM, GlobalBuffer).
                              All have #pragma GCC nounroll.
    - Acc init              → nounroll (non-spatial, must not be unrolled).
    - Inner sequential loop → MemLevels below FanoutLevels (WRegister R).
                              All have #pragma GCC nounroll.
    - When unroll=True (SA): two-phase r-loop body:
        Phase 1: preload weights into local w_tile[C_sa][S_sa][N_M_sp] with
                 fully unrolled c,s,ml loops → GCC SROA → scalar weight regs.
        Phase 2: compute with unrolled c,s,ml,ql using w_tile (local regs)
                 + AXI input reads only.
    - When unroll=False (seq): single-phase: all loops nounroll, inline weight
      AXI reads (no preload).
    - Output write: generalized over all spec.out_dims (FF order).
    Always emitted (no fallback).
    """
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))
    H = P + R - 1; W = Q + S - 1
    in_banks = bank.in_banks  # 2

    # ---- SA dim spec — computed early (needed for N_out, Ptiles, Qtiles) ----
    spec = _classify_sa_dims(mapping)
    shape_str = "".join(f"[{f}]" for _, f, _ in spec.all_dims)
    lvars = spec.loop_vars()
    zeros = "".join("[0]" for _ in spec.all_dims)

    # Derive output banking from spec (single source of truth)
    N_M_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'M') or 1
    N_Q_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'Q') or 1
    N_P_sp = math.prod(f for d, f, _ in spec.out_dims if d == 'P') or 1
    Qtiles = Q // N_Q_sp
    Ptiles = P // N_P_sp

    hdr = _emit_headers_and_pragmas(spec.N_out)
    sig = _emit_top_signature(spec.N_out)

    outer_mem, fanout, inner_mem = _classify_levels(mapping)
    tiling = mapping.tiling

    # ---- Outer temporal loops ----
    def _level_short(lvl):
        s = {"DRAM": "dram", "GlobalBuffer": "gb", "WRegister": "wr", "InRegister": "ir"}
        return s.get(lvl, lvl.lower()[:3])

    outer_q_terms: list = []
    outer_p_terms: list = []
    outer_m_terms: list = []

    outer_loop_specs = []  # [(varname, factor, comment)]
    for lvl in outer_mem:
        til = tiling.get(lvl, {})
        abbr = _level_short(lvl)
        for dim, fac in til.items():
            fac = int(fac)
            vname = f"{dim.lower()}_{abbr}"
            outer_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "Q": outer_q_terms.append((vname, fac))
            if dim == "P": outer_p_terms.append((vname, fac))
            if dim == "M": outer_m_terms.append((vname, fac))

    def _composite_tile_expr(terms):
        if not terms:
            return None, 1
        total = 1
        for _, f in terms:
            total *= f
        parts = []
        remaining = total
        for vname, f in terms:
            remaining //= f
            parts.append(vname if remaining == 1 else f"{vname} * {remaining}")
        expr = " + ".join(parts)
        return (f"({expr})" if len(parts) > 1 else expr), total

    outer_p_var, outer_p_factor = _composite_tile_expr(outer_p_terms)
    outer_q_var, outer_q_factor = _composite_tile_expr(outer_q_terms)
    outer_m_var, outer_m_factor = _composite_tile_expr(outer_m_terms)

    # Synthetic outer M tile loop
    M_tiles = (M + N_M_sp - 1) // N_M_sp
    if M_tiles > 1 and outer_m_var is None:
        outer_m_var = "m_tile"
        outer_loop_specs.insert(0, ("m_tile", M_tiles, "M tile (synthetic outer loop)"))

    # ---- Inner sequential loops (WRegister / InRegister) ----
    inner_loop_specs = []  # [(varname, factor, comment)]
    inner_r_var = None
    inner_c_var = None
    inner_c_factor = 1
    for lvl in inner_mem:
        til = tiling.get(lvl, {})
        for dim, fac in til.items():
            fac = int(fac)
            vname = dim.lower()
            if dim == "C":
                vname = "c_seq"
                inner_c_var = "c_seq"
                inner_c_factor = fac
            inner_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "R": inner_r_var = vname

    # ---- SARows (unrolled reduction dims: C, S) ----
    sarows_til = tiling.get("SARows", {}) or {}
    C_sa = int(sarows_til.get("C", 1))
    S_sa = int(sarows_til.get("S", 1))

    # ---- Build code ----
    kind = "SA (weight-preload)" if unroll else "seq (all-nounroll)"
    code = [hdr, sig, "{"]
    code.append(f"    // {kind} Eyeriss CONV -- loop structure mirrors FF mapping hierarchy")
    code.append(f"    const int M={M}, P={P}, Q={Q}, C={C}, R={R}, S={S};")
    code.append(f"    const int H={H}, W={W};")
    code.append(f"    const int Ptiles={Ptiles}, Qtiles={Qtiles};")
    code.append(f"    const int in_banks={in_banks};")
    code.append("")
    if unroll:
        for comment in spec.loop_var_comments():
            code.append(f"    {comment}")
        code.append(f"    // {spec.N_PE} PE accumulators: acc{shape_str}")
        code.append(f"    DTYPE acc{shape_str};")
    else:
        # Flat accumulator for sequential path — GCC SROA at -O3 → scalar regs
        code.append(f"    // Accumulator: flat 1D at function scope → GCC SROA → {spec.N_out} scalar regs")
        code.append(f"    DTYPE acc[{spec.N_out}];")
    code.append("")

    indent = "    "

    # -- Outer temporal loops (all nounroll — temporal, not spatial) --
    for vname, fac, cmt in outer_loop_specs:
        code.append(f"{indent}// {cmt}")
        code.append(f"{indent}#pragma GCC nounroll")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    # -- Accumulator init (nounroll — non-spatial init) --
    if unroll:
        code.append(f"{indent}// Zero {spec.N_PE} PE accumulators (nounroll — non-spatial init)")
        cur_indent = indent
        for var, (_, fac, _) in zip(lvars, spec.all_dims):
            code.append(f"{cur_indent}#pragma GCC nounroll")
            code.append(f"{cur_indent}for (int {var} = 0; {var} < {fac}; ++{var}) {{")
            cur_indent += "  "
        inner_acc_ref = "".join(f"[{v}]" for v in lvars)
        code.append(f"{cur_indent}acc{inner_acc_ref} = 0.0f;")
        for _ in spec.all_dims:
            cur_indent = cur_indent[:-2]
            code.append(f"{cur_indent}}}")
        # acc_flat removed: write-back now reads from reduced[] (Phase 5)
    else:
        code.append(f"{indent}// Zero accumulator (nounroll — non-spatial init)")
        code.append(f"{indent}#pragma GCC nounroll")
        code.append(f"{indent}for (int _i = 0; _i < {spec.N_out}; ++_i) acc[_i] = 0.0f;")
    code.append("")

    # -- Inner sequential loops (WRegister C, R, etc.) — all nounroll --
    for vname, fac, cmt in inner_loop_specs:
        code.append(f"{indent}// {cmt} (sequential)")
        code.append(f"{indent}#pragma GCC nounroll")
        code.append(f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{")
        indent += "  "

    if inner_r_var:
        r_var = inner_r_var
    else:
        r_var = "r"
        code.append(f"{indent}int r = 0;  // R=1 or no inner sequential R loop")

    # Helper: emit the c_bank/c_blk/q_base setup lines for either preload or compute
    def _emit_c_setup(ind, need_in_base=True, need_q_base=True):
        if inner_c_var:
            code.append(f"{ind}  int c_global = {inner_c_var} * {C_sa} + c;")
            code.append(f"{ind}  int c_bank = c_global & 1;")
            code.append(f"{ind}  int c_blk  = c_global >> 1;")
        else:
            code.append(f"{ind}  int c_bank = c & 1;")
            code.append(f"{ind}  int c_blk  = c >> 1;")
        if need_in_base:
            code.append(f"{ind}  int in_c_base = c_blk * (H * W);")
        if need_q_base:
            if outer_q_var:
                code.append(f"{ind}  int q_base = {outer_q_var} * {N_Q_sp};")
            else:
                code.append(f"{ind}  int q_base = 0;")

    def _w_idx_expr(r_v, s_v, ml_v=None):
        mt = f"({outer_m_var} * {N_M_sp} + {ml_v})" if outer_m_var else (ml_v or "ml")
        return f"({mt} * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + {r_v} * S + {s_v}"

    if unroll:
        # ---- Precompute address groupings from spec ----
        non_q_pairs = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d != 'Q']
        c_sa_pairs  = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'C']
        s_sa_pairs  = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'S']
        m_sa_pairs  = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'M']
        q_sa_pairs  = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'Q']

        C_sa_total = math.prod(f for _, f in c_sa_pairs) if c_sa_pairs else 1
        N_M_sp     = math.prod(f for _, f in m_sa_pairs) if m_sa_pairs else 1
        N_Q_sp     = math.prod(f for _, f in q_sa_pairs) if q_sa_pairs else 1

        c_flat_expr = _mixed_radix(c_sa_pairs) if c_sa_pairs else "0"
        s_flat_expr = _mixed_radix(s_sa_pairs) if s_sa_pairs else "0"
        q_flat_expr = _mixed_radix(q_sa_pairs) if q_sa_pairs else "0"
        m_flat_expr = _mixed_radix(m_sa_pairs) if m_sa_pairs else "0"

        if inner_c_var:
            c_global_expr = f"({inner_c_var} * {C_sa_total} + ({c_flat_expr}))"
        else:
            c_global_expr = f"({c_flat_expr})"

        if outer_m_var:
            m_total_expr_sa = f"({outer_m_var} * {N_M_sp} + ({m_flat_expr}))"
        else:
            m_total_expr_sa = f"({m_flat_expr})"

        w_shape   = "".join(f"[{f}]" for _, f in non_q_pairs)
        w_idx_str = "".join(f"[{v}]" for v, _ in non_q_pairs)
        n_w_elems = math.prod(f for _, f in non_q_pairs) if non_q_pairs else 1
        p_idx_str = "".join(f"[{v}]" for v in lvars)

        # ---- Phase 1: preload weights (non-Q SA dims only) ----
        code.append(f"{indent}// ---- Phase 1: preload weights — {n_w_elems} elems, no Q loop ----")
        code.append(f"{indent}// w_tile{w_shape}: level-indexed, Q absent (weight is Q-independent)")
        code.append(f"{indent}DTYPE w_tile{w_shape};")
        pre_ind = indent
        for v, f in non_q_pairs:
            code.append(f"{pre_ind}#pragma GCC unroll {f}")
            code.append(f"{pre_ind}for (int {v} = 0; {v} < {f}; ++{v}) {{")
            pre_ind += "  "
        code.append(f"{pre_ind}int c_global = {c_global_expr};")
        code.append(f"{pre_ind}int c_bank = c_global & 1;")
        code.append(f"{pre_ind}int c_blk  = c_global >> 1;")
        code.append(f"{pre_ind}int w_idx = ({m_total_expr_sa} * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + {r_var} * S + {s_flat_expr};")
        code.append(f"{pre_ind}w_tile{w_idx_str} = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];")
        for v, _ in reversed(non_q_pairs):
            pre_ind = pre_ind[:-2]
            code.append(f"{pre_ind}}}  // {v} (preload)")
        code.append("")

        # ---- Phase 2a: multiply — N_PE independent products ----
        code.append(f"{indent}// ---- Phase 2a: multiply — {spec.N_PE} independent products ----")
        code.append(f"{indent}// p{shape_str}: GCC SROA → {spec.N_PE} scalar float regs")
        code.append(f"{indent}DTYPE p{shape_str};")
        if outer_q_var:
            code.append(f"{indent}int q_base = {outer_q_var} * {N_Q_sp};")
        else:
            code.append(f"{indent}int q_base = 0;")
        p2a_ind = indent
        for v, (d, f, _) in zip(lvars, spec.all_dims):
            code.append(f"{p2a_ind}#pragma GCC unroll {f}")
            code.append(f"{p2a_ind}for (int {v} = 0; {v} < {f}; ++{v}) {{  // {d}:{f}")
            p2a_ind += "  "
        code.append(f"{p2a_ind}int c_global = {c_global_expr};")
        code.append(f"{p2a_ind}int c_bank = c_global & 1;")
        code.append(f"{p2a_ind}int c_blk  = c_global >> 1;")
        code.append(f"{p2a_ind}int in_c_base = c_blk * (H * W);")
        if outer_p_var:
            p_row_expr_sa = f"({outer_p_var} + {r_var})"
        else:
            p_row_expr_sa = f"{r_var}"
        code.append(f"{p2a_ind}int in_row_base = in_c_base + {p_row_expr_sa} * W;")
        code.append(f"{p2a_ind}int in_col = q_base + {q_flat_expr} + {s_flat_expr};")
        code.append(f"{p2a_ind}DTYPE wv = w_tile{w_idx_str};")
        code.append(f"{p2a_ind}DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]")
        code.append(f"{p2a_ind}                        : dram_in_b1[in_row_base + in_col];")
        code.append(f"{p2a_ind}p{p_idx_str} = wv * inv;")
        for v, (d, f, _) in reversed(list(zip(lvars, spec.all_dims))):
            p2a_ind = p2a_ind[:-2]
            code.append(f"{p2a_ind}}}  // {v} ({d}:{f})")
        code.append("")

        # ---- Phase 2b: accumulate — N_PE independent, no chain ----
        code.append(f"{indent}// ---- Phase 2b: accumulate — {spec.N_PE} independent, no RAW chain ----")
        p2b_ind = indent
        for v, (d, f, _) in zip(lvars, spec.all_dims):
            code.append(f"{p2b_ind}#pragma GCC unroll {f}")
            code.append(f"{p2b_ind}for (int {v} = 0; {v} < {f}; ++{v}) {{")
            p2b_ind += "  "
        code.append(f"{p2b_ind}acc{p_idx_str} += p{p_idx_str};")
        for v, (d, f, _) in reversed(list(zip(lvars, spec.all_dims))):
            p2b_ind = p2b_ind[:-2]
            code.append(f"{p2b_ind}}}  // {v}")
        code.append("")

    else:
        # ---- Seq compute body (unchanged — all nounroll, inline weight read) ----
        c_pragma  = "#pragma GCC nounroll"
        s_pragma  = "#pragma GCC nounroll"
        ml_pragma = "#pragma GCC nounroll"
        ql_pragma = "#pragma GCC nounroll"

        # SEQ: derive out_loop_vars from spec (FF order, same var names as SA)
        out_loop_vars_f_seq = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims)
                               if d in {'M', 'P', 'Q'}]
        bank_expr_seq = _mixed_radix(out_loop_vars_f_seq)
        m_sa_pairs_seq = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'M']
        q_sa_pairs_seq = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims) if d == 'Q']
        m_flat_seq = _mixed_radix(m_sa_pairs_seq) if m_sa_pairs_seq else "0"
        q_flat_seq = _mixed_radix(q_sa_pairs_seq) if q_sa_pairs_seq else "0"
        N_M_sp_seq = math.prod(f for _, f in m_sa_pairs_seq) if m_sa_pairs_seq else 1
        if outer_m_var:
            m_total_seq = f"({outer_m_var} * {N_M_sp_seq} + ({m_flat_seq}))"
        else:
            m_total_seq = m_flat_seq if m_flat_seq != "0" else "0"

        code.append(f"{indent}// SARows C:{C_sa} -- sequential (reduction)")
        code.append(f"{indent}{c_pragma}")
        code.append(f"{indent}for (int c = 0; c < {C_sa}; ++c) {{")
        _emit_c_setup(indent, need_in_base=True, need_q_base=True)
        code.append("")
        code.append(f"{indent}  // SARows S:{S_sa}")
        code.append(f"{indent}  {s_pragma}")
        code.append(f"{indent}  for (int s = 0; s < {S_sa}; ++s) {{")
        # Out dims loops in FF order (nounroll for SEQ)
        seq_ind = indent + "    "
        for (var, fac), (dim, _, _) in zip(out_loop_vars_f_seq, spec.out_dims):
            code.append(f"{seq_ind}#pragma GCC nounroll")
            code.append(f"{seq_ind}for (int {var} = 0; {var} < {fac}; ++{var}) {{  // {dim}:{fac}")
            seq_ind += "  "
        code.append(f"{seq_ind}int w_idx = (({m_total_seq}) * ((C + in_banks - 1) / in_banks) + c_blk) * (R * S) + {r_var} * S + s;")
        code.append(f"{seq_ind}DTYPE wv = (c_bank==0) ? dram_w_b0[w_idx] : dram_w_b1[w_idx];")
        if outer_p_var:
            p_row_expr_seq = f"({outer_p_var} + {r_var})"
        else:
            p_row_expr_seq = f"{r_var}"
        code.append(f"{seq_ind}int in_row_base = in_c_base + {p_row_expr_seq} * W;")
        code.append(f"{seq_ind}int in_col = q_base + {q_flat_seq} + s;")
        code.append(f"{seq_ind}DTYPE inv = (c_bank==0) ? dram_in_b0[in_row_base + in_col]")
        code.append(f"{seq_ind}                        : dram_in_b1[in_row_base + in_col];")
        code.append(f"{seq_ind}acc[{bank_expr_seq}] += wv * inv;")
        for (var, fac), (dim, _, _) in reversed(list(zip(out_loop_vars_f_seq, spec.out_dims))):
            seq_ind = seq_ind[:-2]
            code.append(f"{seq_ind}}}  // {var} ({dim}:{fac})")
        code.append(f"{indent}  }}  // s")
        code.append(f"{indent}}}  // c")
        code.append("")

    # Close inner sequential loops
    for _ in inner_loop_specs:
        indent = indent[:-2]
        code.append(f"{indent}}}  // inner seq")
    code.append("")

    # -- Reduction block (SA path only) --
    if unroll:
        out_loop_vars = [v for v, (d, _, __) in zip(lvars, spec.all_dims) if d in {'M', 'P', 'Q'}]
        red_positions = [i for i, (d, _, __) in enumerate(spec.all_dims) if d not in {'M', 'P', 'Q'}]
        out_positions = [i for i, (d, _, __) in enumerate(spec.all_dims) if d in {'M', 'P', 'Q'}]
        red_factors   = [spec.all_dims[i][1] for i in red_positions]

        reduced_shape = "".join(f"[{f}]" for _, f, _ in spec.out_dims)
        out_idx_str   = "".join(f"[{v}]" for v in out_loop_vars)

        code.append(f"{indent}// ---- reduction: {spec.N_PE} acc → {spec.N_out} outputs ({spec.N_red} inputs each) ----")
        code.append(f"{indent}DTYPE reduced{reduced_shape};")
        red_ind = indent
        for var, (dim, fac, _) in zip(out_loop_vars, spec.out_dims):
            code.append(f"{red_ind}#pragma GCC unroll {fac}")
            code.append(f"{red_ind}for (int {var} = 0; {var} < {fac}; ++{var}) {{")
            red_ind += "  "

        # Build scalar tree input list: enumerate all reduction index combinations
        values = []
        for combo in iprod(*[range(f) for f in red_factors]):
            idx = ["?"] * len(spec.all_dims)
            for k, i in enumerate(red_positions):
                idx[i] = str(combo[k])
            for k, i in enumerate(out_positions):
                idx[i] = out_loop_vars[k]
            values.append(f"acc{''.join(f'[{x}]' for x in idx)}")

        stmts, final = _scalar_tree(values)
        for s in stmts:
            code.append(f"{red_ind}{s}")
        code.append(f"{red_ind}reduced{out_idx_str} = {final};")

        for var, (dim, fac, _) in reversed(list(zip(out_loop_vars, spec.out_dims))):
            red_ind = red_ind[:-2]
            code.append(f"{red_ind}}}  // {var} (reduction)")
        code.append("")

    # -- Output write --
    code.append(f"{indent}// OutRegister: write acc to banked output ports")
    if unroll:
        # SA path: FF-order out_loop_vars, direct reduced[] subscript — no ml/ql decomposition
        out_loop_vars_f = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims)
                           if d in {'M', 'P', 'Q'}]
        bank_expr = _mixed_radix(out_loop_vars_f)
        cm_expr = f"{outer_m_var}" if outer_m_var else "0"
        cq_expr = f"{outer_q_var}" if outer_q_var else "0"
        cp_expr = f"{outer_p_var}" if outer_p_var else "0"
        wb_ind = indent
        for (var, fac), (dim, _, _) in zip(out_loop_vars_f, spec.out_dims):
            code.append(f"{wb_ind}#pragma GCC unroll {fac}")
            code.append(f"{wb_ind}for (int {var} = 0; {var} < {fac}; ++{var}) {{")
            wb_ind += "  "
        code.append(f"{wb_ind}int out_bank = {bank_expr};")
        code.append(f"{wb_ind}int cm = {cm_expr};")
        code.append(f"{wb_ind}int cp = {cp_expr};")
        code.append(f"{wb_ind}int cq = {cq_expr};")
        code.append(f"{wb_ind}int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;")
        out_idx = "".join(f"[{v}]" for v, _ in out_loop_vars_f)
        code.append(f"{wb_ind}DTYPE v = reduced{out_idx};")
        code.append(_emit_out_store_switch_fixed("out_bank", spec.N_out,
                                                 "out_idx_b", "v", wb_ind))
        for _ in out_loop_vars_f:
            wb_ind = wb_ind[:-2]
            code.append(f"{wb_ind}}}")
    else:
        # SEQ path: FF-order out_loop_vars, direct acc[bank_expr] — no ml/ql
        out_loop_vars_f_wb = [(v, f) for v, (d, f, _) in zip(lvars, spec.all_dims)
                              if d in {'M', 'P', 'Q'}]
        bank_expr_wb = _mixed_radix(out_loop_vars_f_wb)
        cm_expr = f"{outer_m_var}" if outer_m_var else "0"
        cq_expr = f"{outer_q_var}" if outer_q_var else "0"
        cp_expr = f"{outer_p_var}" if outer_p_var else "0"
        wb_ind = indent
        for (var, fac), (dim, _, _) in zip(out_loop_vars_f_wb, spec.out_dims):
            code.append(f"{wb_ind}#pragma GCC nounroll")
            code.append(f"{wb_ind}for (int {var} = 0; {var} < {fac}; ++{var}) {{")
            wb_ind += "  "
        code.append(f"{wb_ind}int out_bank = {bank_expr_wb};")
        code.append(f"{wb_ind}int cm = {cm_expr};")
        code.append(f"{wb_ind}int cp = {cp_expr};")
        code.append(f"{wb_ind}int cq = {cq_expr};")
        code.append(f"{wb_ind}int out_idx_b = (cm * Ptiles + cp) * Qtiles + cq;")
        code.append(f"{wb_ind}DTYPE v = acc[{bank_expr_wb}];")
        code.append(_emit_out_store_switch_fixed("out_bank", spec.N_out,
                                                 "out_idx_b", "v", wb_ind))
        for _ in out_loop_vars_f_wb:
            wb_ind = wb_ind[:-2]
            code.append(f"{wb_ind}}}")

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
    float_mul_val is '' if no -C=__float_mule8m23b_127nih=N flag is present."""
    import re
    pat = re.compile(r"^-C=__float_mule8m23b_127nih=(\d+)$")
    val = ""
    other = []
    for a in extra_args:
        m = pat.match(a.strip())
        if m:
            val = m.group(1)
        else:
            other.append(a)
    return val, other


def _emit_compile_bambu_sh(bambu_cfg: Dict[str, Any], tb_sizes: Dict[str, int], n_pe: int = 0) -> str:
    """
    A generalistic compile script:
      ./compile_bambu.sh [top_file.c [N_MUL [N_ADD]]]
    Defaults to top_level_sa.c if top omitted; N_MUL/N_ADD override float-op counts.
    N_MUL_DEFAULT and N_ADD_DEFAULT both equal n_pe (one multiplier and one adder per PE).
    """
    clock = bambu_cfg.get("clock_period", 5)
    compiler = bambu_cfg.get("compiler", "I386_GCC8")
    opt = bambu_cfg.get("opt_level", 3)
    v = bambu_cfg.get("v", 4)
    extra_args = bambu_cfg.get("extra_args", []) or []

    float_mul_default, other_args = _extract_float_mul(extra_args)
    n_pe_str = str(n_pe) if n_pe else ""

    tb_flags = ""
    for name, sz in tb_sizes.items():
        tb_flags += f"  --tb-param-size={name}:{sz} \\\n"

    other_flags = ""
    for a in other_args:
        other_flags += f"  {a} \\\n"

    return f"""#!/bin/bash
set -euo pipefail

TOP="${{1:-top_level_sa.c}}"
TB="$(dirname "$0")/testbench_common.c"
N_MUL_DEFAULT="{float_mul_default}"
N_MUL="${{2:-$N_MUL_DEFAULT}}"
N_ADD_DEFAULT="{n_pe_str}"
N_ADD="${{3:-$N_ADD_DEFAULT}}"

FLOAT_MUL_FLAG=""
if [[ -n "$N_MUL" ]]; then
  FLOAT_MUL_FLAG="-C=__float_mule8m23b_127nih=$N_MUL"
fi
FLOAT_ADD_FLAG=""
if [[ -n "$N_ADD" ]]; then
  FLOAT_ADD_FLAG="-C=__float_adde8m23b_127nih=$N_ADD"
fi

bambu "$TOP" \\
  --top-fname=top_level \\
  --generate-interface=INFER \\
  --compiler={compiler} \\
  --clock-period={clock} \\
  -O{opt} -v{v} \\
  --generate-tb="$TB" \\
{tb_flags}{other_flags}${{FLOAT_MUL_FLAG:+$FLOAT_MUL_FLAG}} \\
  ${{FLOAT_ADD_FLAG:+$FLOAT_ADD_FLAG}} \\
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

# Optional first argument: N_MUL overrides -C=__float_mule8m23b_127nih=N
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

  local nmul_tag="n${{N_MUL:-1}}"
  local outdir="${{BAMBU_OUT_ROOT}}/${{tag}}/${{nmul_tag}}"
  local log="${{outdir}}/bambu_${{tag}}_${{nmul_tag}}.log"

  local float_mul_flag=""
  if [[ -n "$N_MUL" ]]; then
    float_mul_flag="-C=__float_mule8m23b_127nih=$N_MUL"
  fi

  rm -rf "${{outdir}}"
  mkdir -p "${{outdir}}"

  # Run Bambu inside its output directory so ALL generated files land there,
  # and write the log there too.
  (
    cd "${{outdir}}"
    bambu "../../../${{top}}" \\
      --top-fname=top_level \\
      --generate-interface=INFER \\
      --compiler={compiler} \\
      --clock-period={clock} \\
      -O{opt} -v{v} \\
      --generate-tb="../../../${{TB}}" \\
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
echo "  $BAMBU_OUT_ROOT/seq/n${{N_MUL:-1}}/bambu_seq_n${{N_MUL:-1}}.log"
echo "  $BAMBU_OUT_ROOT/sa/n${{N_MUL:-1}}/bambu_sa_n${{N_MUL:-1}}.log"
echo "Bambu outputs:"
echo "  $BAMBU_OUT_ROOT/seq/n${{N_MUL:-1}}"
echo "  $BAMBU_OUT_ROOT/sa/n${{N_MUL:-1}}"
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