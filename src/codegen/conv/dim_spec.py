from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Dict, List, Tuple

from mapping_types import MappingInfo


@dataclass
class SADimSpec:
    """SA spatial partition specification derived from a FF mapping.

    all_dims: SARows partitions first (FF order), then SACols partitions (FF order).
    Each entry: (dim_name, factor, level) where level ∈ {"SARows", "SACols"}.
    """
    all_dims: List[Tuple[str, int, str]]

    @property
    def N_PE(self) -> int:
        return math.prod(f for _, f, _ in self.all_dims)

    @property
    def red_dims(self) -> List[Tuple[str, int, str]]:
        return [(d, f, l) for d, f, l in self.all_dims if d not in {'M', 'P', 'Q'}]

    @property
    def out_dims(self) -> List[Tuple[str, int, str]]:
        return [(d, f, l) for d, f, l in self.all_dims if d in {'M', 'P', 'Q'}]

    @property
    def N_red(self) -> int:
        return math.prod(f for _, f, _ in self.red_dims) if self.red_dims else 1

    @property
    def N_out(self) -> int:
        return math.prod(f for _, f, _ in self.out_dims) if self.out_dims else 1

    def loop_vars(self) -> List[str]:
        counter: Dict[str, int] = {}
        names = []
        for dim, fac, level in self.all_dims:
            lname = level.lower().replace(" ", "")
            k = counter.get(lname, 0)
            counter[lname] = k + 1
            names.append(f"{lname}_{k}")
        return names

    def loop_var_comments(self) -> List[str]:
        counter: Dict[str, int] = {}
        lines = []
        for dim, fac, level in self.all_dims:
            lname = level.lower().replace(" ", "")
            k = counter.get(lname, 0)
            counter[lname] = k + 1
            lines.append(f"// {lname}_{k} → {level}_{k} = {dim}:{fac}")
        return lines


def _classify_sa_dims(mapping: MappingInfo) -> SADimSpec:
    tiling = getattr(mapping, "tiling", {}) or {}
    sarows = tiling.get("SARows", {}) or {}
    sacols = tiling.get("SACols", {}) or {}

    all_dims: List[Tuple[str, int, str]] = []
    for dim, fac in sarows.items():
        all_dims.append((dim, int(fac), "SARows"))
    for dim, fac in sacols.items():
        all_dims.append((dim, int(fac), "SACols"))

    return SADimSpec(all_dims=all_dims)


def _classify_levels(mapping: MappingInfo):
    """Split mapping levels into (outer_mem, fanout, inner_mem).

    outer_mem: MemLevels before first SA level  (DRAM, GlobalBuffer)
    fanout:    SA-named levels                   (SACols, SARows)
    inner_mem: MemLevels after last SA level,    (WRegister, InRegister)
               excl. OutRegister
    """
    levels = mapping.spatial_levels
    tiling = mapping.tiling

    fa_idx = [i for i, l in enumerate(levels) if "SA" in l]
    if not fa_idx:
        return list(levels), [], []

    first_fa, last_fa = fa_idx[0], fa_idx[-1]
    outer_mem = [l for l in levels[:first_fa]   if tiling.get(l)]
    fanout    = [levels[i] for i in fa_idx]
    inner_mem = [l for l in levels[last_fa+1:]
                 if "Register" in l and "Out" not in l and tiling.get(l)]
    return outer_mem, fanout, inner_mem


def _level_short(lvl: str) -> str:
    return lvl.lower().replace(" ", "")


def _composite_tile_expr(terms: list) -> tuple:
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


def _mixed_radix(dim_vars: list) -> str:
    """[(var0,f0),(var1,f1),...] → mixed-radix address expression."""
    if not dim_vars:
        return "0"
    remaining = math.prod(f for _, f in dim_vars)
    parts = []
    for var, f in dim_vars:
        remaining //= f
        parts.append(f"{var}*{remaining}" if remaining > 1 else var)
    return " + ".join(parts)


def _scalar_tree(values: list) -> tuple:
    """Left-leaning binary tree over N values. Returns (stmts, final_var)."""
    stmts: list = []
    level = 0
    while len(values) > 1:
        nxt = []
        for i in range(0, len(values), 2):
            if i + 1 < len(values):
                v = f"partial_sum_{level}_{i//2}"
                stmts.append(f"DTYPE {v} = {values[i]} + {values[i+1]};")
                nxt.append(v)
            else:
                nxt.append(values[i])
        values, level = nxt, level + 1
    return stmts, values[0]
