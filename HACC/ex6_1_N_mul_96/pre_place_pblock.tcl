# pre_place_pblock.tcl  v3
# Runs before place_design via STEPS.PLACE_DESIGN.TCL.PRE.
# Splits Controller_i (left half) and Datapath_i (right half) within
# pblock_dynamic_SLR0 to prevent routing conflicts from co-location.
#
# v3 changes vs v2:
#   - Queries pblock_dynamic_SLR0 for actual SLICE/DSP/BRAM/URAM bounds
#     instead of hardcoding Y0, so cells cannot land below the Vitis shell floor.
#   - Adds DSP48E2, RAMB18, RAMB36, URAM288 ranges to each sub-pblock so
#     ALL resource types (not just SLICEs) are bounded → fixes HDPR-29.

# ── Helpers ────────────────────────────────────────────────────────────
proc parse_range_bounds {rect tag} {
    # Extract Xa Yb Xc Yd from the first occurrence of "TAG_XaYb:TAG_XcYd" in rect.
    if {[regexp "${tag}_X(\\d+)Y(\\d+):${tag}_X(\\d+)Y(\\d+)" $rect -> x0 y0 x1 y1]} {
        return [list $x0 $y0 $x1 $y1]
    }
    return {}
}

proc midpoint {a b} { return [expr {($a + $b) / 2}] }

# ── Find the SLR0 dynamic pblock ────────────────────────────────────────
set dr_name ""
foreach candidate {pblock_dynamic_SLR0 pblock_dynamic_region} {
    if {[llength [get_pblocks $candidate]] > 0} {
        set dr_name $candidate
        break
    }
}

if {$dr_name eq ""} {
    puts "WARNING: pre_place_pblock — no dynamic pblock found; skipping"
    return
}

set rect [get_property RECTANGLE [get_pblocks $dr_name]]
puts "INFO: pre_place_pblock — $dr_name RECTANGLE = $rect"

# ── Parse per-resource bounds ───────────────────────────────────────────
set slice_b [parse_range_bounds $rect "SLICE"]
set dsp_b   [parse_range_bounds $rect "DSP48E2"]
set rb18_b  [parse_range_bounds $rect "RAMB18"]
set rb36_b  [parse_range_bounds $rect "RAMB36"]
set uram_b  [parse_range_bounds $rect "URAM288"]

if {[llength $slice_b] == 0} {
    puts "WARNING: pre_place_pblock — cannot parse SLICE bounds; skipping"
    return
}
lassign $slice_b sx0 sy0 sx1 sy1
set sxmid [midpoint $sx0 $sx1]

# Build resource range strings for left and right halves
proc make_ranges {bounds tag xmid side} {
    if {[llength $bounds] == 0} { return {} }
    lassign $bounds x0 y0 x1 y1
    # Clamp xmid to within [x0, x1]
    set xm [expr {min(max($xmid, $x0), $x1)}]
    if {$side eq "left"} {
        if {$xm < $x0} { return {} }
        return "${tag}_X${x0}Y${y0}:${tag}_X${xm}Y${y1}"
    } else {
        set xl [expr {$xm + 1}]
        if {$xl > $x1} { return {} }
        return "${tag}_X${xl}Y${y0}:${tag}_X${x1}Y${y1}"
    }
}

# SLICE xmid drives the split for all resource types
# DSP columns are ~8x narrower — find DSP xmid proportionally
set dsp_xmid ""
if {[llength $dsp_b] > 0} {
    lassign $dsp_b dx0 dy0 dx1 dy1
    # Map SLICE midpoint ratio to DSP column space
    set ratio [expr {double($sxmid - $sx0) / double($sx1 - $sx0 + 1)}]
    set dsp_xmid [expr {int($dx0 + $ratio * ($dx1 - $dx0 + 1))}]
}
set rb18_xmid ""
if {[llength $rb18_b] > 0} {
    lassign $rb18_b bx0 by0 bx1 by1
    set ratio [expr {double($sxmid - $sx0) / double($sx1 - $sx0 + 1)}]
    set rb18_xmid [expr {int($bx0 + $ratio * ($bx1 - $bx0 + 1))}]
}
set rb36_xmid $rb18_xmid   ;# RAMB36 and RAMB18 share columns
set uram_xmid ""
if {[llength $uram_b] > 0} {
    lassign $uram_b ux0 uy0 ux1 uy1
    set ratio [expr {double($sxmid - $sx0) / double($sx1 - $sx0 + 1)}]
    set uram_xmid [expr {int($ux0 + $ratio * ($ux1 - $ux0 + 1))}]
}

foreach side {left right} {
    set ranges {}
    lappend ranges [make_ranges $slice_b "SLICE"   $sxmid    $side]
    if {$dsp_xmid  ne ""} { lappend ranges [make_ranges $dsp_b  "DSP48E2" $dsp_xmid  $side] }
    if {$rb18_xmid ne ""} { lappend ranges [make_ranges $rb18_b "RAMB18"  $rb18_xmid $side] }
    if {$rb36_xmid ne ""} { lappend ranges [make_ranges $rb36_b "RAMB36"  $rb36_xmid $side] }
    if {$uram_xmid ne ""} { lappend ranges [make_ranges $uram_b "URAM288" $uram_xmid $side] }
    set ranges [lsearch -all -inline -not $ranges ""]
    set "${side}_ranges" $ranges
    puts "INFO: pre_place_pblock — $side ranges: $ranges"
}

# ── Create sub-pblocks ──────────────────────────────────────────────────
set ctrl [get_cells -hierarchical -filter {NAME =~ *Controller_i*}]
set dp   [get_cells -hierarchical -filter {NAME =~ *Datapath_i*}]

if {[llength $ctrl] > 0} {
    create_pblock pb_ctrl
    add_cells_to_pblock pb_ctrl $ctrl
    foreach r $left_ranges { resize_pblock pb_ctrl -add $r }
    puts "INFO: pre_place_pblock — [llength $ctrl] Controller_i cells -> left"
} else {
    puts "WARNING: pre_place_pblock — no *Controller_i* cells found"
}

if {[llength $dp] > 0} {
    create_pblock pb_dp
    add_cells_to_pblock pb_dp $dp
    foreach r $right_ranges { resize_pblock pb_dp -add $r }
    puts "INFO: pre_place_pblock — [llength $dp] Datapath_i cells -> right"
} else {
    puts "WARNING: pre_place_pblock — no *Datapath_i* cells found"
}

puts "INFO: pre_place_pblock.tcl done"
