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
			output reg  [7:0] x,
			output reg  [6:0] y,
			output reg [2:0] color_f,
			output ld); 
		
	reg [1:0] counter;

	
	always @( posedge clk )
	begin
		
		if(!reset_co)
			counter <= 2'b00;
		else if(counter == 2'b11)
			counter <= 2'b00;
		else
			counter <= counter + 1'b1;
		
				
		case (counter) 
			2'b00:
			begin
				x <= paddle1x_out;
				y <= paddle1y_out;
				color_f <= color_out_paddle1;
			end 
			2'b01:
			begin
				x <= paddle2x_out;
				y <= paddle2y_out;
				color_f <= color_out_paddle2;
			end
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
	
	assign ld = (counter == 2'b11) ? 1 : 0;


endmodule