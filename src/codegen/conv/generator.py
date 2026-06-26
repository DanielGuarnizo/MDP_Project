#!/usr/bin/env python3
from __future__ import annotations

import math
from pathlib import Path
from typing import Any, Dict, List

from mapping_types import MappingInfo
from harness.conv_harness import make_conv_testbench, conv_tb_param_sizes

from codegen.conv.dim_spec import _classify_sa_dims, SADimSpec, _mixed_radix
from codegen.conv.port_spec import ConvBankSpec, _infer_eyeriss_port_spec
from codegen.conv.emit_kernel import _emit_top_level_seq, _emit_top_level_sa
from codegen.conv.checks import (
    _verify_sa_structure, _cpu_golden_check,
    _compute_expected_mops, _mop_runtime_check,
)
from codegen.conv.scripts import _emit_compile_bambu_sh, _emit_run_compare_sh, _write


def _gen_gather_bank_c(spec: SADimSpec, lvars: List[str],
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


def generate_experiment(mapping: MappingInfo, config: Dict[str, Any], out_dir: Path) -> None:
    """
    Conv generator entry point. Writes into out_dir:
      - top_level_seq.c
      - top_level_sa.c
      - testbench_common.c
      - compile_bambu.sh
      - run_compare.sh
    """
    arch = (getattr(mapping, "arch", "") or "").lower().strip()
    wl   = (getattr(mapping, "workload", "") or "").upper().strip()
    aw   = (getattr(mapping, "arch_workload", "") or "").lower().strip()

    if arch not in ("eyeriss", "alveo-u55c") or wl != "CONV":
        raise ValueError(
            f"[generator] Expected arch='eyeriss' or 'alveo-u55c' and workload='CONV', "
            f"got arch={arch!r}, workload={wl!r}, arch_workload={aw!r}"
        )

    if aw and not aw.endswith("-conv"):
        raise ValueError(
            f"[generator] Expected arch_workload to end with '-conv', got {aw!r}"
        )

    spec     = _classify_sa_dims(mapping)
    expected = _compute_expected_mops(mapping, spec)

    bambu_cfg = config.get("bambu", {}) or {}
    device_cfg = bambu_cfg.get("device", {}) or {}
    if "physical_ports" not in device_cfg:
        raise KeyError(
            "[generator] config['bambu']['device']['physical_ports'] is required"
        )
    physical_ports = int(device_cfg["physical_ports"])

    bank = _infer_eyeriss_port_spec(mapping, spec.N_out, physical_ports)
    folding_depth = math.ceil(spec.N_out / bank.output_ports)

    seq_c = _emit_top_level_seq(mapping, bank)
    sa_c  = _emit_top_level_sa(mapping, bank)

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
    tb_c = make_conv_testbench(
        mapping, bank, gather_bank_c=gather_bank_c,
        out_banks_n=spec.N_out, out_bank_elems_n=out_bank_elems_tb,
        output_ports=bank.output_ports, folding_depth=folding_depth,
    )
    tb_sizes = conv_tb_param_sizes(
        mapping, bank, spec,
        output_ports=bank.output_ports, folding_depth=folding_depth,
    )

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
    _verify_sa_structure(spec, sa_c, out_dir.name, mapping=mapping, expected=expected)
    _cpu_golden_check(out_dir, out_dir.name)
    _mop_runtime_check(out_dir, out_dir.name, sa_c, expected)
