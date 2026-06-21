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

add_files -norecurse [list \
  [file join $SRC_DIR top_level.v] \
  [file join $SRC_DIR top_level_translator.v] \
  [file join $SRC_DIR panda_wrapper.v] \
  [file join $SRC_DIR panda_libtech.v] \
]
update_compile_order -fileset sources_1
set_property top panda [current_fileset]
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
ipx::associate_bus_interfaces -busif m_axi_gmem_0 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_10 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_11 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_12 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_13 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_14 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_15 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_16 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_17 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_18 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_19 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_1 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_20 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_21 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_22 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_23 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_2 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_3 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_4 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_5 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_6 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_7 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_8 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem_9 -clock ap_clk [ipx::current_core]

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
ipx::add_register dram_input_p0 $ab
ipx::add_register dram_input_p1 $ab
ipx::add_register dram_input_p2 $ab
ipx::add_register dram_input_p3 $ab
ipx::add_register dram_weight_p0 $ab
ipx::add_register dram_weight_p1 $ab
ipx::add_register dram_weight_p2 $ab
ipx::add_register dram_weight_p3 $ab
ipx::add_register dram_output_p0 $ab
ipx::add_register dram_output_p1 $ab
ipx::add_register dram_output_p2 $ab
ipx::add_register dram_output_p3 $ab
ipx::add_register dram_output_p4 $ab
ipx::add_register dram_output_p5 $ab
ipx::add_register dram_output_p6 $ab
ipx::add_register dram_output_p7 $ab
ipx::add_register dram_output_p8 $ab
ipx::add_register dram_output_p9 $ab
ipx::add_register dram_output_p10 $ab
ipx::add_register dram_output_p11 $ab
ipx::add_register dram_output_p12 $ab
ipx::add_register dram_output_p13 $ab
ipx::add_register dram_output_p14 $ab
ipx::add_register dram_output_p15 $ab
ipx::add_register dram_output_p16 $ab
ipx::add_register dram_output_p17 $ab
ipx::add_register dram_output_p18 $ab
ipx::add_register dram_output_p19 $ab
ipx::add_register dram_output_p20 $ab
ipx::add_register dram_output_p21 $ab
ipx::add_register dram_output_p22 $ab
ipx::add_register dram_output_p23 $ab
set_property address_offset 0x010 [ipx::get_registers dram_input_p0 -of_objects $ab]
set_property address_offset 0x018 [ipx::get_registers dram_input_p1 -of_objects $ab]
set_property address_offset 0x020 [ipx::get_registers dram_input_p2 -of_objects $ab]
set_property address_offset 0x028 [ipx::get_registers dram_input_p3 -of_objects $ab]
set_property address_offset 0x030 [ipx::get_registers dram_weight_p0 -of_objects $ab]
set_property address_offset 0x038 [ipx::get_registers dram_weight_p1 -of_objects $ab]
set_property address_offset 0x040 [ipx::get_registers dram_weight_p2 -of_objects $ab]
set_property address_offset 0x048 [ipx::get_registers dram_weight_p3 -of_objects $ab]
set_property address_offset 0x050 [ipx::get_registers dram_output_p0 -of_objects $ab]
set_property address_offset 0x058 [ipx::get_registers dram_output_p1 -of_objects $ab]
set_property address_offset 0x060 [ipx::get_registers dram_output_p2 -of_objects $ab]
set_property address_offset 0x068 [ipx::get_registers dram_output_p3 -of_objects $ab]
set_property address_offset 0x070 [ipx::get_registers dram_output_p4 -of_objects $ab]
set_property address_offset 0x078 [ipx::get_registers dram_output_p5 -of_objects $ab]
set_property address_offset 0x080 [ipx::get_registers dram_output_p6 -of_objects $ab]
set_property address_offset 0x088 [ipx::get_registers dram_output_p7 -of_objects $ab]
set_property address_offset 0x090 [ipx::get_registers dram_output_p8 -of_objects $ab]
set_property address_offset 0x098 [ipx::get_registers dram_output_p9 -of_objects $ab]
set_property address_offset 0x0A0 [ipx::get_registers dram_output_p10 -of_objects $ab]
set_property address_offset 0x0A8 [ipx::get_registers dram_output_p11 -of_objects $ab]
set_property address_offset 0x0B0 [ipx::get_registers dram_output_p12 -of_objects $ab]
set_property address_offset 0x0B8 [ipx::get_registers dram_output_p13 -of_objects $ab]
set_property address_offset 0x0C0 [ipx::get_registers dram_output_p14 -of_objects $ab]
set_property address_offset 0x0C8 [ipx::get_registers dram_output_p15 -of_objects $ab]
set_property address_offset 0x0D0 [ipx::get_registers dram_output_p16 -of_objects $ab]
set_property address_offset 0x0D8 [ipx::get_registers dram_output_p17 -of_objects $ab]
set_property address_offset 0x0E0 [ipx::get_registers dram_output_p18 -of_objects $ab]
set_property address_offset 0x0E8 [ipx::get_registers dram_output_p19 -of_objects $ab]
set_property address_offset 0x0F0 [ipx::get_registers dram_output_p20 -of_objects $ab]
set_property address_offset 0x0F8 [ipx::get_registers dram_output_p21 -of_objects $ab]
set_property address_offset 0x100 [ipx::get_registers dram_output_p22 -of_objects $ab]
set_property address_offset 0x108 [ipx::get_registers dram_output_p23 -of_objects $ab]
foreach r {dram_input_p0 dram_input_p1 dram_input_p2 dram_input_p3 dram_weight_p0 dram_weight_p1 dram_weight_p2 dram_weight_p3 dram_output_p0 dram_output_p1 dram_output_p2 dram_output_p3 dram_output_p4 dram_output_p5 dram_output_p6 dram_output_p7 dram_output_p8 dram_output_p9 dram_output_p10 dram_output_p11 dram_output_p12 dram_output_p13 dram_output_p14 dram_output_p15 dram_output_p16 dram_output_p17 dram_output_p18 dram_output_p19 dram_output_p20 dram_output_p21 dram_output_p22 dram_output_p23} {
  set_property size 32 [ipx::get_registers $r -of_objects $ab]
}

# Associate each register to its AXI master bundle
set regobj [ipx::get_registers dram_input_p0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_input_p1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_input_p2 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_2 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_input_p3 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_3 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_weight_p0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_4 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_weight_p1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_5 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_weight_p2 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_6 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_weight_p3 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_7 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p1 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p2 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_2 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p3 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_3 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p4 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_4 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p5 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_5 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p6 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_6 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p7 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_7 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p8 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_8 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p9 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_9 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p10 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_10 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p11 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_11 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p12 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_12 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p13 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_13 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p14 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_14 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p15 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_15 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p16 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_16 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p17 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_17 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p18 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_18 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p19 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_19 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p20 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_20 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p21 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_21 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p22 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_22 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set regobj [ipx::get_registers dram_output_p23 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_23 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

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
package_xo -force -xo_path $XO_PATH \
  -kernel_name panda \
  -ip_directory $IP_ROOT \
  -ctrl_protocol ap_ctrl_hs

puts "\nDone: $XO_PATH"
