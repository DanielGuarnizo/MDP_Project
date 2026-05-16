from .models import Interface


def gen_script_to_xo(iface: Interface) -> str:
    BASE, STEP = 0x10, 0x08
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
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "project"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "ip_pkg"]]
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
set_property top panda_wrapper [current_fileset]
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
package_xo -xo_path $XO_PATH \\
  -kernel_name panda \\
  -ip_directory $IP_ROOT \\
  -ctrl_protocol ap_ctrl_hs

puts "\\nDone: $XO_PATH"
"""


def gen_xo_to_xclbin(iface: Interface, platform: str, target: str, hbm_bank: str) -> str:
    sp_lines = " \\\n".join(
        f"  --connectivity.sp panda_1.{b}:{hbm_bank}" for b in iface.axi_bundles
    )
    return f"""\
#!/usr/bin/env bash
# xo_to_xclbin.sh — links panda.xo into a .xclbin
# Run: bash xo_to_xclbin.sh
# Edit -t to switch between hw_emu and hw

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"

v++ -t {target} \\
  --platform {platform} \\
  --link "${{SCRIPT_DIR}}/xo/panda.xo" \\
{sp_lines} \\
  -o "${{SCRIPT_DIR}}/xo/panda.xclbin"

echo "Generated: ${{SCRIPT_DIR}}/xo/panda.xclbin"
"""
