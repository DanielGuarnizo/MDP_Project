from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Any, Dict, List

from mapping_types import MappingInfo
from codegen.conv.dim_spec import (
    SADimSpec, _classify_sa_dims, _classify_levels,
    _level_short, _composite_tile_expr,
)
from codegen.conv.port_spec import ConvBankSpec


@dataclass
class _SACtx:
    """Pre-computed loop-structure facts threaded through SA/SEQ kernel emitters."""
    M: int; P: int; Q: int; C: int; R: int; S: int; H: int; W: int
    input_ports: int
    physical_ports: int
    spec: SADimSpec
    lvars: List[str]
    N_M_sp: int; N_Q_sp: int; N_P_sp: int
    Ptiles: int; Qtiles: int
    outer_out_specs: List       # [(vname, fac, comment, dim)]
    outer_red_specs: List       # [(vname, fac, comment, dim)]
    outer_q_var: Any; outer_q_factor: int
    outer_p_var: Any; outer_p_factor: int
    outer_m_var: Any; outer_m_factor: int
    outer_c_var: Any; outer_c_factor: int
    outer_s_var: Any; outer_s_factor: int
    outer_r_var: Any; outer_r_factor: int
    inner_loop_specs: List      # [(vname, fac, comment)]
    inner_r_var: Any
    inner_r_factor: int
    inner_c_var: Any
    inner_c_factor: int
    C_sa: int; S_sa: int
    output_ports: int
    n_out: int
    folding_depth: int


def _build_sa_ctx(mapping: MappingInfo, bank: ConvBankSpec) -> _SACtx:
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
    outer_c_terms: list = []; outer_s_terms: list = []; outer_r_terms: list = []
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
            if dim == "R": outer_r_terms.append((vname, fac))

    # OutRegister output dims (M,P,Q) act as additional output tile loops
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
    outer_r_var, outer_r_factor = _composite_tile_expr(outer_r_terms)

    M_tiles = (M + N_M_sp - 1) // N_M_sp
    if M_tiles > 1 and outer_m_var is None:
        outer_m_var = "m_tile"
        outer_loop_specs.insert(0, ("m_tile", M_tiles, "M tile (synthetic outer loop)", "M"))

    outer_out_specs = [(v, f, c, dm) for v, f, c, dm in outer_loop_specs if dm in _OUTPUT_DIMS]
    outer_red_specs = [(v, f, c, dm) for v, f, c, dm in outer_loop_specs if dm not in _OUTPUT_DIMS]

    inner_loop_specs: list = []
    inner_r_var = None; inner_r_factor = 1
    inner_c_var = None; inner_c_factor = 1
    inner_level_ctr: Dict[str, int] = {}
    for lvl in inner_mem:
        lvl_name = lvl.lower().replace(" ", "")
        for dim, fac in (tiling.get(lvl, {}) or {}).items():
            fac = int(fac)
            k = inner_level_ctr.get(lvl_name, 0); inner_level_ctr[lvl_name] = k + 1
            vname = f"{lvl_name}_{k}"
            if dim == "C": inner_c_var = vname; inner_c_factor = fac
            if dim == "R": inner_r_var = vname; inner_r_factor = fac
            inner_loop_specs.append((vname, fac, f"{lvl} → {dim}:{fac}"))

    sarows_til = tiling.get("SARows", {}) or {}
    C_sa = int(sarows_til.get("C", 1))
    S_sa = int(sarows_til.get("S", 1))

    n_out = spec.N_out
    output_ports = bank.output_ports
    folding_depth = math.ceil(n_out / output_ports)

    return _SACtx(
        M=M, P=P, Q=Q, C=C, R=R, S=S, H=H, W=W,
        input_ports=bank.input_ports,
        physical_ports=bank.physical_ports,
        spec=spec, lvars=lvars,
        N_M_sp=N_M_sp, N_Q_sp=N_Q_sp, N_P_sp=N_P_sp,
        Ptiles=Ptiles, Qtiles=Qtiles,
        outer_out_specs=outer_out_specs, outer_red_specs=outer_red_specs,
        outer_q_var=outer_q_var, outer_q_factor=outer_q_factor,
        outer_p_var=outer_p_var, outer_p_factor=outer_p_factor,
        outer_m_var=outer_m_var, outer_m_factor=outer_m_factor,
        outer_c_var=outer_c_var, outer_c_factor=outer_c_factor,
        outer_s_var=outer_s_var, outer_s_factor=outer_s_factor,
        outer_r_var=outer_r_var, outer_r_factor=outer_r_factor,
        inner_loop_specs=inner_loop_specs,
        inner_r_var=inner_r_var, inner_r_factor=inner_r_factor,
        inner_c_var=inner_c_var, inner_c_factor=inner_c_factor,
        C_sa=C_sa, S_sa=S_sa,
        output_ports=output_ports,
        n_out=n_out,
        folding_depth=folding_depth,
    )
