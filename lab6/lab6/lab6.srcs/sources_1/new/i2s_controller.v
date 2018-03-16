`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data.
);

    // An idea of what you might need, to get you started.
    localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
    localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
    localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
    localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);
    
    // 1: Generate MCLK from sys_clk. MCLK's frequency must be an integer multiple
    // of the sample rate, and hence LRCK rate, as defined in the PMOD I2S reference
    // manual and the Cirrus Logic CS4344 data sheet.
    
    reg mclk_reg;
    reg [MCLK_COUNTER_WIDTH-1:0] mcounter;
    assign mclk = mclk_reg;
    
    initial mclk_reg = 0;
    
    always @(posedge sys_clk) begin
        if (sys_reset) begin
            mclk_reg <= 0;
            mcounter <= 0;
        end
        else if (mcounter < MCLK_CYCLES)
            mcounter <= mcounter + 1;
        else begin
            mclk_reg <= ~mclk_reg;
            mcounter <= 0;
        end
    end
    
    // 2: Generate the LRCK, the left-right clock.
    localparam LRCK_COUNTER_WIDTH = `log2(LRCK_FREQ_HZ);
    
    reg lrck_reg;
    reg [LRCK_COUNTER_WIDTH-1:0] lrcounter;
    assign lrck = lrck_reg;
    
    initial lrck_reg = 0;
    
    always @(posedge mclk) begin
        if (sys_reset) begin
            lrck_reg <= 0;
            lrcounter <= 0;
        end
        else if (lrcounter < LRCK_FREQ_HZ)
            lrcounter <= lrcounter + 1;
        else begin
            lrck_reg <= ~lrck_reg;
            lrcounter <= 0;
        end
    end    
        
    // 3. Generate the bit clock, or serial clock. It clocks transmitted bits for a 
    // whole sample on each half-cycle of the lr_clock. The frequency of this clock
    // relative to the lr_clock determines how wide our samples can be.
    localparam bit_depth = 24;
    localparam SCLK_CYCLES = `divceil(LRCK_FREQ_HZ, bit_depth);
    localparam SCLK_COUNTER_WIDTH = `log2(SCLK_CYCLES);
    
    reg sclk_reg;
    reg [SCLK_COUNTER_WIDTH-1:0] scounter;
    assign sclk = sclk_reg;
    
    initial sclk_reg = 0;
    
    always @(posedge mclk) begin
        if (sys_reset) begin
            sclk_reg <= 0;
            scounter <= 0;
        end
        else if (scounter < MCLK_CYCLES_HALF)
            scounter <= scounter + 1;
        else begin
            sclk_reg <= ~sclk_reg;
            scounter <= 0;
        end
    end 
    // 4. Generate a bit counter that will track which bit of each
    // sample to output for each bit clock.
    
    reg [4:0] bit_counter;
    assign sdin = bit_counter;
    
    
    always @(negedge sclk) begin
        if (sys_reset)
            bit_counter <= 0;
        else if (bit_counter == 0)
            bit_counter <= bit_depth-1;
        else if (bit_counter > 1)
            bit_counter <= bit_counter - 1;
        else
            bit_counter <= 0;
    end    

endmodule