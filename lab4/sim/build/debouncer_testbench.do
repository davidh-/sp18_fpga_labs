proc start {m} {vsim -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver -L secureip work.glbl $m}
start debouncer_testbench
add wave debouncer_testbench/*
add wave debouncer_testbench/DUT/*
add wave debouncer_testbench/DUT/saturating_counter/*
run 1000ms
