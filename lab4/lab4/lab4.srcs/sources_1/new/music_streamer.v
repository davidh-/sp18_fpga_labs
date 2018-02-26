`include "util.vh"
`define clk_cycles_p_sec 5_000_000
`define tempo_change 1_000_000

module music_streamer (
    input clk,
    input rst,
    input tempo_up,
    input tempo_down,
    input tempo_reset,
    input play_pause,           // Switches between play and pause
    input switch_fn,            // Switches between regular play and play sequence
    input switch_mode,          // Switches between forward and reverse or play and edit sequence
    input edit_next_node,       // Select next tone to edit
    input edit_prev_node,       // Selects previous tone to edit
    output led_paused,
    output led_regular_play,
    output led_reverse_play,
    output led_play_seq,
    output led_edit_seq,
    output [23:0] tone
);
    reg [9:0] tone_index;
    reg [22:0] clock_counter;
    reg [`log2(`clk_cycles_p_sec):0] tempo; //clock cycles per note 125MHz * (1/25 s)
    wire [9:0] last_address_wire;
    wire [23:0] data_wire;
    reg in_pause;
	reg reversed;   
	reg [23:0] data_to_tone;
	
    assign tone = data_to_tone;
    
    rom music_data (
        .address(tone_index),       // 10 bits
        .data(data_wire),                // 24 bits
        .last_address(last_address_wire)
    );
    
    always @(posedge clk) begin
        if (tempo_reset) begin
            tempo <= `clk_cycles_p_sec;
        end
        else if (tempo_up && tempo > 0) begin
            tempo <= tempo - `tempo_change;
        end
        else if (tempo_down) begin
            tempo <= tempo + `tempo_change;
        end
    end

    // YOUR CODE FROM LAB3 HERE - you may have to modify this template to integrate your old code. 
    always @(posedge clk) begin
        if (rst) begin
            clock_counter <= 23'd0;
            tone_index <= 10'd0;
        end
        else begin
            clock_counter <= clock_counter + 24'd1;
        end
        if (clock_counter >= tempo) begin
        	if (reversed)
        		tone_index <= (tone_index > 0) ? tone_index - 1  : last_address_wire ;
        	else if (in_pause) 
        		tone_index <= tone_index;
        	else
            	tone_index <= (tone_index < last_address_wire) ? tone_index + 1  : 0 ;
            clock_counter <= 0;
        end
    end
  
    // Use these nets for constructing your FSM
    localparam PAUSED = 3'd0;
    localparam REGULAR_PLAY = 3'd1;
    localparam REVERSE_PLAY = 3'd2;
    localparam PLAY_SEQ = 3'd3;
    localparam EDIT_SEQ = 3'd4;
    reg [2:0] current_state;
    reg [2:0] next_state;
    
    assign led_paused = current_state == PAUSED;
    assign led_regular_play = current_state == REGULAR_PLAY;
    assign led_reverse_play = current_state == REVERSE_PLAY;
    assign led_play_seq = 1'b0;
    assign led_edit_seq = 1'b0;
    
    // always block for state register
    always @(posedge clk) begin
        if (rst) begin
            current_state <= REGULAR_PLAY;
        end
        else begin
        	current_state <= next_state;
        end
    end

    // always block for combinational logic portion
    always @(current_state or play_pause or switch_mode or data_wire) begin
    	case (current_state)
	    	REGULAR_PLAY:begin 
	    	    data_to_tone = data_wire;
	    		in_pause = 0;
	    		reversed = 0;
	    		if (play_pause) begin
	    			next_state = PAUSED;
	    		end
	    		else if (switch_mode) begin
	    			next_state = REVERSE_PLAY;
	    		end
	    		else
	    			next_state = REGULAR_PLAY;
	    	end
	    	PAUSED:begin 
	    		data_to_tone = 24'b0;
	    		in_pause = 1;
	    		reversed = 0;
	    		if (play_pause) begin
	    			next_state = REGULAR_PLAY;
	    		end
	    		else
	    			next_state = PAUSED;
	    	end
	    	REVERSE_PLAY:begin 
	    		data_to_tone = data_wire;
	    		in_pause = 0;
	    		reversed = 1;
	    		if (play_pause) begin
	    			next_state = PAUSED;
	    		end
	    		else if (switch_mode) begin
	    			next_state = REGULAR_PLAY;
	    		end
	    		else
	    			next_state = REVERSE_PLAY;
	    	end
	    	default:begin
	    		data_to_tone = data_wire;
	    		in_pause = 0;
	    		reversed = 0;
	    		next_state = REGULAR_PLAY;
	    	end
    	endcase 
    end

    // The following RTL is provided as starter code for Section 9: Music Sequencer
    reg [23:0] sequencer_mem [7:0];
    reg [2:0] sequencer_addr;
    reg [23:0] tone_under_edit;

    // Registering and modification of the tone_under_edit (sequencer)
    always @ (posedge clk) begin
        tone_under_edit <= tone_under_edit;

        // If we are moving into edit mode from the play mode, register the note
        if (next_state == EDIT_SEQ && current_state == PLAY_SEQ) begin
            tone_under_edit <= sequencer_mem[sequencer_addr];
        end
        // We are currently in edit mode, if we switch notes or edit the current note, we should update the tone_under_edit
        else if (current_state == EDIT_SEQ) begin
            if (edit_next_node) tone_under_edit <= sequencer_mem[sequencer_addr + 3'd1];
            else if (edit_prev_node) tone_under_edit <= sequencer_mem[sequencer_addr - 3'd1];
            else tone_under_edit <= tone_under_edit;
        end
    end

    // Modification of the sequencer notes (sequencer_mem)
    always @ (posedge clk) begin
        if (rst) begin
            sequencer_mem[0] <= 24'd37500;
            sequencer_mem[1] <= 24'd37500;
            sequencer_mem[2] <= 24'd37500;
            sequencer_mem[3] <= 24'd37500;
            sequencer_mem[4] <= 24'd37500;
            sequencer_mem[5] <= 24'd37500;
            sequencer_mem[6] <= 24'd37500;
            sequencer_mem[7] <= 24'd37500;
        end
        // If we are in edit mode and the user pushes in tempo_reset, store the tone_under_edit in the sequencer memory, for some reason.
        else if (current_state == EDIT_SEQ && tempo_reset) begin
            sequencer_mem[sequencer_addr] <= tone_under_edit;
        end
        else begin
            sequencer_mem[sequencer_addr] <= sequencer_mem[sequencer_addr];
        end
    end

endmodule
