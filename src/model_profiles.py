"""
ArchProfile — architecture-specific AXI read formulas for BambuCycleModel.

Each profile encodes two things:
  port_reads(mapping, T_seq, T_outer) → {port_name: total_reads}
      Total reads per AXI port over the full computation.
  n_chains(mapping) → int
      Number of independent accumulator chains (determines n_threshold).

Adding a new architecture:
  1. Subclass ArchProfile and implement both methods.
  2. Add an instance to PROFILE_REGISTRY under the arch_workload key.
  3. Add the arch_workload to _PROFILE_REGISTRY (ff_args) and
     _GENERATOR_SUPPORTED in model.py once the generator is also implemented.
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Dict

from mapping_types import MappingInfo


class ArchProfile(ABC):
    """Abstract base for architecture-specific AXI port read formulas."""

    @abstractmethod
    def port_reads(self, mapping: MappingInfo,
                   T_seq: int, T_outer: int) -> Dict[str, int]:
        """Return {port_name: total_reads} for the full computation."""

    @abstractmethod
    def n_chains(self, mapping: MappingInfo) -> int:
        """Independent accumulator chains → used as n_threshold in the model."""


class EyerissCONVProfile(ArchProfile):
    """
    Eyeriss 2D convolution: 2 weight banks (w_b0/w_b1) + 2 input banks (in_b0/in_b1),
    split by channel parity (c % 2).
    """
    in_banks: int = 2

    def port_reads(self, mapping: MappingInfo,
                   T_seq: int, T_outer: int) -> Dict[str, int]:
        sacols = mapping.tiling.get("SACols", {}) or {}
        sarows = mapping.tiling.get("SARows", {}) or {}
        m_sf = int(sacols.get("M", 1))
        q_sf = int(sacols.get("Q", 1))
        C_sa = int(sarows.get("C", 1))
        S_sa = int(sarows.get("S", 1))
        n = T_seq * T_outer
        rw = (C_sa // self.in_banks) * S_sa * m_sf * n  # per weight bank
        ri = (C_sa // self.in_banks) * S_sa * q_sf * n  # per input bank
        return {
            "dram_w_b0":  rw,
            "dram_w_b1":  rw,
            "dram_in_b0": ri,
            "dram_in_b1": ri,
        }

    def n_chains(self, mapping: MappingInfo) -> int:
        sacols = mapping.tiling.get("SACols", {}) or {}
        return int(sacols.get("M", 1)) * int(sacols.get("Q", 1))


class EyerissGEMMProfile(ArchProfile):
    """
    Eyeriss GEMM: A[M×K] → 2 weight banks (split by k%2),
                  B[K×N] → 2 input banks  (split by k%2).
    n_sf = 1 (N handled entirely by outer loops, never in SA).
    """
    in_banks: int = 2

    def port_reads(self, mapping: MappingInfo,
                   T_seq: int, T_outer: int) -> Dict[str, int]:
        sacols   = mapping.tiling.get("SACols", {}) or {}
        sarows   = mapping.tiling.get("SARows", {}) or {}
        m_sacols = int(sacols.get("M", 1))
        m_sarows = int(sarows.get("M", 1))
        m_sf     = m_sacols * m_sarows
        k_sa     = int(sacols.get("K", 1))
        n        = T_seq * T_outer
        # Per weight bank: (k_sa/2) K-elements × m_sf M-lanes × n outer tiles
        rw = (k_sa // self.in_banks) * m_sf * n
        # Per input bank:  (k_sa/2) K-elements × 1 N-lane (n_sf=1) × n outer tiles
        ri = (k_sa // self.in_banks) * 1 * n
        return {
            "dram_w_b0": rw, "dram_w_b1": rw,
            "dram_in_b0": ri, "dram_in_b1": ri,
        }

    def n_chains(self, mapping: MappingInfo) -> int:
        sacols = mapping.tiling.get("SACols", {}) or {}
        sarows = mapping.tiling.get("SARows", {}) or {}
        return int(sacols.get("M", 1)) * int(sarows.get("M", 1))  # = m_sf


PROFILE_REGISTRY: Dict[str, ArchProfile] = {
    "eyeriss-conv": EyerissCONVProfile(),
    "eyeriss":      EyerissGEMMProfile(),
}


def get_profile(arch_workload: str) -> ArchProfile:
    key = (arch_workload or "").lower().strip()
    if key not in PROFILE_REGISTRY:
        raise ValueError(
            f"No ArchProfile for {key!r}. Available: {list(PROFILE_REGISTRY)}"
        )
    return PROFILE_REGISTRY[key]
