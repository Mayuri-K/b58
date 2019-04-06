module extract_move( 
			input clk,
			input reset_co,
			input [7:0] paddle1x_out, 
			input [6:0] paddle1y_out, 
			input [7:0] paddle2x_out, 
			input [6:0] paddle2y_out,
			input [7:0] x_out_b,
			input [6:0] y_out_b,
			input [2:0] color_out_paddle1,
			input [2:0] color_out_paddle2,
			input [2:0] color_out_b,
	// output each position to x and y to the VGA adapter (1px at a time) 
			output reg  [7:0] x,
			output reg  [6:0] y,
	// also output the color_f change to VGA adapter ( can be changed through sw[7:9]) 
			output reg [2:0] color_f,
			output ld); 
		
	reg [1:0] counter;

	
	always @( posedge clk )
	begin
		
		if(!reset_co)
			counter <= 2'b00;
		else if(counter == 2'b11) // if counter is at max, reset to zero 
			counter <= 2'b00;
		else // increase the counter every clk cycle (posedge) 
			counter <= counter + 1'b1;
		
		// outs put the paddle1, paddle2 and position of the ball one by one  	
		case (counter) 
			// when the counter == 0, output the position of the x,y, and color for paddle 1 , 
			2'b00:
			begin
				x <= paddle1x_out;
				y <= paddle1y_out;
				color_f <= color_out_paddle1;
			end 
			// when the counter == 1, output for paddle 2
			2'b01:
			begin
				x <= paddle2x_out;
				y <= paddle2y_out;
				color_f <= color_out_paddle2;
			end
			// when the counter == 2, output for ball 
			2'b10 :
			begin
				x <= x_out_b;
				y <= y_out_b;
				color_f <= color_out_b;
			end
			default:
			begin
			end 
		endcase
		
	end
	
	// once the counter reaches max, ie once all the position for object are loaded, 
	// output the load signal as one 
	// if the positions are still loading, output 0 as a signal 
	
	assign ld = (counter == 2'b11) ? 1 : 0;


endmodule
