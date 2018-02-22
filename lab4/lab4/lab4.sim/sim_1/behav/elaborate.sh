#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/current"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 4812200445c84191891e858eb9bd13a8 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot sync_testbench_behav xil_defaultlib.sync_testbench xil_defaultlib.glbl -log elaborate.log
