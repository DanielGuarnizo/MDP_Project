# script.tcl - Vivado 2024.x - packaging RTL kernel + XO

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "second_version"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "ip_pkg"]]
set XO_DIR     [file normalize [file join $SCRIPT_DIR "xo"]]

file mkdir $PROJ_DIR
file mkdir $IP_ROOT
file mkdir $XO_DIR

create_project -force second_version $PROJ_DIR -part xcu55c-fsvh2892-2L-e

add_files -norecurse [list \
  [file join $SRC_DIR bfs.v] \
  [file join $SRC_DIR bfs_translator.v] \
  [file join $SRC_DIR panda_libtech.v] \
]
update_compile_order -fileset sources_1

# Package IP as kernel
ipx::package_project \
  -root_dir $IP_ROOT \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -force

set_property name         panda [ipx::current_core]
set_property display_name panda [ipx::current_core]
set_property description  panda [ipx::current_core]

set_property ipi_drc {ignore_freq_hz true}  [ipx::current_core]
set_property sdx_kernel true                [ipx::current_core]
set_property sdx_kernel_type rtl            [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_hs} [ipx::current_core]

# Associate all bus interfaces to ap_clk
set core [ipx::current_core]

# Associate AXI and control interfaces explicitly to ap_clk
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]

ipx::associate_bus_interfaces -busif m_axi_gmem0   -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem1   -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem2   -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmem3   -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_gmemQ   -clock ap_clk [ipx::current_core]

ipx::remove_bus_interface cache_reset $core

# Registers on s_axi_control memory map reg0 
set mm   [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab   [ipx::get_address_blocks reg0 -of_objects $mm]

ipx::add_register nodes         $ab
ipx::add_register edges         $ab
ipx::add_register starting_node $ab
ipx::add_register level         $ab
ipx::add_register level_counts  $ab
ipx::add_register queue1        $ab
ipx::add_register queue2        $ab

set_property address_offset 0x010 [ipx::get_registers nodes -of_objects $ab]
set_property address_offset 0x018 [ipx::get_registers edges -of_objects $ab]
set_property address_offset 0x020 [ipx::get_registers starting_node -of_objects $ab]
set_property address_offset 0x028 [ipx::get_registers level -of_objects $ab]
set_property address_offset 0x030 [ipx::get_registers level_counts -of_objects $ab]
set_property address_offset 0x038 [ipx::get_registers queue1 -of_objects $ab]
set_property address_offset 0x040 [ipx::get_registers queue2 -of_objects $ab]

foreach r {nodes edges starting_node level level_counts queue1 queue2} {
  set_property size 32 [ipx::get_registers $r -of_objects $ab]
}

# Associate each pointer-like register to its specific m_axi bundle
# Mapping
# nodes        -> gmem0
# edges        -> gmem1
# level        -> gmem2
# level_counts -> gmem3
# queue1/2     -> gmemQ

set reg2busif [dict create \
  nodes        m_axi_gmem0 \
  edges        m_axi_gmem1 \
  level        m_axi_gmem2 \
  level_counts m_axi_gmem3 \
  queue1       m_axi_gmemQ \
  queue2       m_axi_gmemQ \
]

foreach r [dict keys $reg2busif] {
  set regobj [ipx::get_registers $r -of_objects $ab]
  ipx::add_register_parameter ASSOCIATED_BUSIF $regobj
  set_property value [dict get $reg2busif $r] \
    [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects $regobj]
}


ipx::add_register CTRL $ab
set_property address_offset 0x000 [ipx::get_registers CTRL -of_objects $ab]
set_property size 32 [ipx::get_registers CTRL -of_objects $ab]

# FREQ tolerance 
ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects $core]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ -of_objects \
  [ipx::get_bus_interfaces ap_clk -of_objects $core]]

set_property core_revision 2 $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::check_integrity -kernel -xrt $core
ipx::save_core $core

# Create XO
set XO_PATH [file join $XO_DIR "panda.xo"]
package_xo -xo_path $XO_PATH -kernel_name panda -ip_directory $IP_ROOT -ctrl_protocol ap_ctrl_hs

# Optional: archive the IP
set ZIP_PATH [file join $SCRIPT_DIR "user.org_user_panda_1.0.zip"]
ipx::archive_core $ZIP_PATH $core
