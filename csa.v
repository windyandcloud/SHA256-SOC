module csa (
	input  [31:0] x, y, z,
	output [31:0] sum, carry
);

	wire [31:0] carry_stage1;

	genvar i;
	generate
		// Stage 1: CSA – 3-input fulladders
		for (i = 0; i < 32; i = i + 1) begin : CSA_STAGE
			fulladder fa (
				.a(x[i]),
				.b(y[i]),
				.cin(z[i]),
				.sum(sum[i]),
				.carry(carry_stage1[i])
			);
		end
	endgenerate

	// Stage 2: Ripple Carry Adder – sum_stage1 + (carry_stage1 << 1)
	// assign sum_out = {1'b0, sum} + {carry_stage1, 1'b0};
	assign carry = {carry_stage1[30:0], 1'b0};

endmodule

module fulladder (
	input a, b, cin,
	output sum, carry
);
	assign {carry, sum} = a + b + cin;
endmodule
