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
                v = f"partial_sum_{level}_{i//2}"
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
    acc_match = re.search(r'DTYPE\s+accumulator(\[\d+\])+', sa_text)
    p_match   = re.search(r'DTYPE\s+product(\[\d+\])+',   sa_text)

    if not acc_match:
        raise ValueError(f"[verify_sa] {name}: 'DTYPE accumulator[...]' not found in generated SA code")

    acc_nums = [int(x) for x in re.findall(r'\[(\d+)\]', acc_match.group(0))]
    code_N_PE = math.prod(acc_nums)

    if code_N_PE != spec.N_PE:
        raise ValueError(
            f"[verify_sa] {name}: accumulator shape product={code_N_PE} != mapping N_PE={spec.N_PE} "
            f"(accumulator brackets: {acc_nums}, spec.all_dims={spec.all_dims})"
        )

    if not p_match:
        raise ValueError(f"[verify_sa] {name}: 'DTYPE product[...]' not found in generated SA code")

    p_nums = [int(x) for x in re.findall(r'\[(\d+)\]', p_match.group(0))]
    if p_nums != acc_nums:
        raise ValueError(
            f"[verify_sa] {name}: product shape {p_nums} != accumulator shape {acc_nums}"
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
        lines.append(f"int local_filter_index = m % {N_M_sp};")
        lines += decompose(m_ann, N_M_sp, "local_filter_index")
    elif m_ann:
        lines.append(f"int {m_ann[0][0]} = 0;")
    if N_Q_sp > 1:
        lines.append(f"int local_col_index = q % {N_Q_sp};")
        lines += decompose(q_ann, N_Q_sp, "local_col_index")
    elif q_ann:
        lines.append(f"int {q_ann[0][0]} = 0;")
    if N_P_sp > 1:
        lines.append(f"int local_row_index = p % {N_P_sp};")
        lines += decompose(p_ann, N_P_sp, "local_row_index")
    elif p_ann:
        lines.append(f"int {p_ann[0][0]} = 0;")

    bank_expr = _mixed_radix(out_loop_vars_f)
    lines.append(f"int output_bank_index = {bank_expr};")
    lines.append(f"int output_filter_tile = m / {N_M_sp};")
    lines.append(f"int output_col_tile = q / {N_Q_sp};")
    lines.append(f"int output_row_tile = p;")
    lines.append(f"int output_dram_offset = (output_filter_tile * {Ptiles} + output_row_tile) * {Qtiles} + output_col_tile;")
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


def _level_short(lvl: str) -> str:
    return lvl.lower().replace(" ", "")


def _composite_tile_expr(terms: list) -> Tuple:
    """[(vname, fac), ...] → (composite_expr_or_None, total_factor)."""
    if not terms:
        return None, 1
    total = math.prod(f for _, f in terms)
    remaining = total
    parts = []
    for vname, f in terms:
        remaining //= f
        parts.append(vname if remaining == 1 else f"{vname} * {remaining}")
    expr = " + ".join(parts)
    return (f"({expr})" if len(parts) > 1 else expr), total


@dataclass
class _SACtx:
    """Pre-computed loop-structure facts, threaded through SA/SEQ kernel emitters."""
    M: int; P: int; Q: int; C: int; R: int; S: int; H: int; W: int
    in_banks: int
    spec: SADimSpec
    lvars: List[str]
    N_M_sp: int; N_Q_sp: int; N_P_sp: int
    Ptiles: int; Qtiles: int
    outer_out_specs: List       # [(vname, fac, comment, dim)]  output-dim outer loops
    outer_red_specs: List       # [(vname, fac, comment, dim)]  reduction-dim outer loops
    outer_q_var: Any; outer_q_factor: int
    outer_p_var: Any; outer_p_factor: int
    outer_m_var: Any; outer_m_factor: int
    outer_c_var: Any; outer_c_factor: int
    outer_s_var: Any; outer_s_factor: int
    inner_loop_specs: List      # [(vname, fac, comment)]
    inner_r_var: Any
    inner_c_var: Any
    inner_c_factor: int
    C_sa: int; S_sa: int


def _build_sa_ctx(mapping: MappingInfo, bank: ConvBankSpec) -> _SACtx:
    """Derive all loop-structure facts from the mapping; return as _SACtx."""
    d = mapping.dims
    M = int(d["M"]); P = int(d["P"]); Q = int(d["Q"])
    C = int(d.get("C", 1)); R = int(d.get("R", 1)); S = int(d.get("S", 1))
    H = P + R - 1; W = Q + S - 1

    spec  = _classify_sa_dims(mapping)
    lvars = spec.loop_vars()

    N_M_sp = math.prod(f for dm, f, _ in spec.out_dims if dm == 'M') or 1
    N_Q_sp = math.prod(f for dm, f, _ in spec.out_dims if dm == 'Q') or 1
    N_P_sp = math.prod(f for dm, f, _ in spec.out_dims if dm == 'P') or 1
    Qtiles = Q // N_Q_sp
    Ptiles = P // N_P_sp

    outer_mem, _fanout, inner_mem = _classify_levels(mapping)
    tiling = mapping.tiling
    _OUTPUT_DIMS = {'M', 'P', 'Q'}

    outer_q_terms: list = []; outer_p_terms: list = []; outer_m_terms: list = []
    outer_c_terms: list = []; outer_s_terms: list = []
    level_ctr: Dict[str, int] = {}
    outer_loop_specs: list = []

    for lvl in outer_mem:
        abbr = _level_short(lvl)
        for dim, fac in (tiling.get(lvl, {}) or {}).items():
            fac = int(fac)
            k = level_ctr.get(abbr, 0); level_ctr[abbr] = k + 1
            vname = f"{abbr}_{k}"
            outer_loop_specs.append((vname, fac, f"{lvl}_{k} = {dim}:{fac}", dim))
            if dim == "Q": outer_q_terms.append((vname, fac))
            if dim == "P": outer_p_terms.append((vname, fac))
            if dim == "M": outer_m_terms.append((vname, fac))
            if dim == "C": outer_c_terms.append((vname, fac))
            if dim == "S": outer_s_terms.append((vname, fac))

    # OutRegister output dims (M,P,Q) act as additional output tile loops nested just
    # outside the zero-init. This covers e.g. OutRegister M:10 in ex7-class mappings
    # that have both DRAM M tiles and OutRegister M tiles simultaneously.
    for dim, fac in (tiling.get("OutRegister", {}) or {}).items():
        fac = int(fac)
        if dim in _OUTPUT_DIMS:
            k = level_ctr.get("outregister", 0); level_ctr["outregister"] = k + 1
            vname = f"outregister_{k}"
            outer_loop_specs.append((vname, fac, f"OutRegister_{k} = {dim}:{fac}", dim))
            if dim == "Q": outer_q_terms.append((vname, fac))
            if dim == "P": outer_p_terms.append((vname, fac))
            if dim == "M": outer_m_terms.append((vname, fac))

    outer_p_var, outer_p_factor = _composite_tile_expr(outer_p_terms)
    outer_q_var, outer_q_factor = _composite_tile_expr(outer_q_terms)
    outer_m_var, outer_m_factor = _composite_tile_expr(outer_m_terms)
    outer_c_var, outer_c_factor = _composite_tile_expr(outer_c_terms)
    outer_s_var, outer_s_factor = _composite_tile_expr(outer_s_terms)

    M_tiles = (M + N_M_sp - 1) // N_M_sp
    if M_tiles > 1 and outer_m_var is None:
        outer_m_var = "m_tile"
        outer_loop_specs.insert(0, ("m_tile", M_tiles, "M tile (synthetic outer loop)", "M"))

    outer_out_specs = [(v, f, c, dm) for v, f, c, dm in outer_loop_specs if dm in _OUTPUT_DIMS]
    outer_red_specs = [(v, f, c, dm) for v, f, c, dm in outer_loop_specs if dm not in _OUTPUT_DIMS]

    inner_loop_specs: list = []
    inner_r_var = None; inner_c_var = None; inner_c_factor = 1
    inner_level_ctr: Dict[str, int] = {}
    for lvl in inner_mem:
        lvl_name = lvl.lower().replace(" ", "")
        for dim, fac in (tiling.get(lvl, {}) or {}).items():
            fac = int(fac)
            k = inner_level_ctr.get(lvl_name, 0); inner_level_ctr[lvl_name] = k + 1
            vname = f"{lvl_name}_{k}"
            if dim == "C": inner_c_var = vname; inner_c_factor = fac
            inner_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))
            if dim == "R": inner_r_var = vname

    sarows_til = tiling.get("SARows", {}) or {}
    C_sa = int(sarows_til.get("C", 1))
    S_sa = int(sarows_til.get("S", 1))

    return _SACtx(
        M=M, P=P, Q=Q, C=C, R=R, S=S, H=H, W=W,
        in_banks=bank.in_banks,
        spec=spec, lvars=lvars,
        N_M_sp=N_M_sp, N_Q_sp=N_Q_sp, N_P_sp=N_P_sp,
        Ptiles=Ptiles, Qtiles=Qtiles,
        outer_out_specs=outer_out_specs, outer_red_specs=outer_red_specs,
        outer_q_var=outer_q_var, outer_q_factor=outer_q_factor,
        outer_p_var=outer_p_var, outer_p_factor=outer_p_factor,
        outer_m_var=outer_m_var, outer_m_factor=outer_m_factor,
        outer_c_var=outer_c_var, outer_c_factor=outer_c_factor,
        outer_s_var=outer_s_var, outer_s_factor=outer_s_factor,
        inner_loop_specs=inner_loop_specs,
        inner_r_var=inner_r_var, inner_c_var=inner_c_var, inner_c_factor=inner_c_factor,
        C_sa=C_sa, S_sa=S_sa,
    )


def _emit_acc_decl(ctx: _SACtx, unroll: bool) -> List[str]:
    """Accumulator declaration (function-scope, before outer loops)."""
    spec = ctx.spec
    shape_str = "".join(f"[{f}]" for _, f, _ in spec.all_dims)
    if unroll:
        lines = [f"    {c}" for c in spec.loop_var_comments()]
        lines.append(f"    // {spec.N_PE} PE accumulators: accumulator{shape_str}")
        lines.append(f"    DTYPE accumulator{shape_str};")
    else:
        lines = [
            f"    // Accumulator: flat 1D at function scope → GCC SROA → {spec.N_out} scalar regs",
            f"    DTYPE accumulator[{spec.N_out}];",
        ]
    return lines


def _emit_acc_init(ctx: _SACtx, unroll: bool, indent: str) -> List[str]:
    """Zero-init block, emitted inside the outer OUTPUT loops."""
    spec = ctx.spec; lvars = ctx.lvars
    lines = []
    if unroll:
        lines.append(f"{indent}// Zero {spec.N_PE} PE accumulators (nounroll — non-spatial init)")
        cur = indent
        for var, (_, fac, _) in zip(lvars, spec.all_dims):
            lines += [f"{cur}#pragma GCC nounroll",
                      f"{cur}for (int {var} = 0; {var} < {fac}; ++{var}) {{"]
            cur += "  "
        lines.append(f"{cur}accumulator{''.join(f'[{v}]' for v in lvars)} = 0.0f;")
        for _ in spec.all_dims:
            cur = cur[:-2]; lines.append(f"{cur}}}")
    else:
        lines += [
            f"{indent}// Zero accumulator (nounroll — non-spatial init)",
            f"{indent}#pragma GCC nounroll",
            f"{indent}for (int accumulator_dim_index = 0; accumulator_dim_index < {spec.N_out}; ++accumulator_dim_index) accumulator[accumulator_dim_index] = 0.0f;",
        ]
    return lines


def _emit_sa_compute_body(ctx: _SACtx, r_var: str, indent: str) -> List[str]:
    """Phase 1 (weight preload) + Phase 2a (multiply) + Phase 2b (accumulate)."""
    spec = ctx.spec; lvars = ctx.lvars
    lines = []

    c_sa_pairs  = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'C']
    s_sa_pairs  = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'S']
    m_sa_pairs  = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'M']
    q_sa_pairs  = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'Q']
    non_q_pairs = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm != 'Q']

    C_sa_total = math.prod(f for _, f in c_sa_pairs) if c_sa_pairs else 1
    N_M_sp     = math.prod(f for _, f in m_sa_pairs) if m_sa_pairs else 1
    N_Q_sp     = math.prod(f for _, f in q_sa_pairs) if q_sa_pairs else 1

    c_flat = _mixed_radix(c_sa_pairs) if c_sa_pairs else "0"
    s_flat = _mixed_radix(s_sa_pairs) if s_sa_pairs else "0"
    q_flat = _mixed_radix(q_sa_pairs) if q_sa_pairs else "0"
    m_flat = _mixed_radix(m_sa_pairs) if m_sa_pairs else "0"

    c_inner = (f"({ctx.inner_c_var} * {C_sa_total} + ({c_flat}))"
               if ctx.inner_c_var else f"({c_flat})")
    c_global_expr = (f"({ctx.outer_c_var} * {ctx.inner_c_factor * C_sa_total} + {c_inner[1:-1]})"
                     if ctx.outer_c_var else c_inner)

    S_sa_total   = math.prod(f for _, f in s_sa_pairs) if s_sa_pairs else 1
    s_total_expr = (f"({ctx.outer_s_var} * {S_sa_total} + ({s_flat}))"
                    if ctx.outer_s_var else s_flat)
    m_total_expr = (f"({ctx.outer_m_var} * {N_M_sp} + ({m_flat}))"
                    if ctx.outer_m_var else f"({m_flat})")

    w_shape   = "".join(f"[{f}]" for _, f in non_q_pairs)
    w_idx_str = "".join(f"[{v}]" for v, _ in non_q_pairs)
    n_w_elems = math.prod(f for _, f in non_q_pairs) if non_q_pairs else 1
    p_shape   = "".join(f"[{f}]" for _, f, _ in spec.all_dims)
    p_idx_str = "".join(f"[{v}]" for v in lvars)

    # ---- Phase 1: preload weights (non-Q SA dims only) ----
    lines += [
        f"{indent}// ---- Phase 1: preload weights — {n_w_elems} elems, no Q loop ----",
        f"{indent}// weight_tile{w_shape}: level-indexed, Q absent (weight is Q-independent)",
        f"{indent}DTYPE weight_tile{w_shape};",
    ]
    pre = indent
    for v, f in non_q_pairs:
        lines += [f"{pre}#pragma GCC unroll {f}", f"{pre}for (int {v} = 0; {v} < {f}; ++{v}) {{"]
        pre += "  "
    lines += [
        f"{pre}int global_channel_index = {c_global_expr};",
        f"{pre}int channel_bank = global_channel_index & 1;",
        f"{pre}int channel_block_index = global_channel_index >> 1;",
        f"{pre}int weight_dram_index = ({m_total_expr} * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + {r_var} * S + {s_total_expr};",
        f"{pre}weight_tile{w_idx_str} = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];",
    ]
    for v, _ in reversed(non_q_pairs):
        pre = pre[:-2]; lines.append(f"{pre}}}  // {v} (preload)")
    lines.append("")

    # ---- Phase 2a: multiply — N_PE independent products ----
    lines += [
        f"{indent}// ---- Phase 2a: multiply — {spec.N_PE} independent products ----",
        f"{indent}// product{p_shape}: GCC SROA → {spec.N_PE} scalar float regs",
        f"{indent}DTYPE product{p_shape};",
        f"{indent}int output_col_base = {ctx.outer_q_var} * {N_Q_sp};" if ctx.outer_q_var else f"{indent}int output_col_base = 0;",
    ]
    p2a = indent
    for v, (dm, f, _) in zip(lvars, spec.all_dims):
        lines += [f"{p2a}#pragma GCC unroll {f}", f"{p2a}for (int {v} = 0; {v} < {f}; ++{v}) {{  // {dm}:{f}"]
        p2a += "  "
    p_row = f"({ctx.outer_p_var} + {r_var})" if ctx.outer_p_var else r_var
    lines += [
        f"{p2a}int global_channel_index = {c_global_expr};",
        f"{p2a}int channel_bank = global_channel_index & 1;",
        f"{p2a}int channel_block_index = global_channel_index >> 1;",
        f"{p2a}int input_channel_base_address = channel_block_index * (H * W);",
        f"{p2a}int input_row_base_address = input_channel_base_address + {p_row} * W;",
        f"{p2a}int input_column_offset = output_col_base + {q_flat} + {s_total_expr};",
        f"{p2a}DTYPE weight_value = weight_tile{w_idx_str};",
        f"{p2a}DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]",
        f"{p2a}                                      : dram_in_b1[input_row_base_address + input_column_offset];",
        f"{p2a}product{p_idx_str} = weight_value * input_value;",
    ]
    for v, (dm, f, _) in reversed(list(zip(lvars, spec.all_dims))):
        p2a = p2a[:-2]; lines.append(f"{p2a}}}  // {v} ({dm}:{f})")
    lines.append("")

    # ---- Phase 2b: accumulate — N_PE independent, no RAW chain ----
    lines.append(f"{indent}// ---- Phase 2b: accumulate — {spec.N_PE} independent, no RAW chain ----")
    p2b = indent
    for v, (dm, f, _) in zip(lvars, spec.all_dims):
        lines += [f"{p2b}#pragma GCC unroll {f}", f"{p2b}for (int {v} = 0; {v} < {f}; ++{v}) {{"]
        p2b += "  "
    lines.append(f"{p2b}accumulator{p_idx_str} += product{p_idx_str};")
    for v, (dm, f, _) in reversed(list(zip(lvars, spec.all_dims))):
        p2b = p2b[:-2]; lines.append(f"{p2b}}}  // {v}")
    lines.append("")

    return lines


def _emit_seq_compute_body(ctx: _SACtx, r_var: str, indent: str) -> List[str]:
    """Sequential compute body: all-nounroll, inline weight read from DRAM."""
    spec = ctx.spec; lvars = ctx.lvars
    lines = []

    out_loop_vars_f = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm in {'M', 'P', 'Q'}]
    bank_expr  = _mixed_radix(out_loop_vars_f)
    m_sa_pairs = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'M']
    q_sa_pairs = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'Q']
    m_flat     = _mixed_radix(m_sa_pairs) if m_sa_pairs else "0"
    q_flat     = _mixed_radix(q_sa_pairs) if q_sa_pairs else "0"
    N_M_sp_seq = math.prod(f for _, f in m_sa_pairs) if m_sa_pairs else 1
    m_total    = (f"({ctx.outer_m_var} * {N_M_sp_seq} + ({m_flat}))"
                  if ctx.outer_m_var else (m_flat if m_flat != "0" else "0"))
    s_seq_expr = f"({ctx.outer_s_var} * {ctx.S_sa} + s)" if ctx.outer_s_var else "s"

    def _c_setup(ind):
        """Emit channel_bank/channel_block_index/input_channel_base_address/output_col_base lines inside the c loop."""
        if ctx.outer_c_var or ctx.inner_c_var:
            parts = []
            if ctx.outer_c_var: parts.append(f"{ctx.outer_c_var} * {ctx.inner_c_factor * ctx.C_sa}")
            if ctx.inner_c_var: parts.append(f"{ctx.inner_c_var} * {ctx.C_sa}")
            parts.append("c")
            lines.extend([f"{ind}  int global_channel_index = {' + '.join(parts)};",
                           f"{ind}  int channel_bank = global_channel_index & 1;",
                           f"{ind}  int channel_block_index = global_channel_index >> 1;"])
        else:
            lines.extend([f"{ind}  int channel_bank = c & 1;", f"{ind}  int channel_block_index = c >> 1;"])
        lines.append(f"{ind}  int input_channel_base_address = channel_block_index * (H * W);")
        q_rhs = f"{ctx.outer_q_var} * {ctx.N_Q_sp}" if ctx.outer_q_var else "0"
        lines.append(f"{ind}  int output_col_base = {q_rhs};")

    p_row = f"({ctx.outer_p_var} + {r_var})" if ctx.outer_p_var else r_var

    lines += [
        f"{indent}// SARows C:{ctx.C_sa} -- sequential (reduction)",
        f"{indent}#pragma GCC nounroll",
        f"{indent}for (int c = 0; c < {ctx.C_sa}; ++c) {{",
    ]
    _c_setup(indent)
    lines += [
        "",
        f"{indent}  // SARows S:{ctx.S_sa}",
        f"{indent}  #pragma GCC nounroll",
        f"{indent}  for (int s = 0; s < {ctx.S_sa}; ++s) {{",
    ]
    seq = indent + "    "
    for (var, fac), (dim, _, _) in zip(out_loop_vars_f, spec.out_dims):
        lines += [f"{seq}#pragma GCC nounroll",
                  f"{seq}for (int {var} = 0; {var} < {fac}; ++{var}) {{  // {dim}:{fac}"]
        seq += "  "
    lines += [
        f"{seq}int weight_dram_index = (({m_total}) * ((C + in_banks - 1) / in_banks) + channel_block_index) * (R * S) + {r_var} * S + {s_seq_expr};",
        f"{seq}DTYPE weight_value = (channel_bank==0) ? dram_w_b0[weight_dram_index] : dram_w_b1[weight_dram_index];",
        f"{seq}int input_row_base_address = input_channel_base_address + {p_row} * W;",
        f"{seq}int input_column_offset = output_col_base + {q_flat} + {s_seq_expr};",
        f"{seq}DTYPE input_value = (channel_bank==0) ? dram_in_b0[input_row_base_address + input_column_offset]",
        f"{seq}                                      : dram_in_b1[input_row_base_address + input_column_offset];",
        f"{seq}accumulator[{bank_expr}] += weight_value * input_value;",
    ]
    for (var, fac), (dim, _, _) in reversed(list(zip(out_loop_vars_f, spec.out_dims))):
        seq = seq[:-2]; lines.append(f"{seq}}}  // {var} ({dim}:{fac})")
    lines += [f"{indent}  }}  // s", f"{indent}}}  // c", ""]
    return lines


def _emit_reduction_tree_block(ctx: _SACtx, indent: str) -> List[str]:
    """Scalar reduction tree: N_PE accumulators → N_out outputs."""
    spec = ctx.spec; lvars = ctx.lvars
    out_vars      = [v for v, (dm, _, _) in zip(lvars, spec.all_dims) if dm in {'M', 'P', 'Q'}]
    red_positions = [i for i, (dm, _, _) in enumerate(spec.all_dims) if dm not in {'M', 'P', 'Q'}]
    out_positions = [i for i, (dm, _, _) in enumerate(spec.all_dims) if dm in {'M', 'P', 'Q'}]
    red_factors   = [spec.all_dims[i][1] for i in red_positions]

    lines = [
        f"{indent}// ---- reduction: {spec.N_PE} acc → {spec.N_out} outputs ({spec.N_red} inputs each) ----",
        f"{indent}DTYPE reduced_output{''.join(f'[{f}]' for _, f, _ in spec.out_dims)};",
    ]
    red = indent
    for var, (dim, fac, _) in zip(out_vars, spec.out_dims):
        lines += [f"{red}#pragma GCC unroll {fac}", f"{red}for (int {var} = 0; {var} < {fac}; ++{var}) {{"]
        red += "  "

    values = []
    for combo in iprod(*[range(f) for f in red_factors]):
        idx = ["?"] * len(spec.all_dims)
        for k, i in enumerate(red_positions): idx[i] = str(combo[k])
        for k, i in enumerate(out_positions): idx[i] = out_vars[k]
        values.append(f"accumulator{''.join(f'[{x}]' for x in idx)}")

    stmts, final = _scalar_tree(values)
    for s in stmts:
        lines.append(f"{red}{s}")
    lines.append(f"{red}reduced_output{''.join(f'[{v}]' for v in out_vars)} = {final};")

    for var, (dim, fac, _) in reversed(list(zip(out_vars, spec.out_dims))):
        red = red[:-2]; lines.append(f"{red}}}  // {var} (reduction)")
    lines.append("")
    return lines


def _emit_writeback_block(ctx: _SACtx, unroll: bool, indent: str) -> List[str]:
    """Write reduced/accumulated values to banked output DRAM ports."""
    spec = ctx.spec; lvars = ctx.lvars
    out_loop_vars_f = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm in {'M', 'P', 'Q'}]
    bank_expr = _mixed_radix(out_loop_vars_f)
    cm_expr   = f"{ctx.outer_m_var}" if ctx.outer_m_var else "0"
    cp_expr   = f"{ctx.outer_p_var}" if ctx.outer_p_var else "0"
    cq_expr   = f"{ctx.outer_q_var}" if ctx.outer_q_var else "0"
    pragma    = "unroll" if unroll else "nounroll"
    val_expr  = f"reduced_output{''.join(f'[{v}]' for v, _ in out_loop_vars_f)}" if unroll else f"accumulator[{bank_expr}]"

    lines = [f"{indent}// OutRegister: write accumulator to banked output ports"]
    wb = indent
    for (var, fac), (dim, _, _) in zip(out_loop_vars_f, spec.out_dims):
        lines += [f"{wb}#pragma GCC {pragma} {fac}", f"{wb}for (int {var} = 0; {var} < {fac}; ++{var}) {{"]
        wb += "  "
    lines += [
        f"{wb}int output_bank = {bank_expr};",
        f"{wb}int output_filter_tile = {cm_expr};",
        f"{wb}int output_row_tile = {cp_expr};",
        f"{wb}int output_col_tile = {cq_expr};",
        f"{wb}int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;",
        f"{wb}DTYPE output_value = {val_expr};",
        _emit_out_store_switch_fixed("output_bank", spec.N_out, "output_dram_offset", "output_value", wb),
    ]
    for _ in out_loop_vars_f:
        wb = wb[:-2]; lines.append(f"{wb}}}")
    return lines


def _emit_top_level_sa(mapping: MappingInfo, bank: ConvBankSpec, unroll: bool = True) -> str:
    """
    Generalized SA-shaped kernel (Option B).
    unroll=True  → SA path: weight preload (Phase 1) + multiply (2a) + accumulate (2b) + reduction tree.
    unroll=False → SEQ path: all-nounroll, inline weight reads, no preload.
    Loop structure mirrors the FF mapping hierarchy directly.
    """
    ctx  = _build_sa_ctx(mapping, bank)
    kind = "SA (weight-preload)" if unroll else "seq (all-nounroll)"

    code = [_emit_headers_and_pragmas(ctx.spec.N_out), _emit_top_signature(ctx.spec.N_out), "{"]
    code += [
        f"    // {kind} Eyeriss CONV — loop structure mirrors FF mapping hierarchy",
        f"    const int M={ctx.M}, P={ctx.P}, Q={ctx.Q}, C={ctx.C}, R={ctx.R}, S={ctx.S};",
        f"    const int H={ctx.H}, W={ctx.W};",
        f"    const int Ptiles={ctx.Ptiles}, Qtiles={ctx.Qtiles};",
        f"    const int in_banks={ctx.in_banks};",
        "",
    ]
    code.extend(_emit_acc_decl(ctx, unroll))
    code.append("")

    indent = "    "

    # Outer output loops (M,P,Q) — wrap zero-init and write-back
    for vname, fac, cmt, _dim in ctx.outer_out_specs:
        code += [f"{indent}// {cmt}", f"{indent}#pragma GCC nounroll",
                 f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{"]
        indent += "  "

    code.extend(_emit_acc_init(ctx, unroll, indent))
    code.append("")

    # Outer reduction loops (C,S,R) — accumulate without resetting the accumulator
    for vname, fac, cmt, _dim in ctx.outer_red_specs:
        code += [f"{indent}// {cmt}", f"{indent}#pragma GCC nounroll",
                 f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{"]
        indent += "  "

    # Inner sequential loops (WRegister, InRegister)
    for vname, fac, cmt in ctx.inner_loop_specs:
        code += [f"{indent}// {cmt} (sequential)", f"{indent}#pragma GCC nounroll",
                 f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{"]
        indent += "  "

    r_var = ctx.inner_r_var or "filter_row_offset"
    if not ctx.inner_r_var:
        code.append(f"{indent}int filter_row_offset = 0;  // R=1 or no inner sequential R loop")

    code.extend(_emit_sa_compute_body(ctx, r_var, indent) if unroll
                else _emit_seq_compute_body(ctx, r_var, indent))

    for vname, _fac, _cmt in reversed(ctx.inner_loop_specs):
        indent = indent[:-2]; code.append(f"{indent}}}  // {vname}")
    code.append("")

    for vname, _fac, _cmt, _dim in reversed(ctx.outer_red_specs):
        indent = indent[:-2]; code.append(f"{indent}}}  // {vname}")
    if ctx.outer_red_specs:
        code.append("")

    if unroll:
        code.extend(_emit_reduction_tree_block(ctx, indent))

    code.extend(_emit_writeback_block(ctx, unroll, indent))

    for vname, _fac, _cmt, _dim in reversed(ctx.outer_out_specs):
        indent = indent[:-2]; code.append(f"{indent}}}  // {vname}")

    code += ["}", ""]
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