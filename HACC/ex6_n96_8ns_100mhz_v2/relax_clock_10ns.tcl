# relax_clock_10ns.tcl
# Overrides platform kernel clock from 300MHz (3.333ns) to 100MHz (10ns).
# Injected before opt_design, place_design, and route_design.
#
# The kernel clock is a generated clock (create_generated_clock in platform XDC),
# so SOURCE_OBJECTS is undefined. Uses catch + multiple fallback methods.

set target_period 10.0
set kernel_clks [get_clocks -filter {PERIOD > 3.0 && PERIOD < 4.0}]

puts "INFO: relax_clock_10ns.tcl — found [llength $kernel_clks] clock(s) in 3-4ns range"

if {[llength $kernel_clks] == 0} {
    puts "WARNING: relax_clock_10ns.tcl — no kernel clock found; constraint NOT changed"
    report_clocks
} else {
    foreach clk $kernel_clks {
        set clk_name [get_property NAME $clk]
        set old_period [get_property PERIOD $clk]
        puts "INFO: attempting to relax clock '$clk_name' from ${old_period}ns to ${target_period}ns"

        set done 0

        # METHOD 1: primary clock — SOURCE_OBJECTS
        if {!$done} {
            set src {}
            catch {set src [get_property SOURCE_OBJECTS $clk]}
            if {[llength $src] > 0} {
                if {![catch {create_clock -period $target_period -name $clk_name $src} err]} {
                    puts "INFO: METHOD1 (SOURCE_OBJECTS) success — $clk_name=[get_property PERIOD [get_clocks $clk_name]]ns src=$src"
                    set done 1
                } else {
                    puts "INFO: METHOD1 create_clock failed: $err"
                }
            }
        }

        # METHOD 2: generated clock — find CLKOUT pin of generating cell via MASTER_PINS
        if {!$done} {
            set mpin {}
            catch {set mpin [get_property MASTER_PINS $clk]}
            if {[llength $mpin] > 0} {
                set gen_cell [get_cells -of_objects [get_nets -of_objects $mpin] -filter {DIRECTION == OUT}]
                set clkout_pin [get_pins -of_objects $gen_cell -filter {IS_CLOCK && DIRECTION == OUT}]
                if {[llength $clkout_pin] > 0} {
                    if {![catch {create_clock -period $target_period -name $clk_name [lindex $clkout_pin 0]} err]} {
                        puts "INFO: METHOD2 (MASTER_PINS→CLKOUT) success — $clk_name=[get_property PERIOD [get_clocks $clk_name]]ns"
                        set done 1
                    } else {
                        puts "INFO: METHOD2 create_clock failed: $err"
                    }
                }
            }
        }

        # METHOD 3: driver pin of first clock net
        if {!$done} {
            set first_net [lindex [get_nets -of_objects $clk] 0]
            if {$first_net ne {}} {
                set drv [get_pins -of_objects $first_net -filter {DIRECTION == OUT && IS_CLOCK}]
                if {[llength $drv] > 0} {
                    if {![catch {create_clock -period $target_period -name $clk_name [lindex $drv 0]} err]} {
                        puts "INFO: METHOD3 (net driver pin) success — $clk_name=[get_property PERIOD [get_clocks $clk_name]]ns"
                        set done 1
                    } else {
                        puts "INFO: METHOD3 create_clock failed: $err"
                    }
                }
            }
        }

        if {!$done} {
            puts "WARNING: relax_clock_10ns.tcl — ALL METHODS FAILED for clock '$clk_name'"
            puts "WARNING: implementation will proceed with original ${old_period}ns constraint (WNS will be negative)"
        }
    }
}
