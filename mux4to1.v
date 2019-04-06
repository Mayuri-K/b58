module mux4to1(out, MuxSelect, rateFull, rateOne, rateHalf, rateQuarter);
    input [1:0] MuxSelect;
    input [19:0] rateFull;
    input [19:0] rateOne;
    input [19:0] rateHalf;
    input [19:0] rateQuarter;

    output reg [19:0] out;

    always @(*)
    begin
		case (MuxSelect[1:0])
	    2'b00: out = rateFull;
	    2'b01: out = rateOne;
	    2'b10: out = rateHalf;
	    2'b11: out = rateQuarter;
	    default: out = 19'b000_000_000_000_000_000_0;
		endcase
    end
endmodule

