`include "util.vh"

module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = `log2(sample_count_max),
    parameter saturating_counter_width = `log2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);
    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that hold high when their respective counter saturates

    // Remove this line once you create your synchronizer
    assign debounced_signal = 0;
    reg [wrapping_counter_width-1:0] saturating_counter [width-1:0]; // 4 X 8 bit array
    
    reg [wrapping_counter_width-1:0] wrapping_counter;
    reg sample_pulse_out;
    
    reg [width-1:0] sync_out;
    
    reg [width-1:0] debounced_sig_reg;
    
    assign debounced_signal = debounced_sig_reg;
    
    
    synchronizer #(.width(width)) synch(.async_signal(glitchy_signal), .clk(clk), .sync_signal(sync_out));
    
    genvar j;
    generate
        for (j = 0; j < width; j = j + 1) begin:debouncers
        end
    endgenerate
    
    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:sat_count
            always @ (posedge clk) begin
                // Insert synchronous Verilog here
                if (sample_pulse_out && sync_out[i]) begin
                    saturating_counter <= saturating_counter + 1;
                end
                if (!sync_out[i]) begin
                    saturating_counter <= 0;
                end
                if (saturating_counter == pulse_count_max) begin
                    debounced_sig_reg[i] <= 1;
                end
                else
                    debounced_sig_reg[i] <= 0;
                end
            end
        end
    endgenerate   
    
    
    always @(posedge clk) begin
        if (wrapping_counter < sample_count_max) begin
            wrapping_counter <= wrapping_counter + 1;
            sample_pulse_out <= 0;
        end
        else begin
            wrapping_counter <= 0;
            sample_pulse_out <= 1;
        end
    end

    
    
endmodule
