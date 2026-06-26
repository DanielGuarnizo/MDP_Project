from __future__ import annotations

import math
from itertools import product as iprod
from typing import List

from mapping_types import MappingInfo
from codegen.conv.dim_spec import _mixed_radix, _scalar_tree
from codegen.conv.port_spec import ConvBankSpec, _emit_headers_and_pragmas, _emit_top_signature
from codegen.conv.ctx import _SACtx, _build_sa_ctx


def _emit_acc_decl(ctx: _SACtx, unroll: bool) -> List[str]:
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


def _emit_input_port_switch(port_var: str, input_ports: int, index_expr: str,
                             result_var: str, rhs_template: str, indent: str) -> List[str]:
    lines = [f"{indent}switch({port_var}) {{"]
    for i in range(input_ports):
        lines.append(f"{indent}  case {i}: {result_var} = dram_input_p{i}[{index_expr}]; break;")
    lines.append(f"{indent}  default: {result_var} = 0.0f; break;")
    lines.append(f"{indent}}}")
    return lines


def _emit_weight_port_switch(port_var: str, weight_ports: int, index_expr: str,
                              result_var: str, indent: str) -> List[str]:
    lines = [f"{indent}switch({port_var}) {{"]
    for i in range(weight_ports):
        lines.append(f"{indent}  case {i}: {result_var} = dram_weight_p{i}[{index_expr}]; break;")
    lines.append(f"{indent}  default: {result_var} = 0.0f; break;")
    lines.append(f"{indent}}}")
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

    # r_total_expr: full R index combining outer_r + SA_r + inner_r across all levels
    r_sa_pairs  = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm == 'R']
    R_sa_total  = math.prod(f for _, f in r_sa_pairs) if r_sa_pairs else 1
    r_sa_flat   = _mixed_radix(r_sa_pairs) if r_sa_pairs else "0"
    inner_r_fac = ctx.inner_r_factor
    r_total_parts: list = []
    if ctx.outer_r_var:
        r_total_parts.append(f"{ctx.outer_r_var} * {R_sa_total * inner_r_fac}")
    if r_sa_flat != "0":
        part = f"({r_sa_flat})"
        r_total_parts.append(f"{part} * {inner_r_fac}" if inner_r_fac > 1 else part)
    if ctx.inner_r_var:
        r_total_parts.append(ctx.inner_r_var)
    r_total_expr = " + ".join(r_total_parts) if r_total_parts else "0"

    # ---- Phase 1: preload weights into weight_tile[] from gb_weight (no Q loop) ----
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
        f"{pre}weight_tile{w_idx_str} = gb_weight[{m_total_expr}][global_channel_index][{r_total_expr}][{s_total_expr}];",
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
        f"{p2a}int input_col = output_col_base + {q_flat} + {s_total_expr};",
        f"{p2a}DTYPE weight_value = weight_tile{w_idx_str};",
        f"{p2a}DTYPE input_value = gb_input[global_channel_index][{p_row}][input_col];",
    ]
    lines.append(f"{p2a}product{p_idx_str} = weight_value * input_value;")
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
    """Sequential compute body: all-nounroll, reads weights/inputs from gb scratchpads."""
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
        if ctx.outer_c_var or ctx.inner_c_var:
            parts = []
            if ctx.outer_c_var: parts.append(f"{ctx.outer_c_var} * {ctx.inner_c_factor * ctx.C_sa}")
            if ctx.inner_c_var: parts.append(f"{ctx.inner_c_var} * {ctx.C_sa}")
            parts.append("c")
            lines.extend([f"{ind}  int global_channel_index = {' + '.join(parts)};"])
        else:
            lines.extend([f"{ind}  int global_channel_index = c;"])
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
        f"{seq}DTYPE weight_value = gb_weight[{m_total}][global_channel_index][{r_var}][{s_seq_expr}];",
        f"{seq}DTYPE input_value = gb_input[global_channel_index][{p_row}][output_col_base + {q_flat} + {s_seq_expr}];",
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
    """Write reduced/accumulated values to output DRAM ports."""
    spec = ctx.spec; lvars = ctx.lvars
    out_loop_vars_f = [(v, f) for v, (dm, f, _) in zip(lvars, spec.all_dims) if dm in {'M', 'P', 'Q'}]
    cm_expr   = f"{ctx.outer_m_var}" if ctx.outer_m_var else "0"
    cp_expr   = f"{ctx.outer_p_var}" if ctx.outer_p_var else "0"
    cq_expr   = f"{ctx.outer_q_var}" if ctx.outer_q_var else "0"

    factors       = [f for _, f in out_loop_vars_f]
    output_ports  = ctx.output_ports
    folding_depth = ctx.folding_depth

    lines = [
        f"{indent}// OutRegister: write {ctx.n_out} outputs to {output_ports} port(s), folding={folding_depth}",
        f"{indent}int output_filter_tile = {cm_expr};",
        f"{indent}int output_row_tile = {cp_expr};",
        f"{indent}int output_col_tile = {cq_expr};",
        f"{indent}int output_dram_offset = (output_filter_tile * Ptiles + output_row_tile) * Qtiles + output_col_tile;",
    ]

    for combo in iprod(*[range(f) for f in factors]):
        bank = 0
        for i, idx in enumerate(combo):
            stride = 1
            for j in range(i + 1, len(factors)):
                stride *= factors[j]
            bank += idx * stride

        port        = bank % output_ports
        fold_offset = bank // output_ports

        val  = f"reduced_output{''.join(f'[{idx}]' for idx in combo)}" if unroll else f"accumulator[{bank}]"
        addr = "output_dram_offset" if folding_depth == 1 \
               else f"output_dram_offset * {folding_depth} + {fold_offset}"

        lines.append(f"{indent}dram_output_p{port}[{addr}] = {val};")

    return lines


def _emit_gb_static_decls(ctx: _SACtx) -> str:
    """Module-scope static arrays for GlobalBuffer scratchpads.

    Declared outside void top_level() so Bambu maps them to internal BRAM rather
    than AXI ports. Level-agnostic: correct whether GlobalBuffer is present in the
    FF hierarchy or not (preload always reads wt_ideal / in_ideal elements from AXI).
    """
    return (
        f"// Internal scratchpads — filled once per top_level call from AXI ports\n"
        f"static DTYPE gb_weight[{ctx.M}][{ctx.C}][{ctx.R}][{ctx.S}];\n"
        f"static DTYPE gb_input[{ctx.C}][{ctx.H}][{ctx.W}];"
    )


def _emit_weight_gb_preload(ctx: _SACtx, indent: str) -> List[str]:
    """Fill gb_weight from AXI weight ports — exactly wt_ideal = M*C*R*S reads."""
    ip = ctx.input_ports
    lines = [
        f"{indent}// ---- GlobalBuffer weight preload: wt_ideal = {ctx.M}*{ctx.C}*{ctx.R}*{ctx.S} AXI reads ----",
        f"{indent}for (int _gm = 0; _gm < {ctx.M}; ++_gm) {{",
        f"{indent}  for (int _gc = 0; _gc < {ctx.C}; ++_gc) {{",
        f"{indent}    for (int _gr = 0; _gr < {ctx.R}; ++_gr) {{",
        f"{indent}      for (int _gs = 0; _gs < {ctx.S}; ++_gs) {{",
        f"{indent}        int weight_port_index = _gc % {ip};",
        f"{indent}        int _cb = _gc / {ip};",
        f"{indent}        int _wa = (_gm * (({ctx.C} + {ip} - 1) / {ip}) + _cb) * ({ctx.R} * {ctx.S}) + _gr * {ctx.S} + _gs;",
    ]
    lines += _emit_weight_port_switch("weight_port_index", ip, "_wa",
                                       "gb_weight[_gm][_gc][_gr][_gs]", f"{indent}        ")
    lines += [
        f"{indent}      }}",
        f"{indent}    }}",
        f"{indent}  }}",
        f"{indent}}}",
        "",
    ]
    return lines


def _emit_input_gb_preload(ctx: _SACtx, indent: str) -> List[str]:
    """Fill gb_input from AXI input ports — exactly in_ideal = C*H*W AXI reads."""
    ip = ctx.input_ports
    lines = [
        f"{indent}// ---- GlobalBuffer input preload: in_ideal = {ctx.C}*{ctx.H}*{ctx.W} AXI reads ----",
        f"{indent}for (int _gc = 0; _gc < {ctx.C}; ++_gc) {{",
        f"{indent}  for (int _gr = 0; _gr < {ctx.H}; ++_gr) {{",
        f"{indent}    for (int _gw = 0; _gw < {ctx.W}; ++_gw) {{",
        f"{indent}      int input_port_index = _gc % {ip};",
        f"{indent}      int _cb = _gc / {ip};",
        f"{indent}      int _ia = _cb * ({ctx.H} * {ctx.W}) + _gr * {ctx.W} + _gw;",
    ]
    lines += _emit_input_port_switch("input_port_index", ip, "_ia",
                                      "gb_input[_gc][_gr][_gw]", "", f"{indent}      ")
    lines += [
        f"{indent}    }}",
        f"{indent}  }}",
        f"{indent}}}",
        "",
    ]
    return lines


def _emit_top_level_sa(mapping: MappingInfo, bank: ConvBankSpec, unroll: bool = True) -> str:
    """
    Generalized SA-shaped kernel.
    unroll=True  → SA path: weight preload + multiply + accumulate + reduction tree.
    unroll=False → SEQ path: all-nounroll, inline weight reads, no preload.
    """
    ctx  = _build_sa_ctx(mapping, bank)
    kind = "SA (weight-preload)" if unroll else "seq (all-nounroll)"

    code = [
        _emit_headers_and_pragmas(ctx.input_ports, ctx.input_ports, ctx.output_ports, ctx.physical_ports),
        _emit_gb_static_decls(ctx),
        _emit_top_signature(ctx.input_ports, ctx.input_ports, ctx.output_ports),
        "{",
    ]
    code += [
        f"    // {kind} Eyeriss CONV — loop structure mirrors FF mapping hierarchy",
        f"    const int M={ctx.M}, P={ctx.P}, Q={ctx.Q}, C={ctx.C}, R={ctx.R}, S={ctx.S};",
        f"    const int H={ctx.H}, W={ctx.W};",
        f"    const int Ptiles={ctx.Ptiles}, Qtiles={ctx.Qtiles};",
        f"    const int input_ports={ctx.input_ports};",
        "",
    ]
    code.extend(_emit_acc_decl(ctx, unroll))
    code.append("")

    indent = "    "
    code.extend(_emit_weight_gb_preload(ctx, indent))
    code.extend(_emit_input_gb_preload(ctx, indent))

    for vname, fac, cmt, _dim in ctx.outer_out_specs:
        code += [f"{indent}// {cmt}", f"{indent}#pragma GCC nounroll",
                 f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{"]
        indent += "  "

    code.extend(_emit_acc_init(ctx, unroll, indent))
    code.append("")

    for vname, fac, cmt, _dim in ctx.outer_red_specs:
        code += [f"{indent}// {cmt}", f"{indent}#pragma GCC nounroll",
                 f"{indent}for (int {vname} = 0; {vname} < {fac}; ++{vname}) {{"]
        indent += "  "

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


def _emit_top_level_seq(mapping: MappingInfo, bank: ConvBankSpec) -> str:
    return _emit_top_level_sa(mapping, bank, unroll=False)
