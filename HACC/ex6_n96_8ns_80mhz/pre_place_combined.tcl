# pre_place_combined.tcl
# Wrapper: runs clock relaxation first, then pblock split.
set SCRIPT_DIR [file dirname [file normalize [info script]]]
source [file join $SCRIPT_DIR relax_clock_10ns.tcl]
source [file join $SCRIPT_DIR pre_place_pblock.tcl]
