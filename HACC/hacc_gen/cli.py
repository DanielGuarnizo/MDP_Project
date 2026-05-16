import argparse
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path

from .gen_config import gen_accel_config
from .gen_host import gen_cmake, gen_harness_cpp, gen_user_config_cmake
from .gen_tcl import gen_script_to_xo, gen_xo_to_xclbin
from .gen_translator import gen_translator_v
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
    p.add_argument('--verilog',  required=True, help='Bambu top_level.v path')
    p.add_argument('--output',   default=None,  help='Output dir (default: HACC/<timestamp>/)')
    p.add_argument('--platform', default='xilinx_u55c_gen3x16_xdma_3_202210_1')
    p.add_argument('--target',   default='hw_emu', choices=['hw_emu', 'hw'])
    p.add_argument('--hbm-bank', default='HBM[0]')
    args = p.parse_args()

    if args.output is None:
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        # __file__ is hacc_gen/cli.py; parent.parent is HACC/
        out = Path(__file__).parent.parent / ts
    else:
        out = Path(args.output)

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

    (src / 'top_level_translator.v').write_text(gen_translator_v(iface))
    print("Generated top_level_translator.v")

    (src / 'panda_wrapper.v').write_text(gen_wrapper_v(iface))
    print("Generated panda_wrapper.v")

    (out / 'script_to_xo.tcl').write_text(gen_script_to_xo(iface))
    print("Generated script_to_xo.tcl")

    xo_sh = out / 'xo_to_xclbin.sh'
    xo_sh.write_text(gen_xo_to_xclbin(iface, args.platform, args.target, args.hbm_bank))
    xo_sh.chmod(0o755)
    print("Generated xo_to_xclbin.sh")

    cfg = gen_accel_config(iface)
    (out / 'accel_config.json').write_text(json.dumps(cfg, indent=2))
    print("Generated accel_config.json")

    (host_src / 'harness.cpp').write_text(gen_harness_cpp())
    (host / 'CMakeLists.txt').write_text(gen_cmake())
    (host / 'UserConfig.cmake').write_text(gen_user_config_cmake())
    (host_inc / '.gitkeep').touch()
    print("Generated host/ (CMakeLists.txt, UserConfig.cmake, src/harness.cpp)")

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
  accel_config.json
  host/src/harness.cpp

Build steps:
  1. vivado -mode batch -source {out}/script_to_xo.tcl
  2. bash {out}/xo_to_xclbin.sh
  3. cmake -S {out}/host -B {out}/host/build
     cmake --build {out}/host/build -j

Run (hw emulation):
  export XCL_EMULATION_MODE=hw_emu
  export LD_LIBRARY_PATH=/opt/xilinx/xrt/lib:$LD_LIBRARY_PATH
  {out}/host/build/bambu_application \\
      {out}/xo/panda.xclbin \\
      {out}/accel_config.json \\
      <input_dir> \\
      <output_dir>
{'═'*60}""")
