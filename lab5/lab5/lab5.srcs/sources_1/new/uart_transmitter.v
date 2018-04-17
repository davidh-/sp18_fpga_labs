`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 33_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);
    
    wire tx_running;  
    wire symbol_edge;
    wire start; 
    
    reg [9:0] tx_shift;
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;


    //--|Signal Assignments|------------------------------------------------------

    assign serial_out = tx_shift[0];
    assign data_in_ready = !tx_running;
    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);
    
    // Goes high when it is time to start transmitting a new character
    assign start = data_in_valid;

    // Goes high while we are transmitting a character
    assign tx_running = bit_counter != 0;
    
    //--|Counters|----------------------------------------------------------------

    // Counts cycles until a single symbol is done  
    always @ (posedge clk) begin
        clock_counter <= (start || reset || symbol_edge) ? 0 : clock_counter + 1;
    end
    
    // Counts up to 10 bits for every character
    always @ (posedge clk) begin
        if (reset) begin
            bit_counter <= 0;
        end 
        else if (start) 
            bit_counter <= 1;
        else if (symbol_edge && tx_running) begin
            if (bit_counter == 10) 
                bit_counter <= 0;
            else
                bit_counter <= bit_counter + 1;
        end
        
    end 
    
    //--|Shift Register|----------------------------------------------------------
    always @(posedge clk) begin
        if (reset || !tx_running) begin
            tx_shift <= 10'b1;
        end
        if (start) begin
            tx_shift <= {1'b1, data_in[7:0], 1'b0};
        end
        else if (symbol_edge && tx_running && bit_counter < 10)
            tx_shift <= tx_shift >> 1;
    end     
    
endmodule
