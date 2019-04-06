// Part 2 skeleton

module pong
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		LEDR,
		HEX7,
		HEX0,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input CLOCK_50;				//	50 MHz
	input [17:0] SW;
	input [1:0] KEY;
	output [5:0] LEDR;
	output [7:0] HEX7, HEX0;

	output	VGA_CLK;   				//	VGA Clockcontrol
	output	VGA_HS;					//	VGA H_SYNC
	output	VGA_VS;					//	VGA V_SYNC
	output	VGA_BLANK_N;				//	VGA BLANK
	output	VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			

	wire [7:0] paddle1xw;
	wire [6:0] paddle1yw;
	wire [7:0] paddle2xw;
	wire [6:0] paddle2yw;
	wire [2:0] color_paddle1w;
	wire [2:0] color_paddle2w;
	wire should_ld;
	wire [7:0] x_out_bw;
	wire [6:0] y_out_bw;
	wire [2:0] color_out_bw;
	wire [6:0] paddle1_initw;
	wire [6:0] paddle2_initw;
	wire move_ballw;
	wire reset_cow;
	wire rd_ldw;	
	wire enable;
	wire [3:0] score1w;
	wire [3:0] score2w;
	wire game_over_sigw;
	wire reset_movementw;
	wire [19:0] mux_out;
	
	// choose the speed of the ball by selecting SW[17:16]
	mux4to1(
				.out(mux_out), 
				.MuxSelect(SW[17:16]), 
				.rateFull(20'b01001001001111100000), // 300k original speed with sws down 
				.rateOne(20'b00111101000010010000), // 250k
				.rateHalf(20'b00110000110101000000), // 200k
				.rateQuarter(20'b00100100100111110000)); // 150k
	
	
	// change the speed of ball by plugging in the rate chosen from mux to the rd
	rd my_rd(
			.e(enable),
			.rate(mux_out),
			.clear(rd_ldw),
			.clk(CLOCK_50));
	
	// FSM ; controls the state of game, you can move from one state to another by pressing key[1]
	control ctrl(
			.clk(CLOCK_50),
			.go(KEY[1]),
			//.game_over_sig(game_over_sigw),
			.reset_co(reset_cow),
			.reset_movement(reset_movementw),
			.move_ball(move_ballw), 
			.rd_ld(rd_ldw),
			.state(LEDR[5:0]));
	
	
	// displays the score of player one in the hex7 
	hex_display player1_score(
			.IN(score1w),
			.OUT(HEX7[6:0]));
	
	// displays the score of player two in the hex0
	hex_display player2_score(
			.IN(score2w), 
			.OUT(HEX0[6:0]));
	
	// controls the movement of the ball/paddle1/paddle2
	// moves according to the previous position and erases the trace
	// also keeps the score when ball interacts with the side of screen 
	game_movement gm(			  
			.clk(enable),
			.ld(should_ld), 
			.reset_movement(reset_movementw), // common inputs between ball and paddle end
			
			.move_ball(move_ballw), 
			//.color_in_b(SW[11:9]),  // ball inputs end
			
			.move1_up(SW[8]),
			.move1_down(SW[7]),
			.move2_up(SW[4]),
			.move2_down(SW[3]),
			.color_in(SW[11:9]),
			.paddle1x(8'b00000010),
			.paddle1y(7'b0110110),
			.paddle2x(8'b10011101),
			.paddle2y(7'b0110110), // paddle inputs end
			
			.x_out_b(x_out_bw), // positin of the ball 
			.y_out_b(y_out_bw), 
			.color_out_b(color_out_bw),
			.scorep1(score1w), //score of the players 
			.scorep2(score2w), // ball outputs end
			
			.paddle1x_out(paddle1xw), // position of the paddle 1
			.paddle1y_out(paddle1yw), 
			.paddle2x_out(paddle2xw),  // position of the paddle 2
			.paddle2y_out(paddle2yw),
			.color_out_paddle1(color_paddle1w), 	// color of each paddle 
			.color_out_paddle2(color_paddle2w),
			//.game_over_sig(game_over_sigw)
			);


	// takes in all the position of the objects to draw on the screen from game_movement
	// and sends to the vga one by one to be actually drawn 
	// x, y is the px position going in to the VGA controller 
	extract_move extract(
			.clk(enable),
			.reset_co(reset_cow),
			.paddle1x_out(paddle1xw), 
			.paddle1y_out(paddle1yw), 
			.paddle2x_out(paddle2xw), 
			.paddle2y_out(paddle2yw),
			.x_out_b(x_out_bw),
			.y_out_b(y_out_bw),
			.color_out_paddle1(color_paddle1w),
			.color_out_paddle2(color_paddle2w),
			.color_out_b(color_out_bw),
			.x(x),
			.y(y),
			.color_f(colour),
			.ld(should_ld)); 

endmodule
