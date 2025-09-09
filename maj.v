module maj(
	input [31:0] a, b, c,
	output [31:0] out
);
	assign out = (a & b) ^ (a & c) ^ (b & c);
endmodule 