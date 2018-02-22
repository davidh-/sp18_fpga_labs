# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg400-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.cache/wt [current_project]
set_property parent.project_path /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.srcs/sources_1/new/synchronizer.v
  /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.srcs/sources_1/new/sync_testbench.v
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.srcs/constrs_1/imports/constrs_1/PYNQ-Z1_C.xdc
set_property used_in_implementation false [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab4/lab4/lab4.srcs/constrs_1/imports/constrs_1/PYNQ-Z1_C.xdc]


synth_design -top sync_testbench -part xc7z020clg400-3


write_checkpoint -force -noxdef sync_testbench.dcp

catch { report_utilization -file sync_testbench_utilization_synth.rpt -pb sync_testbench_utilization_synth.pb }
