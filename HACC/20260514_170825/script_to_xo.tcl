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

add_files -norecurse [list \
  [file join $SRC_DIR top_level.v] \
  [file join $SRC_DIR top_level_translator.v] \
  [file join $SRC_DIR panda_wrapper.v] \
  [file join $SRC_DIR panda_libtech.v] \
]
update_compile_order -fileset sources_1
set_property top panda_wrapper [current_fileset]
update_compile_order -fileset sources_1

# Package as IP / Vitis kernel
ipx::package_project \
  -root_dir $IP_ROOT \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -force

set_property name         panda [ipx::current_core]
set_property display_name panda [ipx::current_core]
set_property description  "Bambu accelerator wrapped for Vitis" [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property sdx_kernel               true   [ipx::current_core]
set_property sdx_kernel_type          rtl    [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_hs} [ipx::current_core]

set core [ipx::current_core]

# Associate s_axi_control and all AXI masters to ap_clk
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk $core
ipx::associate_bus_interfaces -busif m_axi_gmem_in0 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_in1 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out0 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out1 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out2 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out3 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out4 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out5 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out6 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_out7 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_w0 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_w1 -clock ap_clk [ipx::current_core]

# Remove ports that are not AXI bus interfaces
catch { ipx::remove_bus_interface cache_reset $core }

# s_axi_control register map
set mm [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab [ipx::get_address_blocks reg0 -of_objects $mm]

# AP_CTRL register (required for ap_ctrl_hs protocol)
ipx::add_register CTRL $ab
set_property address_offset 0x000 [ipx::get_registers CTRL -of_objects $ab]
set_property size 32              [ipx::get_registers CTRL -of_objects $ab]

# Scalar argument registers
ipx::add_register dram_in_b0 $ab
ipx::add_register dram_in_b1 $ab
ipx::add_register dram_w_b0 $ab
ipx::add_register dram_w_b1 $ab
ipx::add_register dram_out_b0 $ab
ipx::add_register dram_out_b1 $ab
ipx::add_register dram_out_b2 $ab
ipx::add_register dram_out_b3 $ab
ipx::add_register dram_out_b4 $ab
ipx::add_register dram_out_b5 $ab
ipx::add_register dram_out_b6 $ab
ipx::add_register dram_out_b7 $ab
set_property address_offset 0x010 [ipx::get_registers dram_in_b0 -of_objects $ab]
set_property address_offset 0x018 [ipx::get_registers dram_in_b1 -of_objects $ab]
set_property address_offset 0x020 [ipx::get_registers dram_w_b0 -of_objects $ab]
set_property address_offset 0x028 [ipx::get_registers dram_w_b1 -of_objects $ab]
set_property address_offset 0x030 [ipx::get_registers dram_out_b0 -of_objects $ab]
set_property address_offset 0x038 [ipx::get_registers dram_out_b1 -of_objects $ab]
set_property address_offset 0x040 [ipx::get_registers dram_out_b2 -of_objects $ab]
set_property address_offset 0x048 [ipx::get_registers dram_out_b3 -of_objects $ab]
set_property address_offset 0x050 [ipx::get_registers dram_out_b4 -of_objects $ab]
set_property address_offset 0x058 [ipx::get_registers dram_out_b5 -of_objects $ab]
set_property address_offset 0x060 [ipx::get_registers dram_out_b6 -of_objects $ab]
set_property address_offset 0x068 [ipx::get_registers dram_out_b7 -of_objects $ab]
foreach r {dram_in_b0 dram_in_b1 dram_w_b0 dram_w_b1 dram_out_b0 dram_out_b1 dram_out_b2 dram_out_b3 dram_out_b4 dram_out_b5 dram_out_b6 dram_out_b7} {
  set_property size 32 [ipx::get_registers $r -of_objects $ab]
}

# Associate each register to its AXI master bundle
set regobj [ipx::get_registers dram_in_b0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_in0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_in_b1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_in1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_w_b0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_w0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_w_b1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_w1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b2 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out2 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b3 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out3 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b4 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out4 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b5 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out5 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b6 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out6 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_out_b7 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_out7 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

# Frequency tolerance for ap_clk
ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects $core]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ \
  -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]

set_property core_revision 1 $core
ipx::create_xgui_files $core
ipx::update_checksums   $core
ipx::check_integrity -kernel -xrt $core
ipx::save_core $core

# Create XO
set XO_PATH [file join $XO_DIR "panda.xo"]
package_xo -xo_path $XO_PATH \
  -kernel_name panda \
  -ip_directory $IP_ROOT \
  -ctrl_protocol ap_ctrl_hs

puts "\nDone: $XO_PATH"
