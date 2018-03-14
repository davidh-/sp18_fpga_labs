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
    reg [saturating_counter_width-1:0] saturating_counter [width-1:0]; 
    reg [wrapping_counter_width-1:0] wrapping_counter;
    reg sample_pulse_out;

    initial begin
        wrapping_counter = 0;
        sample_pulse_out = 0;
    end
    
    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:sat_count
            initial begin
                saturating_counter[i] = 0;
            end
            assign debounced_signal[i] = saturating_counter[i] == pulse_count_max;
            always @ (posedge clk) begin
                // Insert synchronous Verilog here
                if (!glitchy_signal[i]) begin
                    saturating_counter[i] <= 0;
                end
                else if (sample_pulse_out && glitchy_signal[i] && saturating_counter[i] < pulse_count_max) begin
                    saturating_counter[i] <= saturating_counter[i] + 1;
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
