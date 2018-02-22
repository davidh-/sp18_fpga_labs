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
echo "xvlog -m64 --relax -prj sync_testbench_vlog.prj"
ExecStep $xv_path/bin/xvlog -m64 --relax -prj sync_testbench_vlog.prj 2>&1 | tee compile.log
