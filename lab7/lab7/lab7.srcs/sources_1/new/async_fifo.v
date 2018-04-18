`include "util.vh"

module async_fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input wr_clk,
    input rd_clk,

    input wr_en,
    input rd_en,
    input [data_width-1:0] din,

    output full,
    output empty,
    output [data_width-1:0] dout
);
    reg [data_width-1:0] buffer [fifo_depth-1:0];
    reg [addr_width-1:0] write_pointer;
    reg [addr_width-1:0] read_pointer;
    reg [data_width-1:0] dout_reg;
    reg write_pointer_wrap;
    reg read_pointer_wrap; 
          
    reg [addr_width-1:0] write_pointer_sync1;
    reg [addr_width-1:0] write_pointer_sync2;
    reg [addr_width-1:0] read_pointer_sync1;
    reg [addr_width-1:0] read_pointer_sync2;
    wire [addr_width-1:0] write_pointer_gray;
    wire [addr_width-1:0] read_pointer_gray;
    
    wire [addr_width-1:0] write_pointer_synced;
    wire [addr_width-1:0] read_pointer_synced;
    
    
    assign full = (write_pointer == read_pointer_synced) && (write_pointer_wrap != read_pointer_wrap);
    assign empty = (write_pointer_synced == read_pointer)  && (write_pointer_wrap == read_pointer_wrap);
    assign dout = dout_reg;
    
    //binary to gray
    assign write_pointer_gray =  write_pointer ^ (write_pointer >> 1);
    assign read_pointer_gray =  read_pointer ^ (read_pointer >> 1);
    // gray to binary
    assign write_pointer_synced = write_pointer_sync2 ^ (write_pointer_sync2 >> 1) ^ (write_pointer_sync2 >> 2) ^ (write_pointer_sync2 >> 3);
    assign read_pointer_synced = read_pointer_sync2 ^ (read_pointer_sync2 >> 1) ^ (read_pointer_sync2 >> 2) ^ (read_pointer_sync2 >> 3);
    
    initial begin
        write_pointer = 0;
        read_pointer = 0;
        dout_reg = 0;  
        write_pointer_wrap = 0;
        read_pointer_wrap = 0; 
        write_pointer_sync1 = 0;
        write_pointer_sync2 = 0;
        read_pointer_sync1 = 0;
        read_pointer_sync2 = 0;
    end  
    
    // Write interface  
    always @(posedge wr_clk) begin
        // write logic
        if (wr_en && !full) begin
            if (write_pointer == fifo_depth - 1) begin
                write_pointer <= 0;
                write_pointer_wrap <= ~write_pointer_wrap;
            end
            else begin
                write_pointer <= write_pointer + 1;
            end
            
            buffer[write_pointer] <= din;
        end
        // synchronizer
        write_pointer_sync1 <= write_pointer_gray;
        write_pointer_sync2 <= write_pointer_sync1;
    end
    
    // Read interface
    always @(posedge rd_clk) begin
        // read logic
        if (rd_en && !empty) begin
            if (read_pointer == fifo_depth - 1) begin
                read_pointer <= 0;  
                read_pointer_wrap <= ~read_pointer_wrap;
            end
            else begin
                read_pointer <= read_pointer + 1;  
            end
            dout_reg <= buffer[read_pointer];
        end
        // synchronizer
        read_pointer_sync1 <= read_pointer_gray;
        read_pointer_sync2 <= read_pointer_sync1;
    end
endmodule
