module music_streamer (
    input clk,
    output [23:0] tone,
    output [9:0] rom_address
);
    reg [9:0] address_reg;
    reg [22:0] counter;
    wire [9:0] last_address_wire;
    
    initial begin
        address_reg = 0;
        counter = 0;
    end
    
    assign rom_address = address_reg;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter >= 5000000) begin
            address_reg <= (address_reg < last_address_wire) ? address_reg + 1  : 0 ;
            counter <= 0;
        end
    end
    
    rom music ( 
        .address(address_reg),
        .data(tone),
        .last_address(last_address_wire)
    );
    
endmodule
