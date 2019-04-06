module control(clk, go, reset_co, move_ball, rd_ld, reset_movement, state);
    
	 input clk;
	 input go;
	 
	 output reg reset_co;
	 output reg move_ball;
    output reg rd_ld;
	 output reg reset_movement;
	 output [5:0] state;
	 
	 
    reg [5:0] current_state, next_state;  
    
	 assign state = current_state;
	 
	 //localparam pre_game = 2'b00, draw = 2'b01, game = 2'b11, game_over = 2'b10;

	 
	 
	   localparam  pre_game      = 5'd0,
                pre_game_wait   = 5'd1,
                draw        	  = 5'd2,
                draw_wait   	  = 5'd3,
                game        	  = 5'd4,
                game_wait  	  = 5'd5,
                game_over       = 5'd6,
                game_over_wait  = 5'd7;
    
	 initial
	 begin
		current_state <= pre_game;
	 end
	 
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                pre_game: next_state = go ? pre_game_wait : pre_game; // Loop in current state until value is input
                pre_game_wait: next_state = go ? pre_game_wait : draw; // Loop in current state until go signal goes low
                draw: next_state = go ? draw_wait : draw; // Loop in current state until value is input
                draw_wait: next_state = go ? draw_wait : game; // Loop in current state until go signal goes low
                game: next_state = go ? game_wait : game; // Loop in current state until value is input
                game_wait: next_state = go ? game_wait : game_over; // Loop in current state until go signal goes low
                game_over: next_state = go ? game_over_wait : game_over; // Loop in current state until value is input
                game_over_wait: next_state = go ? game_over_wait : pre_game; // Loop in current state until go signal goes low
            default:     next_state = pre_game;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		reset_co <= 1'b0;
		move_ball <= 1'b0;
		rd_ld <= 1'b0;
		reset_movement <= 1'b0;
        
		  case (current_state)
			pre_game_wait:
			begin
				reset_co <= 1'b0;
				move_ball <= 1'b0;
				rd_ld <= 1'b0;
				reset_movement <= 1'b0;
			end
			draw_wait: 
			begin
				reset_co <= 1'b1;
				move_ball <= 1'b0;
				rd_ld <= 1'b1;
				reset_movement <= 1'b0;
			end
			game_wait:
			begin
				reset_co <= 1'b1;
				move_ball <= 1'b1;
				rd_ld <= 1'b1;
				reset_movement <= 1'b1;
			end
			game_over_wait:
			begin
				 reset_co <= 1'b0;
				 move_ball <= 1'b0;
				 rd_ld <= 1'b0;
				 reset_movement <= 1'b0;
			end  
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	
	
   always@(posedge clk)
	begin: state_FFs
			current_state <= next_state;
	end 
endmodule
