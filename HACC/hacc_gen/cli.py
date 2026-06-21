import argparse
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

from .gen_config import gen_accel_config
from .gen_host import gen_cmake, gen_harness_cpp, gen_user_config_cmake
from .gen_tcl import gen_build_all_sh, gen_script_to_xo, gen_xo_to_xclbin
from .gen_translator import gen_translator_v
from .gen_verify import gen_verify_py, parse_output_port_mapping
from .gen_wrapper import gen_wrapper_v
from .models import infer_direction
from .parser import parse_interface

_DOC = """\
generate_hacc_project.py
========================
Converts a Bambu-generated top_level.v into a complete HACC/Vitis deployment folder.

Usage:
  python generate_hacc_project.py \\
      --verilog   path/to/top_level.v \\
      [--output   path/to/output_dir/]   # default: HACC/<timestamp>/
      [--platform xilinx_u55c_gen3x16_xdma_3_202210_1]
      [--target   hw_emu|hw]             # default: hw_emu
      [--hbm-bank HBM[0]]               # default: HBM[0]

panda_libtech.v is resolved automatically from HACC/lib/panda_libtech.v.
"""


def main() -> None:
    p = argparse.ArgumentParser(
        description=_DOC,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument('--verilog',  default=None, help='Bambu top_level.v path (required unless --verify-only)')
    p.add_argument('--output',   default=None,  help='Output dir (default: HACC/<timestamp>/)')
    p.add_argument('--platform', default='xilinx_u55c_gen3x16_xdma_3_202210_1')
    p.add_argument('--target',   default='hw',     choices=['hw_emu', 'hw'])
    p.add_argument('--hbm-bank', default='HBM[0]')
    p.add_argument('--workload', default=None, choices=['conv', 'gemm'],
                   help='Workload type (enables workload section in accel_config.json)')
    p.add_argument('--dims',     default=None, nargs='+', type=int,
                   help='Workload dims: M P Q C R S (conv) or M K N (gemm)')
    p.add_argument('--hw-profile', action='store_true', default=False,
                   help='Embed AXI latency counters (rd/wr busy-cycles + txn-count) '
                        'readable via XRT after kernel done. Adds ~200 FFs. '
                        'Omit for large designs where only correctness matters.')
    p.add_argument('--routing-directive',
                   default='AggressiveExplore',
                   choices=['AggressiveExplore', 'Explore',
                            'NoTimingRelaxation', 'Default', 'AlternateCLBRouting'],
                   help='Vivado route_design directive (default: AggressiveExplore; '
                        'use Explore when AggressiveExplore leaves 1-2 overlaps; '
                        'avoid AlternateCLBRouting — conflicts with U55C platform IPs)')
    p.add_argument('--c-source', default=None, metavar='PATH',
                   help='Path to top_level_sa.c — enables per-deploy verify.py '
                        'with exact PORT_TO_MQ table baked in (no formula inference).')
    p.add_argument('--verify-only', action='store_true', default=False,
                   help='Only (re)generate verify.py for an existing deploy folder. '
                        'Requires --output (existing dir) and --c-source. '
                        'Skips all RTL/host/tcl generation.')
    args = p.parse_args()

    if not args.verify_only and args.verilog is None:
        p.error("--verilog is required (unless --verify-only is set)")

    if args.output is None:
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        # __file__ is hacc_gen/cli.py; parent.parent is HACC/
        out = Path(__file__).parent.parent / ts
    else:
        out = Path(args.output)

    # ── verify-only mode: regenerate verify.py for an existing deploy folder ──
    if args.verify_only:
        if not args.c_source:
            sys.exit("ERROR: --verify-only requires --c-source <path/to/top_level_sa.c>")
        cfg_path = out / 'accel_config.json'
        if not cfg_path.exists():
            sys.exit(f"ERROR: --verify-only requires an existing deploy folder with "
                     f"accel_config.json, not found at {cfg_path}")
        cfg = json.loads(cfg_path.read_text())
        wl = cfg.get('workload', {})
        M = wl.get('M') or wl.get('m')
        P = wl.get('P') or wl.get('p')
        Q = wl.get('Q') or wl.get('q')
        if not all([M, P, Q]):
            sys.exit("ERROR: accel_config.json missing workload.M/P/Q — "
                     "was the folder generated with --workload conv --dims?")
        print(f"[verify-only] parsing {args.c_source}")
        port_to_mq = parse_output_port_mapping(args.c_source)
        print(f"[verify-only] {len(port_to_mq)} output ports, M={M} P={P} Q={Q}")
        verify_code = gen_verify_py(port_to_mq, int(M), int(P), int(Q))
        verify_path = out / 'verify.py'
        verify_path.write_text(verify_code)
        verify_path.chmod(0o755)
        print(f"[verify-only] wrote {verify_path}")
        return

    src      = out / 'src'
    host     = out / 'host'
    host_src = host / 'src'
    host_inc = host / 'include'
    xo_dir   = out / 'xo'
    for d in [src, host_src, host_inc, xo_dir]:
        d.mkdir(parents=True, exist_ok=True)

    print(f"\nParsing: {args.verilog}")
    iface = parse_interface(args.verilog)
    print(f"  scalar args  : {iface.scalar_args}")
    print(f"  AXI bundles  : {iface.axi_bundles}")
    print(f"  arg→bundle   : {iface.arg_to_bundle}")
    print(f"  buffer sizes : {iface.buffer_sizes}")
    print(f"  directions   : { {a: infer_direction(a) for a in iface.scalar_args} }")
    print()

    lib_path = Path(__file__).parent.parent / 'lib' / 'panda_libtech.v'
    if not lib_path.exists():
        sys.exit(
            f"ERROR: panda_libtech.v not found at {lib_path}\n"
            f"Place panda_libtech.v in HACC/lib/ to use this generator."
        )

    shutil.copy(args.verilog, src / 'top_level.v')
    shutil.copy(lib_path,     src / 'panda_libtech.v')
    print("Copied top_level.v + panda_libtech.v")

    hw_profile = args.hw_profile

    (src / 'top_level_translator.v').write_text(gen_translator_v(iface, hw_profile=hw_profile))
    print("Generated top_level_translator.v")

    (src / 'panda_wrapper.v').write_text(gen_wrapper_v(iface, hw_profile=hw_profile))
    print("Generated panda_wrapper.v")

    (out / 'script_to_xo.tcl').write_text(gen_script_to_xo(iface))
    print("Generated script_to_xo.tcl")

    xo_sh = out / 'xo_to_xclbin.sh'
    xo_sh.write_text(gen_xo_to_xclbin(iface, args.platform, args.target, args.hbm_bank,
                                       args.routing_directive))
    xo_sh.chmod(0o755)
    print("Generated xo_to_xclbin.sh")

    cfg = gen_accel_config(iface, args.workload, args.dims)
    (out / 'accel_config.json').write_text(json.dumps(cfg, indent=2))
    print("Generated accel_config.json")

    (host_src / 'harness.cpp').write_text(gen_harness_cpp(hw_profile=hw_profile))
    (host / 'CMakeLists.txt').write_text(gen_cmake())
    (host / 'UserConfig.cmake').write_text(gen_user_config_cmake())
    (host_inc / '.gitkeep').touch()
    print("Generated host/ (CMakeLists.txt, UserConfig.cmake, src/harness.cpp)")

    build_sh = out / 'build_all.sh'
    build_sh.write_text(gen_build_all_sh())
    build_sh.chmod(0o755)
    print("Generated build_all.sh")

    shutil.copy(Path(__file__).parent.parent / 'lib' / 'xrt.ini',              out / 'xrt.ini')
    shutil.copy(Path(__file__).parent.parent / 'lib' / 'post_route.tcl',      out / 'post_route.tcl')
    shutil.copy(Path(__file__).parent.parent / 'lib' / 'pre_place_pblock.tcl', out / 'pre_place_pblock.tcl')
    print("Copied xrt.ini + post_route.tcl + pre_place_pblock.tcl")

    if args.workload and args.dims:
        import subprocess
        gen_inputs_path = Path(__file__).parent.parent / 'gen_inputs.py'
        subprocess.run([sys.executable, str(gen_inputs_path), str(out)], check=True)
        print("[gen_inputs] input_data/ generated")

    if args.c_source:
        print(f"\nParsing output port mapping from: {args.c_source}")
        port_to_mq = parse_output_port_mapping(args.c_source)
        cfg = json.loads((out / 'accel_config.json').read_text())
        wl  = cfg.get('workload', {})
        M_v = int(wl.get('M') or wl.get('m', 0))
        P_v = int(wl.get('P') or wl.get('p', 0))
        Q_v = int(wl.get('Q') or wl.get('q', 0))
        verify_code = gen_verify_py(port_to_mq, M_v, P_v, Q_v)
        verify_path = out / 'verify.py'
        verify_path.write_text(verify_code)
        verify_path.chmod(0o755)
        print(f"Generated verify.py  ({len(port_to_mq)} output ports, M={M_v} P={P_v} Q={Q_v})")

    print(f"""
{'═'*60}
Output folder: {out}

  src/
    top_level.v            ← Bambu core (unchanged)
    panda_libtech.v        ← Bambu stdlib (unchanged)
    top_level_translator.v ← AXI-Lite slave
    panda_wrapper.v        ← Vitis top module (kernel: panda)
  script_to_xo.tcl
  xo_to_xclbin.sh
  build_all.sh
  accel_config.json
  host/src/harness.cpp

Build steps:
  1. vivado -mode batch -source {out}/script_to_xo.tcl
  2. bash {out}/xo_to_xclbin.sh
  3. cmake -S {out}/host -B {out}/build/host
     cmake --build {out}/build/host -j

Run (on alveo node):
  export LD_LIBRARY_PATH=/opt/xilinx/xrt/lib:$LD_LIBRARY_PATH
  {out}/build/host/bambu_application \\
      {out}/xo/panda.xclbin \\
      {out}/accel_config.json \\
      <input_dir> \\
      <output_dir>

Automate full pipeline from local machine:
  bash deploy_and_run.sh build {out}
  bash deploy_and_run.sh run   {out} <alveo_host> <input_data_dir>
{'═'*60}
hw-profile counters: {'ENABLED  (--hw-profile)' if hw_profile else 'DISABLED (omit --hw-profile for large builds)'}
{'═'*60}""")
