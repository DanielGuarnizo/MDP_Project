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

    # Sort bundles numerically — Bambu emits ports in lex order (gmem_0, gmem_10, gmem_11 …
    # before gmem_2 …) which breaks sequential assignment for designs with ≥10 bundles.
    sorted_bundles = sorted(
        axi_bundles, key=lambda b: int(re.search(r'\d+', b).group())
    )

    # Pass 2: sequential assignment for non-output args (inputs, weights).
    # Output args are skipped here — they go to Pass 3 which applies the modular-index
    # rule matching the #pragma HLS interface bundle assignments in the generated C code
    # (output_pN reuses gmem_{N % n_bundles}, sharing the AXI master with the input/weight
    # that uses that port during the read phase, since reads and writes don't overlap).
    remaining = [b for b in sorted_bundles if b not in used]
    non_output = [a for a in unmatched if 'out' not in a.lower()]
    output_unmatched = [a for a in unmatched if 'out' in a.lower()]

    for arg, bundle in zip(non_output, remaining):
        result[arg] = bundle

    # Pass 3: output_pN → sorted_bundles[N % n_bundles]
    n_bundles = len(sorted_bundles)
    still_unmatched = output_unmatched + [a for a in non_output if a not in result]
    for arg in still_unmatched:
        if arg in result:
            continue
        suf = re.search(r'_p(\d+)$', arg)
        if suf:
            idx = int(suf.group(1)) % n_bundles
            result[arg] = sorted_bundles[idx]

    return result
