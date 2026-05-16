from dataclasses import dataclass
from typing import Dict, List, Optional

CONTROL_PORTS = frozenset({'clock', 'reset', 'start_port', 'cache_reset', 'done_port'})

AXI_SIGNAL_SUFFIXES = [
    '_awready', '_wready', '_bid', '_bresp', '_buser', '_bvalid',
    '_arready', '_rid', '_rdata', '_rresp', '_rlast', '_ruser', '_rvalid',
    '_awid', '_awaddr', '_awlen', '_awsize', '_awburst', '_awlock',
    '_awcache', '_awprot', '_awqos', '_awregion', '_awuser', '_awvalid',
    '_wdata', '_wstrb', '_wlast', '_wuser', '_wvalid', '_bready',
    '_arid', '_araddr', '_arlen', '_arsize', '_arburst', '_arlock',
    '_arcache', '_arprot', '_arqos', '_arregion', '_aruser', '_arvalid',
    '_rready',
]


@dataclass
class PortDecl:
    direction: str
    width: Optional[str]  # e.g. '[31:0]', or None (1-bit)
    name: str


@dataclass
class Interface:
    scalar_args:   List[str]
    axi_bundles:   List[str]
    arg_to_bundle: Dict[str, str]
    axi_ports:     List[PortDecl]
    buffer_sizes:  Dict[str, int]


def _port_str(direction: str, width: Optional[str], name: str) -> str:
    w = (width + ' ') if width else ''
    return f"  {direction} {w}{name}"


def infer_direction(arg: str) -> str:
    low = arg.lower()
    if 'out' in low:
        return 'output'
    if 'in' in low or low.startswith('w') or '_w_' in low or low.endswith('_w'):
        return 'input'
    return 'inout'
