module game_movement(clk,
		     ld,  
		     reset_movement,// common inputs between ball and paddle end
		     move_ball, // ball inputs end
		     
		     move1_up,
		     move1_down,
		     move2_up,
		     move2_down,
		     color_in,
		     paddle1x, 
		     paddle1y, 
		     paddle2x, 
		     paddle2y, // paddle inputs end
		     
		     x_out_b,
		     y_out_b,
		     color_out_b,
		     scorep1,
		     scorep2, // ball outputs end
		     
		     paddle1x_out,
		     paddle1y_out, 
		     paddle2x_out, 
		     paddle2y_out,
		     color_out_paddle1,
		     color_out_paddle2,
		     game_over_sig); // paddle outputs end 
	

// inputs common between ball and paddle
	input clk;
	input ld;
	input reset_movement;
	
// ball inputs
	input move_ball;
	
// paddle inputs
	input move1_up;
	input move1_down;
	input move2_up;
	input move2_down;
	input [2:0] color_in;
	input [7:0] paddle1x;
	input [6:0] paddle1y;
	input [7:0] paddle2x;
	input [6:0] paddle2y;
	
// ball outputs
	output reg [7:0] x_out_b;
	output reg [6:0] y_out_b;
	output reg [2:0] color_out_b;
	output reg [3:0] scorep1;
	output reg [3:0] scorep2;
	
// paddle outputs
	output reg [7:0] paddle1x_out;
	output reg [6:0] paddle1y_out; 
	output reg [7:0] paddle2x_out; 
	output reg [6:0] paddle2y_out;
	output reg game_over_sig;

	output reg [2:0] color_out_paddle1;
	output reg [2:0] color_out_paddle2;
	
// ball regs/wires
	reg [6:0] paddle1_init;
	reg [6:0] paddle2_init;
	reg [7:0] x_counter;
	reg [6:0] y_counter;
	reg [7:0] x_max;
	reg [7:0] x_min;
	reg [6:0] y_max;
	reg [6:0] y_min;
	reg x_forward;
	reg y_forward;
	reg [7:0] x_before;
	reg [6:0] y_before;
	reg drawn_b;
	
// paddle regs/wires
	reg [3:0] paddley_count; 
	reg deleted1_up;
	reg deleted1_down;
	reg deleted2_up;
	reg deleted2_down;
	reg drawn;
	
// counters to reset screen
	reg [6:0] y_screen;

	
		// paddle movement
	always @(posedge clk) 
	begin
		if (reset_movement == 1'b0)
		begin
		// initialization of paddle values
			paddle1_init <= 7'b0110110;
			paddle2_init <= 7'b0110110;
			paddley_count <= 4'b0000;
			deleted1_up <= 1'b0;
			deleted1_down <= 1'b0;
			deleted2_up <= 1'b0;
			deleted2_down <= 1'b0;
			drawn <= 1'b0;
			y_screen <= y_screen + 1'b1;
		end // end reset
		
		if(ld)
		begin

			if(paddley_count != 4'b1111)
				paddley_count <= paddley_count + 1'b1;
			else
			begin
				drawn <= 1'b1;
			end
			
			if(drawn == 1'b1)
			begin
				if(move1_up == 1'b1 && deleted1_up == 1'b0)
				begin
					paddle1y_out <= paddle1_init + paddley_count;
					color_out_paddle1 <= 3'b000;
					deleted1_up <= 1'b1;
				end
				else if(deleted1_up == 1'b1)
				begin
					paddle1y_out <= paddle1_init - 1'b1;
					color_out_paddle1 <= color_in;
					paddle1_init <= paddle1_init - 1'b1;
					deleted1_up <= 1'b0;
				end
				else if(move1_down == 1'b1 && deleted1_down == 1'b0)
				begin
					paddle1y_out <= paddle1_init;
					color_out_paddle1 <= 3'b000;
					deleted1_down <= 1'b1;
				end
				else if(deleted1_down == 1'b1)
				begin
					paddle1y_out <= paddle1_init + paddley_count + 1'b1;
					color_out_paddle1 <= color_in;
					paddle1_init <= paddle1_init + 1'b1;
					deleted1_down <= 1'b0;
				end
				if(move2_up == 1'b1 && deleted2_up == 1'b0)
				begin
					paddle2y_out <= paddle2_init + paddley_count;
					color_out_paddle2 <= 3'b000;
					deleted2_up <= 1'b1;
				end
				else if(deleted2_up == 1'b1)
				begin
					paddle2y_out <= paddle2_init - 1'b1;
					color_out_paddle2 <= color_in;
					paddle2_init <= paddle2_init - 1'b1;
					deleted2_up <= 1'b0;
				end
				else if(move2_down == 1'b1 && deleted2_down == 1'b0)
				begin
					paddle2y_out <= paddle2_init;
					color_out_paddle2 <= 3'b000;
					deleted2_down <= 1'b1;
				end
				else if(deleted2_down == 1'b1)
				begin
					paddle2y_out <= paddle2_init + paddley_count + 1'b1;
					color_out_paddle2 <= color_in;
					paddle2_init <= paddle2_init + 1'b1;
					deleted2_down <= 1'b0;
				end
			end
			else
			begin
				paddle1x_out <= paddle1x;
				paddle1y_out <= paddle1_init + paddley_count;
				paddle2x_out <= paddle2x;
				paddle2y_out <= paddle2_init + paddley_count;
				color_out_paddle1 <= color_in;
				color_out_paddle2 <= color_in;
			end
			
			if(game_over_sig == 1'b1)
			begin
				if(y_screen <= 7'b1111111)
				begin
					y_screen <= y_screen + 1'b1;
					color_out_paddle1 <= 3'b000;
					color_out_paddle2 <= 3'b000;
					paddle1y_out <= y_screen;
					paddle2y_out <= y_screen;
				end
			end
		end // end of load
	end

	// ball movement
	always@(posedge clk)
	begin
		if (reset_movement == 1'b0)
		begin
			// initialization of ball values
			x_max <= 8'b10011111;
			y_max <= 7'b1110111;
			x_min <= 8'b0000001;
			y_min <= 7'b000010;
			x_counter <= 8'b01010000;
			y_counter <= 7'b0111100;
			x_forward <= 1'b1;
			y_forward <= 1'b1;
			drawn_b <= 1'b0;
			
			// score initialization (to reset back to 0 after first round)
			scorep1 <= 4'b0000;
			scorep2 <= 4'b0000;
			game_over_sig <= 1'b0;
		end // end reset
		
		
		if(ld)
		begin
			if(move_ball && !game_over_sig)
			begin
				if(drawn_b == 1'b0 && game_over_sig == 1'b0)
				begin
					if(x_counter != x_max && x_forward == 1'b1)
					begin
						x_counter <= x_counter + 1'b1;
						x_out_b <= x_counter;
						color_out_b <= color_in;
					end
					else if(x_counter != x_min && x_forward == 1'b0)
					begin
						x_counter <= x_counter - 1'b1;
						x_out_b <= x_counter;
						color_out_b <= color_in;
					end
					else
					begin
						if(x_counter >= x_max)
						begin
							x_forward <= 1'b0;
							color_out_b <= color_in;
							if(scorep1 != 4'b0011)
								scorep1 <= scorep1 + 1'b1;
							else
							begin
								scorep1 <= scorep1 + 1'b1;
								game_over_sig <= 1'b1;
							end
						end
						else
						begin
							x_forward <= 1'b1;
							color_out_b <= color_in;
							if(scorep2 != 4'b0011)
								scorep2 <= scorep2 + 1'b1;
							else
							begin
								scorep1 <= scorep1 + 1'b1;
								game_over_sig <= 1'b1;
							end
						end
					end


					if(y_counter != y_max && y_forward == 1'b1)
					begin
						y_counter <= y_counter + 1'b1;
						y_out_b <= y_counter;
						color_out_b <= color_in;
					end
					else if(y_counter != y_min && y_forward == 1'b0)
					begin
						y_counter <= y_counter - 1'b1;
						y_out_b <= y_counter;
						color_out_b <= color_in;
					end
					else
					begin
						if(y_counter == y_max)
						begin
							y_forward <= 1'b0;
							color_out_b <= color_in;
						end
						else
						begin
							y_forward <= 1'b1;
							color_out_b <= color_in;
						end
					end
					
					if ((x_counter <= paddle1x_out + 2'b10) && (x_forward == 0) && (y_counter >= paddle1_init) && (y_counter <= paddle1_init + 4'b1111))
						x_forward <= 1'b1;	
					else if ((x_counter >= paddle2x_out - 2'b10) && (x_forward == 1) && (y_counter >= paddle2_init) && (y_counter <= paddle2_init + 4'b1111))
						x_forward <= 1'b0;
					
					drawn_b <= 1'b1;
				end
				else if (drawn_b == 1'b1)
				begin
					drawn_b <= 1'b0;
					color_out_b <= 3'b000;
				end
			end
			
			else if(game_over_sig == 1'b1)
			begin
				color_out_b <= 3'b000;
			end

			
		end // end of load
	
	
	
	end
	


endmodule