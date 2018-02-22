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
ExecStep $xv_path/bin/xsim sync_testbench_behav -key {Behavioral:sim_1:Functional:sync_testbench} -tclbatch sync_testbench.tcl -log simulate.log
