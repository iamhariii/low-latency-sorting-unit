# Run from the Vivado Tcl Console or: vivado -mode batch -source scripts/create_project.tcl
# Override PART on invocation if needed:
# vivado -mode batch -source scripts/create_project.tcl -tclargs xc7a35tcpg236-1
set part_name "xc7a35tcpg236-1"
if {$argc > 0} {
    set part_name [lindex $argv 0]
}
create_project low_latency_sorting_unit ./vivado_project -part $part_name -force
add_files ./rtl/low_latency_sorter.sv
add_files -fileset sim_1 ./tb/tb_low_latency_sorter.sv
add_files -fileset constrs_1 ./constraints/artix7_template.xdc
set_property top low_latency_sorter [get_filesets sources_1]
set_property top tb_low_latency_sorter [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Project created for $part_name. Set the correct board constraints before implementation."
