from __future__ import annotations
from dataclasses import dataclass, field
from typing import Dict, List, Any, Optional
@dataclass(frozen=True)
class ConvBankSpec:
    # input/weight banking
    in_banks: int
    w_banks: int

    # output banking factors (parallel lanes)
    m_sf: int
    p_sf: int
    q_sf: int
    out_banks: int

    # derived tiles for per-bank indexing
    Ptiles: int
    Qtiles: int

    # sizes in elements (not bytes)
    H: int
    W: int
    c_blks: int
    in_bank_elems: int
    w_bank_elems: int
    out_bank_elems: int


@dataclass
class MappingInfo:
    # Raw string from FF: e.g. "eyeriss-conv"
    arch_workload: str = ""
    # Parsed: e.g. "eyeriss"
    arch: str = ""
    # Parsed: "CONV" or "GEMM"
    workload: str = ""

    # Computation dims: for CONV keys: M,P,Q,C,R,S
    dims: Dict[str, int] = field(default_factory=dict)

    # FactorFlow mapping (levels order as FF reports)
    # Example keys: "DRAM", "GlobalBuffer", "SACols", "SARows", "WRegister", "OutRegister"
    spatial_levels: List[str] = field(default_factory=list)

    # tiling[level][dim] = factor
    tiling: Dict[str, Dict[str, int]] = field(default_factory=dict)

    # optional extra metadata
    meta: Dict[str, Any] = field(default_factory=dict)

    def require(self, *keys: str) -> None:
        for k in keys:
            if k not in self.dims:
                raise RuntimeError(f"Missing dim '{k}' in MappingInfo.dims. Got: {self.dims}")

    @property
    def is_conv(self) -> bool:
        return self.workload.upper() == "CONV"

    @property
    def is_gemm(self) -> bool:
        return self.workload.upper() == "GEMM"