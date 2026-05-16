import re
import sys
from typing import Dict, List

from .models import AXI_SIGNAL_SUFFIXES, CONTROL_PORTS, Interface, PortDecl


def parse_interface(verilog_path: str) -> Interface:
    with open(verilog_path) as f:
        content = f.read()

    buffer_sizes: Dict[str, int] = {}
    for name, size in re.findall(r'--tb-param-size=(\w+):(\d+)', content):
        buffer_sizes[name] = int(size)

    # Find the LAST 'module top_level(' — sub-modules are declared before it
    top_match = None
    for m in re.finditer(r'\bmodule\s+top_level\s*\(', content):
        top_match = m
    if top_match is None:
        sys.exit("ERROR: 'module top_level' not found in the Verilog file.")

    top_start = top_match.start()
    end_m = re.search(r'\bendmodule\b', content[top_start:])
    if end_m is None:
        sys.exit("ERROR: 'endmodule' not found after 'module top_level'.")
    module_text = content[top_start: top_start + end_m.end()]

    port_list_end = module_text.find(');')
    if port_list_end == -1:
        sys.exit("ERROR: could not find end of port list ').'")
    body = module_text[port_list_end + 2:]

    scalar_args: List[str] = []
    for m in re.finditer(r'^\s+input\s+\[31:0\]\s+(\w+)\s*;', body, re.MULTILINE):
        n = m.group(1)
        if n not in CONTROL_PORTS and not n.startswith('m_axi_') and not n.startswith('_'):
            scalar_args.append(n)

    axi_ports: List[PortDecl] = []
    axi_bundle_set: set = set()
    axi_bundles: List[str] = []
    for m in re.finditer(
        r'^\s+(input|output)\s+(?:(\[[^\]]+\])\s+)?(m_axi_\w+)\s*;',
        body, re.MULTILINE
    ):
        direction, width, name = m.group(1), m.group(2), m.group(3)
        axi_ports.append(PortDecl(direction=direction, width=width, name=name))
        bundle = name
        for suf in AXI_SIGNAL_SUFFIXES:
            if name.endswith(suf):
                bundle = name[: -len(suf)]
                break
        if bundle not in axi_bundle_set:
            axi_bundle_set.add(bundle)
            axi_bundles.append(bundle)

    if not scalar_args:
        print("WARNING: no 32-bit scalar inputs found.")
    if not axi_bundles:
        print("WARNING: no m_axi bundles found.")

    arg_to_bundle = _match_args_to_bundles(scalar_args, axi_bundles)
    return Interface(
        scalar_args=scalar_args,
        axi_bundles=axi_bundles,
        arg_to_bundle=arg_to_bundle,
        axi_ports=axi_ports,
        buffer_sizes=buffer_sizes,
    )


def _match_args_to_bundles(scalar_args: List[str], axi_bundles: List[str]) -> Dict[str, str]:
    result: Dict[str, str] = {}
    used: set = set()
    unmatched: List[str] = []

    for arg in scalar_args:
        cand = re.sub(r'^dram_', '', arg)
        cand = re.sub(r'_b(\d+)$', r'\1', cand)
        matched = None
        for bundle in axi_bundles:
            if bundle in used:
                continue
            bsuf = re.sub(r'^m_axi_gmem_?', '', bundle)
            if cand == bsuf:
                matched = bundle
                break
        if matched:
            result[arg] = matched
            used.add(matched)
        else:
            unmatched.append(arg)

    remaining = [b for b in axi_bundles if b not in used]
    for arg, bundle in zip(unmatched, remaining):
        result[arg] = bundle

    return result
