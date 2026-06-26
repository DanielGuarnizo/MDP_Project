# post_route.tcl — Vivado post-route hook called by v++ via:
#   --vivado.prop run.impl_1.STEPS.ROUTE_DESIGN.TCL.POST=<path>/post_route.tcl
#
# Order: 1) power report  2) hold fix  3) tns_cleanup  4) timing snapshot
# All steps wrapped in catch — a failure here never aborts the overall build.

set _deploy_dir [file dirname [file normalize [info script]]]

# 1. Power report
puts "\n=== post_route.tcl: report_power ==="
catch {
    report_power \
        -file [file join $_deploy_dir impl_1_power_routed.rpt] \
        -pb   [file join $_deploy_dir impl_1_power_routed.pb]
    puts "=== Power report written ==="
}

# 2. Explicit hold fix — insert hold buffers where the router left violations.
#    Runs before Vitis's own POST_ROUTE_PHYS_OPT step so that step starts
#    from a hold-clean state and can focus on setup improvement.
puts "\n=== post_route.tcl: phys_opt_design -hold_fix ==="
catch {
    phys_opt_design -hold_fix
    puts "=== hold_fix done ==="
}

# 3. Re-route nets disrupted by hold buffer insertions.
puts "\n=== post_route.tcl: route_design -tns_cleanup ==="
catch {
    route_design -tns_cleanup
    puts "=== tns_cleanup done ==="
}

# 4. Timing snapshot — written unconditionally so build_all.log / perf_analysis
#    can report WNS without opening Vivado.
puts "\n=== post_route.tcl: timing snapshot ==="
catch {
    report_timing_summary \
        -no_detailed_paths \
        -file [file join $_deploy_dir impl_1_timing_summary.txt]
    puts "=== Timing summary written ==="
}

puts "\n=== post_route.tcl: done ===\n"
