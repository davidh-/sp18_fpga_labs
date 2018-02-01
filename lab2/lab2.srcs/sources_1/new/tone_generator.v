module tone_generator (
    input output_enable,
    input clk,
    output square_wave_out
);
    reg [19:0] clock_counter;
    
    reg sq_wave_reg;
    assign square_wave_out = sq_wave_reg;
    
    always @(posedge clk) begin
        clock_counter <= clock_counter + 1;
        if (output_enable) begin
            if (clock_counter < 284000)
                sq_wave_reg <= 1'b0;
            else if (clock_counter < 568000)
                sq_wave_reg <= 1'b1;
            else 
                clock_counter <= 0;
        end
     end

endmodule

