#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/Xilinx/SDK/current/bin:/opt/Xilinx/Vivado/current/ids_lite/ISE/bin/lin64:/opt/Xilinx/Vivado/current/bin
else
  PATH=/opt/Xilinx/SDK/current/bin:/opt/Xilinx/Vivado/current/ids_lite/ISE/bin/lin64:/opt/Xilinx/Vivado/current/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/opt/Xilinx/Vivado/current/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/opt/Xilinx/Vivado/current/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/cc/eecs151/sp18/class/eecs151-aaq/fpga_labs_sp18/lab2/lab2.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log z1top.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source z1top.tcl -notrace


