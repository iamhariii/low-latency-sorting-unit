# Timing constraint template for an Artix-7 design.
# Replace the clock port name/period and uncomment after confirming your board clock.
# Do not copy arbitrary PACKAGE_PIN assignments: they are board-specific.
#
# create_clock -name sys_clk -period 10.000 [get_ports clk]
#
# Add PACKAGE_PIN and IOSTANDARD constraints for top-level I/O only after
# checking the exact FPGA part and board schematic/master XDC.
