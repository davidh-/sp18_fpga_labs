module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period,
    input clk,
    output square_wave_out
);
    reg [23:0] clock_counter = 0;
    
    reg sq_wave_reg = 0;
    assign square_wave_out = sq_wave_reg;
    
    always @(posedge clk) begin
        clock_counter <= clock_counter + 1;
        if (output_enable) begin
            if (tone_switch_period == clock_counter) begin
                sq_wave_reg <= ~sq_wave_reg;
                clock_counter <= 0;
            end
        end
     end

endmodule

