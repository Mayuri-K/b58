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
	output reg [3:0] scorep1; // score of player 1 
	output reg [3:0] scorep2; // score of player 2
	
// paddle outputs
	output reg [7:0] paddle1x_out; 
	output reg [6:0] paddle1y_out; 
	output reg [7:0] paddle2x_out; 
	output reg [6:0] paddle2y_out;
	output reg game_over_sig;

	output reg [2:0] color_out_paddle1;
	output reg [2:0] color_out_paddle2;
	
// ball regs/wires
	reg [6:0] paddle1_init; // initial position of paddle, draw a stick figure by adding few more pxs, 
	reg [6:0] paddle2_init;
	reg [7:0] x_counter; //position of the x 
	reg [6:0] y_counter; // position of the y 
	reg [7:0] x_max; // max position of x, bottom of the screen 
	reg [7:0] x_min; // min position of x, top of the screen 
	reg [6:0] y_max; // max position of y, right side of the screen 
	reg [6:0] y_min; // min position of y, left side of the screen 
	reg x_forward; // direction of x
	reg y_forward; // direction of y 
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
		// initialization of paddle values, initial possition of the paddles are in the middle 
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
			
			// if the draw signal is on then start drawing 
			if(drawn == 1'b1)
			begin
				// first paddle functionalities 
				// if the paddle moved up by one px but hasn't deleted the bottom part
				if(move1_up == 1'b1 && deleted1_up == 1'b0)
				begin
					// delete the bottom part by setting the color of the bottom most to black 
					// paddle drawn = initial position (1px) + paddley_count (8pxs) 
					paddle1y_out <= paddle1_init + paddley_count; 
					color_out_paddle1 <= 3'b000;
					// once color is set to black, it's considered deleted 
					deleted1_up <= 1'b1;
				end
				// if the bottom part is already deleted 
				else if(deleted1_up == 1'b1)
				begin
					// output a new pxs up  
					paddle1y_out <= paddle1_init - 1'b1;
					// color the top pix 
					color_out_paddle1 <= color_in;
					// save the new initial position 
					paddle1_init <= paddle1_init - 1'b1;
					deleted1_up <= 1'b0;
				end
				// same thing as up but going opposite 
				// remove a px from the top of paddle and put them at the bottom of the paddle 
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
				// first paddle movement function ends here 
				
				
				//do the same for the second paddle 
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
				// paddle 2 funcitonality ends here 
			end
			
			// if all input are zero, then paddle should stay where they are 
			else
			begin
				paddle1x_out <= paddle1x;
				paddle1y_out <= paddle1_init + paddley_count;
				paddle2x_out <= paddle2x;
				paddle2y_out <= paddle2_init + paddley_count;
				color_out_paddle1 <= color_in;
				color_out_paddle2 <= color_in;
			end
			
			// if the game is over, set all the color to black to black-out the screen
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
			x_counter <= 8'b01010000; //start the ball at the middle of the screen 
			y_counter <= 7'b0111100; //start the ball at the middle of the screen 
			x_forward <= 1'b1;
			y_forward <= 1'b1;
			drawn_b <= 1'b0; // signal for drawing ball
			
			// score initialization (to reset back to 0 after first round)
			scorep1 <= 4'b0000;
			scorep2 <= 4'b0000;
			game_over_sig <= 1'b0;
		end // end reset
		
		
		if(ld) // if the previous drawing is done, then start the next one
		begin
			if(move_ball && !game_over_sig) 
			begin
				if(drawn_b == 1'b0 && game_over_sig == 1'b0) 
				begin
					// x-position 
					// if the x-position is not max and is going east, then keep going 
					if(x_counter != x_max && x_forward == 1'b1)
					begin
						x_counter <= x_counter + 1'b1; // increment the counter by 1 
						x_out_b <= x_counter; 
						color_out_b <= color_in;
					end
					// if the x-position is not min and is going west, keep going 
					else if(x_counter != x_min && x_forward == 1'b0)
					begin
						x_counter <= x_counter - 1'b1; 
						x_out_b <= x_counter;
						color_out_b <= color_in;
					end
					// otherwise the ball is at the edge so return accordingly 
					else
					begin
						// if the x-counter is at maximum, ie hit the right side of the screen, then 
						// set x direction to west 
						if(x_counter >= x_max)
						begin 
							x_forward <= 1'b0; // no longer going east, now set to west 
							color_out_b <= color_in;
							if(scorep1 != 4'b0011) // add one to the opponent score 
								scorep1 <= scorep1 + 1'b1;
							// if the score is already at max, then the opponent won and 
							// send the game over signal to the FSM 
							else
							begin
								scorep1 <= scorep1 + 1'b1;
								game_over_sig <= 1'b1;
							end
						end
						// otherwise the ball hit the left side of the screen 
						// set x direction to east 
						else
						begin
							x_forward <= 1'b1; // no longer going west, now set to east 
							color_out_b <= color_in;
							if(scorep2 != 4'b0011)
								scorep2 <= scorep2 + 1'b1; //add score to the opponent 
							else
							begin
								scorep1 <= scorep1 + 1'b1;
								game_over_sig <= 1'b1;
							end
						end
					end
					//end of x-position 
					
					// do y-position now, 
					// same as x, but with north(up) and South(down) instead 
					// it doesnt have the score option like x 
					if(y_counter != y_max && y_forward == 1'b1) // if ball isnt at max, keep going south 
					begin
						y_counter <= y_counter + 1'b1;
						y_out_b <= y_counter;
						color_out_b <= color_in;
					end
					// if the ball isnt at min, keep going north
					else if(y_counter != y_min && y_forward == 1'b0)
					begin
						y_counter <= y_counter - 1'b1;
						y_out_b <= y_counter;
						color_out_b <= color_in;
					end
					else
					begin
						if(y_counter == y_max) // if at max, change direction to north 
						begin
							y_forward <= 1'b0;
							color_out_b <= color_in;
						end
						else // otherwise change direction to south 
						begin
							y_forward <= 1'b1;
							color_out_b <= color_in;
						end
						
					end
					// end of y movement 
					
					
					// paddle and ball interaction
					// if the ball hits the paddle, it doesnt add to the score and it will bounce back 
					
					// if the ball hits the paddle1, then go east 
					if ((x_counter <= paddle1x_out + 2'b10) && (x_forward == 0) && (y_counter >= paddle1_init) && (y_counter <= paddle1_init + 4'b1111))
						x_forward <= 1'b1;	
					// if the ball hits the paddle 2 then go west 
					else if ((x_counter >= paddle2x_out - 2'b10) && (x_forward == 1) && (y_counter >= paddle2_init) && (y_counter <= paddle2_init + 4'b1111))
						x_forward <= 1'b0;
					
					drawn_b <= 1'b1; // send signal to draw the ball 
				end
				
				// if the ball is already drawn, then erase the previous ball by setting it to black 
				else if (drawn_b == 1'b1) 
				begin
					drawn_b <= 1'b0;
					color_out_b <= 3'b000;
				end
			end
			
			// if the game is over then send black regardless 
			else if(game_over_sig == 1'b1)
			begin
				color_out_b <= 3'b000;
			end

			
		end // end of load
	
	
	
	end
	


endmodule
