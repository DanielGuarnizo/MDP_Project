from __future__ import annotations

from dataclasses import dataclass
from typing import List

from mapping_types import MappingInfo


@dataclass(frozen=True)
class ConvBankSpec:
    """AXI port counts for input, weight, and output channels."""
    input_ports: int
    weight_ports: int
    physical_ports: int
    output_ports: int      # min(N_out, physical_ports)


def _infer_eyeriss_port_spec(mapping: MappingInfo, n_out: int, physical_ports: int) -> ConvBankSpec:
    tiling = getattr(mapping, "tiling", {}) or {}
    sarows = tiling.get("SARows", {}) or {}
    sacols = tiling.get("SACols", {}) or {}
    input_ports = 1
    for lvl_tiling in (sarows, sacols):
        for dim, fac in lvl_tiling.items():
            if dim == 'C':
                input_ports *= int(fac)
    input_ports = max(1, input_ports)
    weight_ports = input_ports
    output_ports = min(n_out, physical_ports)
    return ConvBankSpec(
        input_ports=input_ports,
        weight_ports=weight_ports,
        physical_ports=physical_ports,
        output_ports=output_ports,
    )


def _emit_headers_and_pragmas(
    input_ports: int,
    weight_ports: int,
    output_ports: int,
    physical_ports: int,
) -> str:
    """Emit #define and AXI pragma block.

    All port types share the same physical_ports bundles via modulo, so
    exactly physical_ports unique gmem_N names are emitted regardless of
    how many logical ports exist.
    """
    lines = []
    lines.append("#define DTYPE float")
    lines.append("")
    lines.append("/* AXI pragmas: inputs and outputs share bundles (time-multiplexed) */")
    for i in range(input_ports):
        lines.append(
            f"#pragma HLS interface port = dram_input_p{i} mode = m_axi offset = direct bundle = gmem_{i % physical_ports}"
        )
    for i in range(weight_ports):
        lines.append(
            f"#pragma HLS interface port = dram_weight_p{i} mode = m_axi offset = direct bundle = gmem_{i % physical_ports}"
        )
    for i in range(output_ports):
        lines.append(
            f"#pragma HLS interface port = dram_output_p{i} mode = m_axi offset = direct bundle = gmem_{i % physical_ports}"
        )
    lines.append("")
    return "\n".join(lines)


def _emit_top_signature(input_ports: int, weight_ports: int, output_ports: int) -> str:
    args: List[str] = []
    for i in range(input_ports):
        args.append(f"DTYPE *dram_input_p{i}")
    for i in range(weight_ports):
        args.append(f"DTYPE *dram_weight_p{i}")
    for i in range(output_ports):
        args.append(f"DTYPE *dram_output_p{i}")
    return "void top_level(" + ", ".join(args) + ")"
