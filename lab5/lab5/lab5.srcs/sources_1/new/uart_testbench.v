`timescale 1ns/1ps

`define CLOCK_PERIOD 8
`define CLOCK_FREQ 125_000_000
`define BAUD_RATE 115_200

/*
    In this testbench, we instantiate 2 UARTs. They are connected via the serial lines (FPGA_SERIAL_RX/TX).
    Our testbench is given access to the 1st UART's transmitter's ready/valid interface and the 2nd UART's
    receiver's ready/valid interface. The testbench then directs the transmitter to send a character and then
    waits for the receiver to acknowlege that data has been sent to it. It then reads the data from the receiver
    and compares it to what was transmitted.
*/
module uart_testbench();
    // Generate 125 MHz clock
    reg clk = 0;
    always #(`CLOCK_PERIOD/2) clk = ~clk;

    // I/O of off-chip and on-chip UART
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;
    reg reset;

    reg [7:0] data_in;
    reg data_in_valid;
    wire data_in_ready;

    wire [7:0] data_out;
    wire data_out_valid;
    reg data_out_ready;

    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) off_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(), // We aren't using the receiver of the off-chip UART, only the transmitter
        .data_out_valid(),
        .data_out_ready(),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(), // We aren't using the transmitter of the on-chip UART, only the receiver
        .data_in_valid(),
        .data_in_ready(),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_TX), // Notice these lines are connected opposite to the off_chip_uart
        .serial_out(FPGA_SERIAL_RX)
    );

    initial begin
        reset = 1'b0;
        data_in = 8'd0;
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;
        repeat (2) @(posedge clk);

        // Reset the UARTs
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;

        // Wait until the off_chip_uart's transmitter is ready
        while (data_in_ready == 1'b0) @(posedge clk);

        // Send a character to the off chip UART's transmitter to transmit over the serial line
        data_in = 8'h21;
        data_in_valid = 1'b1;
        @(posedge clk);
        data_in_valid = 1'b0;

        // Now, the transmitter should be sending the data_in over the FPGA_SERIAL_TX line to the on chip UART

        // We wait until the on chip UART's receiver indicates that is has valid data it has received
        while (data_out_valid == 1'b0) @(posedge clk);

        // Now, data_out of the on chip UART should contain the data that was sent to it by the off chip UART
        if (data_out !== 8'h21) begin
            $display("Failure 1: on chip UART got data: %h, but expected: %h", data_out, 8'h21);
            $finish();
        end

        // If we wait a few more clock cycles, the data should still be held by the receiver
        repeat (10) @(posedge clk);
        if (data_out !== 8'h21) begin
            $display("Failure 2: on chip UART got correct data, but it didn't hold data_out until data_out_ready was asserted");
            $finish();
        end

        // At this point, the off chip UART's transmitter should be idle and the FPGA_SERIAL_TX line should be in the idle state
        if (FPGA_SERIAL_TX !== 1'b1) begin
            $display("Failure 3: FPGA_SERIAL_TX was not high when the off chip UART's transmitter should be idle");
            $finish();
        end

        // Now, if we assert data_out_ready to the on chip UART's receiver, it should pull its data_out_valid signal low
        data_out_ready = 1'b1;
        @(posedge clk);
        data_out_ready = 1'b0;
        @(posedge clk);
        if (data_out_valid == 1'b1) begin
            $display("Failure 4: on chip UART didn't clear data_out_valid when data_out_ready was asserted");
            $finish();
        end




        repeat (20) @(posedge clk);
        // Wait until the off_chip_uart's transmitter is ready
        while (data_in_ready == 1'b0) @(posedge clk);

        // Send a character to the off chip UART's transmitter to transmit over the serial line
        data_in = 8'h20;
        data_in_valid = 1'b1;
        @(posedge clk);
        data_in_valid = 1'b0;

        // Now, the transmitter should be sending the data_in over the FPGA_SERIAL_TX line to the on chip UART

        // We wait until the on chip UART's receiver indicates that is has valid data it has received
        while (data_out_valid == 1'b0) @(posedge clk);

        // Now, data_out of the on chip UART should contain the data that was sent to it by the off chip UART
        if (data_out !== 8'h20) begin
            $display("Failure 1b: on chip UART got data: %h, but expected: %h", data_out, 8'h21);
            $finish();
        end

        // If we wait a few more clock cycles, the data should still be held by the receiver
        repeat (10) @(posedge clk);
        if (data_out !== 8'h20) begin
            $display("Failure 2b: on chip UART got correct data, but it didn't hold data_out until data_out_ready was asserted");
            $finish();
        end

        // At this point, the off chip UART's transmitter should be idle and the FPGA_SERIAL_TX line should be in the idle state
        if (FPGA_SERIAL_TX !== 1'b1) begin
            $display("Failure 3b: FPGA_SERIAL_TX was not high when the off chip UART's transmitter should be idle");
            $finish();
        end

        // Now, if we assert data_out_ready to the on chip UART's receiver, it should pull its data_out_valid signal low
        data_out_ready = 1'b1;
        @(posedge clk);
        data_out_ready = 1'b0;
        @(posedge clk);
        if (data_out_valid == 1'b1) begin
            $display("Failure 4b: on chip UART didn't clear data_out_valid when data_out_ready was asserted");
            $finish();
        end

        repeat (20) @(posedge clk);
        
        $display("Test Successful");
        $finish();
    end
endmodule
