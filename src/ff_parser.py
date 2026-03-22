from __future__ import annotations
import re
from typing import Dict
from mapping_types import MappingInfo


_ARCH_RE = re.compile(r"^\s*Architecture:\s*([A-Za-z0-9_\-]+)\s*$")
_COMP_RE = re.compile(r"^\s*Computation:\s*\{(.+)\}\s*$")


def _parse_dim_dict(braced: str) -> Dict[str, int]:
    # "M: 4, P: 4, Q: 4, C: 4, R: 3, S: 3"
    out: Dict[str, int] = {}
    parts = [p.strip() for p in braced.split(",")]
    for p in parts:
        if not p:
            continue
        k, v = [x.strip() for x in p.split(":")]
        out[k] = int(v)
    return out


def _infer_arch_and_workload(arch_workload: str) -> tuple[str, str]:
    # e.g. "eyeriss-conv" -> ("eyeriss","CONV")
    toks = arch_workload.strip().lower().split("-")
    if len(toks) < 2:
        raise RuntimeError(f"Cannot infer arch/workload from '{arch_workload}'")
    arch = toks[0]
    wl = toks[-1]
    if wl == "conv":
        wl = "CONV"
    elif wl == "gemm":
        wl = "GEMM"
    else:
        wl = wl.upper()
    return arch, wl


def parse_ff_output(path: str) -> MappingInfo:
    """
    Eyeriss-focused parsing (robust enough for future extension):
    - parses Architecture and Computation
    - parses mapping lines like:
        DRAM ----------> Q: 2
        SACols --------> Q: 2, M: 4
    """
    info = MappingInfo()

    with open(path, "r") as f:
        lines = f.readlines()

    # ---- parse header ----
    for ln in lines[:80]:
        m = _ARCH_RE.match(ln)
        if m:
            info.arch_workload = m.group(1).strip()
            info.arch, info.workload = _infer_arch_and_workload(info.arch_workload)
            continue

        m = _COMP_RE.match(ln)
        if m:
            info.dims = _parse_dim_dict(m.group(1))

    if not info.arch_workload:
        raise RuntimeError("FF_output missing 'Architecture: ...' line.")
    if not info.dims:
        raise RuntimeError("FF_output missing 'Computation: {...}' line.")

    # ---- parse mapping block (levels) ----
    # Accept forms like:
    #   "DRAM ----------> Q: 2"
    #   "SACols --------> Q: 2, M: 4"
    map_line = re.compile(r"^\s*([A-Za-z0-9_]+)\s*-+\>\s*(.+)\s*$")

    for ln in lines:
        mm = map_line.match(ln)
        if not mm:
            continue

        lvl = mm.group(1).strip()
        rhs = mm.group(2).strip()

        # rhs: "Q: 2, M: 4" or "Q: 2"
        til: Dict[str, int] = {}
        for part in rhs.split(","):
            part = part.strip()
            if not part:
                continue
            if ":" not in part:
                continue
            d, v = [x.strip() for x in part.split(":")]
            # ignore expressions like P+R if ever shown here
            if re.match(r"^\d+$", v):
                til[d] = int(v)

        if til:
            if lvl not in info.tiling:
                info.tiling[lvl] = {}
            info.tiling[lvl].update(til)
            if lvl not in info.spatial_levels:
                info.spatial_levels.append(lvl)

    # Eyeriss-only CONV supported today
    if info.workload == "CONV" and info.arch != "eyeriss":
        raise RuntimeError(f"Currently only eyeriss-conv is supported. Got: {info.arch_workload}")

    return info