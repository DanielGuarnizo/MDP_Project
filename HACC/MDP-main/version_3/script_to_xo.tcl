# script.tcl - Vivado 2024.x - packaging RTL kernel + XO

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJ_DIR   [file normalize [file join $SCRIPT_DIR "build" "progetto_copia"]]
set SRC_DIR    [file normalize [file join $SCRIPT_DIR "src"]]
set IP_ROOT    [file normalize [file join $SCRIPT_DIR "ip_pkg"]]
set XO_DIR     [file normalize [file join $SCRIPT_DIR "xo"]]

file mkdir $PROJ_DIR
file mkdir $IP_ROOT
file mkdir $XO_DIR

create_project -force progetto_copia $PROJ_DIR -part xcu55c-fsvh2892-2L-e

add_files -norecurse [list \
  [file join $SRC_DIR bfs.v] \
  [file join $SRC_DIR bfs_translator.v] \
  [file join $SRC_DIR panda_libtech.v] \
  [file join $SRC_DIR axiAddrHbmInsert.v] \
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

set_property ipi_drc {ignore_freq_hz true}          [ipx::current_core]
set_property sdx_kernel true                        [ipx::current_core]
set_property sdx_kernel_type rtl                    [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_hs}   [ipx::current_core]

# --- Bus associations: no more m_axi_gmem, use m_axi_0 and m_axi_1 ---
ipx::associate_bus_interfaces -busif m_axi_0        -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m_axi_1        -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi_control  -clock ap_clk [ipx::current_core]

# Registers on s_axi_control memory map reg0 (assumed to exist)
set core [ipx::current_core]
set mm   [ipx::get_memory_maps s_axi_control -of_objects $core]
set ab   [ipx::get_address_blocks reg0 -of_objects $mm]

# --- Add registers: *_0 + starting_node + *_1 ---
# Bank 0
ipx::add_register nodes_0        $ab
ipx::add_register edges_0        $ab
# Unique scalar
ipx::add_register starting_node  $ab
ipx::add_register level_0        $ab
ipx::add_register level_counts_0 $ab
ipx::add_register queue1_0       $ab
ipx::add_register queue2_0       $ab

# Bank 1
ipx::add_register nodes_1        $ab
ipx::add_register edges_1        $ab
ipx::add_register level_1        $ab
ipx::add_register level_counts_1 $ab
ipx::add_register queue1_1       $ab
ipx::add_register queue2_1       $ab

# --- Offsets: (stride 0x8) ---
# Original layout preserved for *_0 and starting_node:
# 0x10 nodes, 0x18 edges, 0x20 starting_node, 0x28 level, 0x30 level_counts, 0x38 queue1, 0x40 queue2
set_property address_offset 0x010 [ipx::get_registers nodes_0 -of_objects $ab]
set_property address_offset 0x018 [ipx::get_registers edges_0 -of_objects $ab]
set_property address_offset 0x020 [ipx::get_registers starting_node -of_objects $ab]
set_property address_offset 0x028 [ipx::get_registers level_0 -of_objects $ab]
set_property address_offset 0x030 [ipx::get_registers level_counts_0 -of_objects $ab]
set_property address_offset 0x038 [ipx::get_registers queue1_0 -of_objects $ab]
set_property address_offset 0x040 [ipx::get_registers queue2_0 -of_objects $ab]

# Continue after 0x040 with same stride for *_1
set_property address_offset 0x048 [ipx::get_registers nodes_1 -of_objects $ab]
set_property address_offset 0x050 [ipx::get_registers edges_1 -of_objects $ab]
set_property address_offset 0x058 [ipx::get_registers level_1 -of_objects $ab]
set_property address_offset 0x060 [ipx::get_registers level_counts_1 -of_objects $ab]
set_property address_offset 0x068 [ipx::get_registers queue1_1 -of_objects $ab]
set_property address_offset 0x070 [ipx::get_registers queue2_1 -of_objects $ab]

# Sizes 32 for all 
foreach r {nodes_0 edges_0 starting_node level_0 level_counts_0 queue1_0 queue2_0 \
           nodes_1 edges_1 level_1 level_counts_1 queue1_1 queue2_1} {
  set_property size 32 [ipx::get_registers $r -of_objects $ab]
}

# --- Associate pointer-like registers to the correct AXI master ---
# *_0 -> m_axi_0
foreach r {nodes_0 edges_0 level_0 level_counts_0 queue1_0 queue2_0} {
  ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers $r -of_objects $ab]
  set_property value m_axi_0 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects \
    [ipx::get_registers $r -of_objects $ab]]
}

# *_1 -> m_axi_1
foreach r {nodes_1 edges_1 level_1 level_counts_1 queue1_1 queue2_1} {
  ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers $r -of_objects $ab]
  set_property value m_axi_1 [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects \
    [ipx::get_registers $r -of_objects $ab]]
}

# CTRL register (ap_ctrl_hs) at 0x000
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

