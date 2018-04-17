`include "util.vh"

module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [data_width-1:0] dout,
    output empty
);

    reg [data_width-1:0] buffer [fifo_depth-1:0];
    reg [addr_width-1:0] write_pointer;
    reg [addr_width-1:0] read_pointer;
    reg [data_width-1:0] dout_reg;
    reg write_pointer_wrap;
    reg read_pointer_wrap; 
      
    assign full = (write_pointer == read_pointer) && (write_pointer_wrap != read_pointer_wrap);
    assign empty = (write_pointer == read_pointer)  && (write_pointer_wrap == read_pointer_wrap);
    assign dout = dout_reg;

    // Write interface    
    always @(posedge clk) begin
        if (rst) begin
            write_pointer <= 0;
            write_pointer_wrap <= 0;
        end
        else if (wr_en && !full) begin
            if (write_pointer == fifo_depth - 1) begin
                write_pointer <= 0;
                write_pointer_wrap <= ~write_pointer_wrap;
            end
            else begin
                write_pointer <= write_pointer + 1;
            end
            
            buffer[write_pointer] <= din;
        end
    end

    // Read interface
    always @(posedge clk) begin
        if (rst) begin
            read_pointer <= 0;
            read_pointer_wrap <= 0;
            dout_reg <= 0;
        end
        else if (rd_en && !empty) begin
            if (read_pointer == fifo_depth - 1) begin
                read_pointer <= 0;  
                read_pointer_wrap <= ~read_pointer_wrap;
            end
            else begin
                read_pointer <= read_pointer + 1;  
            end
            dout_reg <= buffer[read_pointer];
        end
    end

endmodule
