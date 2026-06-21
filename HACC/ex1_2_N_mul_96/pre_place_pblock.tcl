# pre_place_pblock.tcl
# Runs before place_design via STEPS.PLACE_DESIGN.TCL.PRE.
# Splits Controller_i (left SLR0 half) and Datapath_i (right SLR0 half) to prevent
# routing node conflicts from co-location in the same congested CLB region.
# Consistent with Bambu's output hierarchy; safe no-op if cells are not found.

set ctrl [get_cells -hierarchical -filter {NAME =~ *Controller_i*}]
set dp   [get_cells -hierarchical -filter {NAME =~ *Datapath_i*}]

if {[llength $ctrl] > 0} {
    create_pblock pb_ctrl
    add_cells_to_pblock pb_ctrl $ctrl
    resize_pblock pb_ctrl -add {SLICE_X0Y0:SLICE_X119Y1439}
    puts "INFO: pre_place_pblock — [llength $ctrl] Controller_i cells -> left half"
} else {
    puts "WARNING: pre_place_pblock — no *Controller_i* cells found, skipping"
}

if {[llength $dp] > 0} {
    create_pblock pb_dp
    add_cells_to_pblock pb_dp $dp
    resize_pblock pb_dp -add {SLICE_X120Y0:SLICE_X239Y1439}
    puts "INFO: pre_place_pblock — [llength $dp] Datapath_i cells -> right half"
} else {
    puts "WARNING: pre_place_pblock — no *Datapath_i* cells found, skipping"
}

puts "INFO: pre_place_pblock.tcl done"
