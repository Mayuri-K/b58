module rd(e, rate, clear, clk);
    reg [19:0] q;
    input [19:0] rate; 
    input clear;
    input clk;
    
    output e;

	 
    always @(posedge clk)
    begin 
		if(!clear)
			 q <= rate - 1'b1;
		else if (rate == 20'b0000_000_000_000_000_000_0)
			q <= 20'b0000_000_000_000_000_000_0;
		else if (q == 20'b0000_000_000_000_000_000_0)
			 q <= rate - 1'b1;
		else
			 q <= q - 1'b1;
    end

    assign e = (q == 20'b0_000_000_000_000_000_000_0) ? 1 : 0;
endmodule

