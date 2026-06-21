# script_to_xo.tcl — packages write_bm_krnl wrapper as a Vitis XO kernel
# Run: vivado -mode batch -source script_to_xo.tcl

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "vivado"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "build" "ip"]]
set XO_DIR     [file normalize [file join $SCRIPT_DIR "xo"]]

file mkdir $PROJ_DIR $IP_ROOT $XO_DIR

create_project -force project $PROJ_DIR -part xcu55c-fsvh2892-2L-e

add_files -norecurse [list \
  [file join $SRC_DIR write_bm_krnl.v] \
  [file join $SRC_DIR write_bm_krnl_translator.v] \
  [file join $SRC_DIR write_bm_krnl_dut.v] \
]
update_compile_order -fileset sources_1
set_property top write_bm_krnl [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project \
  -root_dir $IP_ROOT \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -force

set_property name         write_bm_krnl [ipx::current_core]
set_property display_name write_bm_krnl [ipx::current_core]
set_property description  "Bambu AXI latency benchmark — write_bm_krnl" [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property sdx_kernel               true  [ipx::current_core]
set_property sdx_kernel_type          rtl   [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_hs} [ipx::current_core]

set core [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk $core
ipx::associate_bus_interfaces -busif m_axi_gmem_0  -clock ap_clk $core

catch { ipx::remove_bus_interface cache_reset $core }

# Clock frequency tolerance
ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects $core]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ \
  -of_objects [ipx::get_bus_interfaces ap_clk -of_objects $core]]

set mm [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab [ipx::get_address_blocks reg0 -of_objects $mm]

# AP_CTRL
ipx::add_register CTRL $ab
set_property address_offset 0x000 [ipx::get_registers CTRL -of_objects $ab]
set_property size 32              [ipx::get_registers CTRL -of_objects $ab]

# Scalar args
ipx::add_register dram_output_p0 $ab
set_property address_offset 0x010 [ipx::get_registers dram_output_p0 -of_objects $ab]
set_property size 32 [ipx::get_registers dram_output_p0 -of_objects $ab]

ipx::add_register n $ab
set_property address_offset 0x014 [ipx::get_registers n -of_objects $ab]
set_property size 32 [ipx::get_registers n -of_objects $ab]

# hw-profile read-only registers
foreach {name off} {
    rd_busy_cycles_lo 0x90  rd_busy_cycles_hi 0x94
    wr_busy_cycles_lo 0x98  wr_busy_cycles_hi 0x9C
    rd_txn_count      0xA0  wr_txn_count      0xA4
} {
    ipx::add_register $name $ab
    set_property address_offset $off [ipx::get_registers $name -of_objects $ab]
    set_property size 32             [ipx::get_registers $name -of_objects $ab]
}

# Link buffer args to the AXI master bundle
set regobj [ipx::get_registers dram_output_p0 -of_objects $ab]
ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
set_property value m_axi_gmem_0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]

set_property core_revision 1 $core
ipx::create_xgui_files $core
ipx::update_checksums  $core
ipx::check_integrity -kernel -xrt $core
ipx::save_core         $core

package_xo -force \
  -xo_path     ${XO_DIR}/write_bm_krnl.xo \
  -kernel_name  write_bm_krnl \
  -ip_directory $IP_ROOT \
  -ctrl_protocol ap_ctrl_hs

puts "XO created: ${XO_DIR}/write_bm_krnl.xo"
