# post_route.tcl — Vivado post-route hook called by v++ via:
#   --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST=<path>/post_route.tcl
#
# Writes impl_1_power_routed.rpt next to this script (the deploy folder).
# Uses an absolute path via [info script] to bypass Vivado's run-relative
# path resolution, which causes "directory does not exist" errors in v++ context.
# Wrapped in catch so a failure here never aborts the overall build.

puts "\n=== post_route.tcl: running report_power ==="
if {[catch {
    set _deploy_dir [file dirname [file normalize [info script]]]
    set _rpt_file   [file join $_deploy_dir "impl_1_power_routed.rpt"]
    set _pb_file    [file join $_deploy_dir "impl_1_power_routed.pb"]
    report_power -file $_rpt_file -pb $_pb_file
    puts "=== Power report written to: $_rpt_file ===\n"
} err]} {
    puts "WARNING: post_route.tcl: report_power failed — $err"
    puts "WARNING: Build continues without power report.\n"
}
