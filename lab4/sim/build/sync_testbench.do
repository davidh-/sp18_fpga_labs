proc start {m} {vsim -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver -L secureip work.glbl $m}
start sync_testbench
add wave sync_testbench/*
add wave sync_testbench/DUT/*
run 1000ms
