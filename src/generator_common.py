#!/usr/bin/env python3
from __future__ import annotations
from dataclasses import dataclass
import re
from typing import Dict, List, Tuple, Optional


# -----------------------------
# Parsed FactorFlow structures
# -----------------------------

@dataclass
class MappingInfo:
    workload_type: str                 # "GEMM" or "CONV"
    dims: Dict[str, int]               # e.g. {"M":4,"P":4,"Q":4,"C":4,"R":3,"S":3}
    tiling: Dict[str, Dict[str, int]]  # level -> {dim -> factor}
    spatial_levels: List[str]          # levels that are spatial (SACols, SARows, etc.)


def parse_ff_output(path: str) -> MappingInfo:
    """
    Parse the subset of FactorFlow output you are extracting with:
      sed -n '/^Computation:/p;/^Mapping:/,/^Final MOPs per memory level:/p'

    Expected blocks:
      Computation: {M: 4, P: 4, ...}
      Mapping:
      DRAM ----------> Q: 2
      GlobalBuffer --> P: 4
      SACols --------> Q: 2, M: 4
      ...
    """
    with open(path, "r") as f:
        txt = f.read()

    # ---- Computation ----
    m = re.search(r"Computation:\s*\{([^}]*)\}", txt)
    if not m:
        raise ValueError("Could not find 'Computation: {...}' in FF output.")
    comp = m.group(1)

    dims: Dict[str, int] = {}
    for part in comp.split(","):
        part = part.strip()
        if not part:
            continue
        k, v = part.split(":")
        dims[k.strip()] = int(v.strip())

    # infer workload type
    workload_type = "CONV" if any(k in dims for k in ["P", "Q", "R", "S", "C"]) else "GEMM"

    # ---- Mapping lines ----
    tiling: Dict[str, Dict[str, int]] = {}
    spatial_levels: List[str] = []

    # take lines between "Mapping:" and "Final MOPs"
    block_m = re.search(r"Mapping:\s*\n(.*?)\n\s*Final MOPs", txt, flags=re.S)
    if not block_m:
        raise ValueError("Could not find 'Mapping:' block in FF output.")
    mapping_block = block_m.group(1).strip().splitlines()

    for line in mapping_block:
        line = line.strip()
        if not line or line.startswith("Compute"):
            # Compute line often empty mapping
            lvl = line.split()[0] if line else None
            if lvl and lvl not in tiling:
                tiling[lvl] = {}
            continue

        # e.g. "SACols --------> Q: 2, M: 4"
        lvl = line.split()[0]
        rhs = ""
        if ">" in line:
            rhs = line.split(">", 1)[1].strip()
        rhs = rhs.strip("-").strip()

        factors: Dict[str, int] = {}
        if rhs:
            # tokens like "Q: 2, M: 4"
            for tok in rhs.split(","):
                tok = tok.strip()
                if not tok:
                    continue
                if ":" not in tok:
                    continue
                dk, dv = tok.split(":")
                factors[dk.strip()] = int(dv.strip())

        tiling[lvl] = factors

        # Heuristic: "spatial" levels are those that look like fanout arrays in FF naming
        if lvl.lower() in ["sacols", "sarows", "pes", "regmac", "distributionbuffers", "sarows", "sacols"]:
            spatial_levels.append(lvl)

    return MappingInfo(
        workload_type=workload_type,
        dims=dims,
        tiling=tiling,
        spatial_levels=spatial_levels,
    )


# -----------------------------
# Codegen base (optional)
# -----------------------------

class CodeGenBase:
    def __init__(self, info: MappingInfo):
        self.info = info

    def headers_and_defines(self) -> str:
        # Common C headers used by generated code/harness
        d = self.info.dims
        # Only define what exists
        lines = ["#define DTYPE float"]
        for k, v in d.items():
            lines.append(f"#define {k}_TOTAL {int(v)}")
        return "\n".join(lines) + "\n\n"