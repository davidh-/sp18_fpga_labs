module synchronizer #(parameter width = 1) (
    input [width-1:0] async_signal,
    input clk,
    output [width-1:0] sync_signal
);
    // Create your 2 flip-flop synchronizer here
    // This module takes in a vector of 1-bit asynchronous (from different clock domain or not clocked) signals
    // and should output a vector of 1-bit synchronous signals that are synchronized to the input clk

    // Remove this line once you create your synchronizer
    reg [width-1:0] s1;
    reg [width-1:0] s2;
    
    initial begin
        s1 = 0;
        s2 = 0;
    end
    
    assign sync_signal = s2;
    always @(posedge clk) begin
        s1 <= async_signal;
        s2 <= s1;
    end
endmodule
