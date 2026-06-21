from .models import Interface


def gen_script_to_xo(iface: Interface) -> str:
    BASE, STEP = 0x10, 0x04
    addr_map = {arg: BASE + i * STEP for i, arg in enumerate(iface.scalar_args)}

    bus_assoc = "\n".join(
        f"ipx::associate_bus_interfaces -busif {b} -clock ap_clk [ipx::current_core]"
        for b in iface.axi_bundles
    )
    reg_adds = "\n".join(
        f"ipx::add_register {arg} $ab" for arg in iface.scalar_args
    )
    reg_offsets = "\n".join(
        f"set_property address_offset 0x{addr_map[arg]:03X} "
        f"[ipx::get_registers {arg} -of_objects $ab]"
        for arg in iface.scalar_args
    )
    reg_sizes = (
        "foreach r {" + " ".join(iface.scalar_args) + "} {\n"
        "  set_property size 32 [ipx::get_registers $r -of_objects $ab]\n"
        "}"
    )
    reg_busif_blocks = []
    for arg in iface.scalar_args:
        bundle = iface.arg_to_bundle.get(arg, "")
        if bundle:
            reg_busif_blocks.append(
                f"set regobj [ipx::get_registers {arg} -of_objects $ab]\n"
                f"ipx::add_register_parameter ASSOCIATED_BUSIF $regobj\n"
                f"set_property value {bundle} "
                f"[ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]"
            )
    reg_busif = "\n\n".join(reg_busif_blocks)

    return f"""\
# script_to_xo.tcl
# Packages the generated panda_wrapper + top_level as a Vitis XO kernel.
# Run: vivado -mode batch -source script_to_xo.tcl

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "vivado"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "build" "ip"]]
set XO_DIR     [file normalize [file join $SCRIPT_DIR "xo"]]

file mkdir $PROJ_DIR
file mkdir $IP_ROOT
file mkdir $XO_DIR

create_project -force project $PROJ_DIR -part xcu55c-fsvh2892-2L-e

add_files -norecurse [list \\
  [file join $SRC_DIR top_level.v] \\
  [file join $SRC_DIR top_level_translator.v] \\
  [file join $SRC_DIR panda_wrapper.v] \\
  [file join $SRC_DIR panda_libtech.v] \\
]
update_compile_order -fileset sources_1
set_property top panda [current_fileset]
update_compile_order -fileset sources_1

# Package as IP / Vitis kernel
ipx::package_project \\
  -root_dir $IP_ROOT \\
  -vendor user.org -library user -taxonomy /UserIP \\
  -import_files -force

set_property name         panda [ipx::current_core]
set_property display_name panda [ipx::current_core]
set_property description  "Bambu accelerator wrapped for Vitis" [ipx::current_core]
set_property ipi_drc {{ignore_freq_hz true}} [ipx::current_core]
set_property sdx_kernel               true   [ipx::current_core]
set_property sdx_kernel_type          rtl    [ipx::current_core]
set_property vitis_drc {{ctrl_protocol ap_ctrl_hs}} [ipx::current_core]

set core [ipx::current_core]

# Associate s_axi_control and all AXI masters to ap_clk
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk $core
{bus_assoc}

# Remove ports that are not AXI bus interfaces
catch {{ ipx::remove_bus_interface cache_reset $core }}

# s_axi_control register map
set mm [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab [ipx::get_address_blocks reg0 -of_objects $mm]

# AP_CTRL register (required for ap_ctrl_hs protocol)
ipx::add_register CTRL $ab
set_property address_offset 0x000 [ipx::get_registers CTRL -of_objects $ab]
set_property size 32              [ipx::get_registers CTRL -of_objects $ab]

# Scalar argument registers
{reg_adds}
{reg_offsets}
{reg_sizes}

# Associate each register to its AXI master bundle
{reg_busif}

# Frequency tolerance for ap_clk
ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects $core]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ \\
  -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]

set_property core_revision 1 $core
ipx::create_xgui_files $core
ipx::update_checksums   $core
ipx::check_integrity -kernel -xrt $core
ipx::save_core $core

# Create XO
set XO_PATH [file join $XO_DIR "panda.xo"]
package_xo -force -xo_path $XO_PATH \\
  -kernel_name panda \\
  -ip_directory $IP_ROOT \\
  -ctrl_protocol ap_ctrl_hs

puts "\\nDone: $XO_PATH"
"""


def gen_build_all_sh() -> str:
    return """\
#!/usr/bin/env bash
# build_all.sh — full build pipeline on hacc-build-01
# Run inside a tmux session: tmux new-session -d -s hacc_build 'bash build_all.sh; echo EXIT=$?; read'
set -eo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$DEPLOY_DIR/build_all.log"
# Rotate previous log so each run starts clean
[ -f "$LOG" ] && mv "$LOG" "$LOG.prev"
exec &> >(tee "$LOG")
echo "=== BUILD START $(date) ==="

# Unset vars that Xilinx scripts expect to exist
export PYTHONPATH="${PYTHONPATH:-}"
export PYTHONHOME="${PYTHONHOME:-}"

# Vivado + Vitis environment
source /tools/Xilinx/Vivado/2024.2/settings64.sh
source /tools/Xilinx/Vitis/2024.2/settings64.sh

# XRT: setup.sh rejects paths not ending in /xrt, so set manually
export XILINX_XRT=/opt/xilinx/xrt_2024.2
export LD_LIBRARY_PATH=$XILINX_XRT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export PATH=$XILINX_XRT/bin${PATH:+:$PATH}
export PYTHONPATH=$XILINX_XRT/python${PYTHONPATH:+:$PYTHONPATH}

echo "=== [1/3] Vivado: .v -> .xo (~10 min) ==="
cd "$DEPLOY_DIR"
vivado -mode batch -source script_to_xo.tcl
echo "=== .xo: $(ls -lh xo/panda.xo) ==="

echo "=== [2/3] v++: .xo -> .xclbin (edit -t flag for hw vs hw_emu, hw takes 4-8h) ==="
bash xo_to_xclbin.sh
echo "=== .xclbin: $(ls -lh xo/panda.xclbin) ==="

echo "=== [3/3] Host application ==="
cmake -S "$DEPLOY_DIR/host" -B "$DEPLOY_DIR/build/host"
cmake --build "$DEPLOY_DIR/build/host" -j$(nproc)
echo "=== Done: $(ls -lh $DEPLOY_DIR/build/host/bambu_application) ==="

touch "${DEPLOY_DIR}/.build_done"
echo "=== BUILD COMPLETE $(date) ==="
"""


def gen_xo_to_xclbin(iface: Interface, platform: str, target: str, hbm_bank: str,
                     routing_directive: str = "AggressiveExplore") -> str:
    import re as _re
    # Spread each AXI master across sequential even HBM banks to reduce routing congestion.
    # e.g. HBM[0] base → gmem_0:HBM[0], gmem_1:HBM[2], gmem_2:HBM[4], ...
    _HBM_MAX = 8  # U55C: HBM[8+] sits at 0x1_0000_0000+ (outside 4GB kernel aperture)
    _m = _re.match(r'HBM\[(\d+)\]', hbm_bank)
    if _m and len(iface.axi_bundles) > 1:
        _base = int(_m.group(1))
        # Sort bundles numerically so gmem_2 < gmem_10, then assign round-robin within valid range
        _sorted = sorted(iface.axi_bundles, key=lambda b: int(_re.search(r'\d+', b).group()))
        _banks_map = {b: f"HBM[{_base + (i % _HBM_MAX)}]" for i, b in enumerate(_sorted)}
        _banks = [_banks_map[b] for b in iface.axi_bundles]
    else:
        _banks = [hbm_bank] * len(iface.axi_bundles)
    # Sort SP lines numerically for readability
    _sp_pairs = sorted(
        [(b, _banks[i]) for i, b in enumerate(iface.axi_bundles)],
        key=lambda x: int(_re.search(r'\d+', x[0]).group())
    )
    sp_lines = " \\\n".join(
        f"  --connectivity.sp panda_1.{b}:{bank}"
        for b, bank in _sp_pairs
    )
    # For hw: routing directives + post-route power report hook.
    # NOTE: --profile_kernel (old API) is DEPRECATED in Vitis 2024.2 and fails to parse even
    # with correct args, silently corrupting impl constraints and causing routing failure at
    # exactly 22,720 stuck overlaps. Removed. The new API is --profile.kernel.port but requires
    # the xo to be built with profiling support at compile time, not just link time.
    # Hardware profiling via APM is not supported in this flow — use xrt.ini software profiling.
    hw_opts_lines = []
    if target == "hw":
        hw_opts_lines = [
            f"  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE={routing_directive} \\",
            "  --vivado.prop run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true \\",
            "  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true \\",
            "  --vivado.prop run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore \\",
            '  "--vivado.prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=${SCRIPT_DIR}/pre_place_pblock.tcl" \\',
            '  --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST="${SCRIPT_DIR}/post_route.tcl" \\',
        ]
    hw_opts = ("\n" + "\n".join(hw_opts_lines)) if hw_opts_lines else ""
    profile_line = ""  # Hardware APM profiling removed (see note above)
    return f"""\
#!/usr/bin/env bash
# xo_to_xclbin.sh — links panda.xo into a .xclbin
# Run: bash xo_to_xclbin.sh
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"

mkdir -p "${{SCRIPT_DIR}}/build/vpp/logs" \
         "${{SCRIPT_DIR}}/build/vpp/tmp" \
         "${{SCRIPT_DIR}}/build/vpp/reports"

v++ -t {target} \\
  --platform {platform} \\
  --link "${{SCRIPT_DIR}}/xo/panda.xo" \\
  --log_dir    "${{SCRIPT_DIR}}/build/vpp/logs" \\
  --temp_dir   "${{SCRIPT_DIR}}/build/vpp/tmp" \\
  --report_dir "${{SCRIPT_DIR}}/build/vpp/reports" \\{hw_opts}
{sp_lines} \\{profile_line}
  -o "${{SCRIPT_DIR}}/xo/panda.xclbin"

echo "Generated: ${{SCRIPT_DIR}}/xo/panda.xclbin"
"""
