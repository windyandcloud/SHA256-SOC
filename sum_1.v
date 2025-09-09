module sum_1(
	input [31:0] e,
	output [31:0] out
);
	assign out = {e[5:0],e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};
endmodule 