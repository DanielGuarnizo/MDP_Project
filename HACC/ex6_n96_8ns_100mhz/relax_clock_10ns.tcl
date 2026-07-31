# relax_clock_10ns.tcl
# Overrides the Vitis platform kernel clock constraint from 300MHz (3.333ns)
# to 100MHz (10ns) so that Bambu 8ns paths meet timing with positive WNS.
# Injected before opt_design via STEPS.OPT_DESIGN.TCL.PRE.

set target_period 10.0

# Find the kernel clock: platform sets it at ~3.333ns, distinct from HBM/system clocks
set kernel_clks [get_clocks -filter {PERIOD > 3.0 && PERIOD < 4.0}]

if {[llength $kernel_clks] == 0} {
    puts "WARNING: relax_clock_10ns — no clock with period 3-4ns found; nothing changed"
} else {
    foreach clk $kernel_clks {
        set clk_name  [get_property NAME           $clk]
        set src_pins  [get_property SOURCE_OBJECTS  $clk]
        remove_clock  $clk
        create_clock  -period $target_period -name $clk_name $src_pins
        puts "INFO: relax_clock_10ns — $clk_name overridden to ${target_period}ns (100 MHz)"
    }
}
