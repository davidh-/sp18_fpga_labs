`timescale 1ns / 1ps

//----------------------------------------------------------------------------
// UC Berkeley, EECS 151/251A FPGA Lab
// Lab 2, Spring 2018
// Module: z1top.v 
//----------------------------------------------------------------------------
module z1top (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output aud_pwm,
    output aud_sd
);

    assign aud_sd = 1'b1;
    
    tone_generator tone_test_generator ( 
        .output_enable(SWITCHES[0]),
        .clk(CLK_125MHZ_FPGA),
        .square_wave_out(aud_pwm)
    );

    
    
    structural_adder user_adder (
        .A({11'b0,SWITCHES[0],BUTTONS[1:0]}),
        .B({11'b0,SWITCHES[1],BUTTONS[3:2]}),
        .SUM(LEDS[3:0])       // Upper bits will be truncated
    );

    // Self test of the structural adder
    wire [13:0] adder_operand1, adder_operand2;
    wire [14:0] structural_out, behavioral_out;
    wire test_fail;
    assign LEDS[4] = ~test_fail;
    assign LEDS[5] = ~test_fail;

    structural_adder structural_test_adder (
        .A(adder_operand1),
        .B(adder_operand2),
        .SUM(structural_out)
    );

    behavioral_adder behavioral_test_adder (
        .a(adder_operand1),
        .b(adder_operand2),
        .sum(behavioral_out)
    );

    adder_tester tester (
        .adder_operand1(adder_operand1),
        .adder_operand2(adder_operand2),
        .structural_sum(structural_out),
        .behavioral_sum(behavioral_out),
        .clk(CLK_125MHZ_FPGA),
        .test_fail(test_fail)
    );
endmodule
