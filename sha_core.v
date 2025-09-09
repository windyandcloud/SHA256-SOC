module sha_core(
	input clk, clr, start,
	input [511:0] message,
	output [255:0] hashvalue,
	output valid
	//output [6:0] out_count
);
	reg [6:0]	counter_reg;
	reg [31:0]	K, reg_ac;
	reg [319:0]	reg_in;
	reg [511:0]	buffer;
	reg [31:0]  reg_d, reg_g;
	
	wire [6:0]		counter_w_reg;
	wire [31:0]		S0, N0, M1, M2, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5;
	wire [31:0]		as, ac, at, K_i, ei;
	wire [31:0]		d0_256, d1_256;
	wire [31:0]		w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w_i;
	wire [31:0]		h0, h1, h2, h3, h4, h5, h6, h7;
	wire [31:0]		com0, com1, si, ni;
	wire [511:0]	block_out_wire;
	
	
	//assign out_count = counter_reg;
	assign valid = (counter_reg == 66) ? 1'b1 : 1'b0;
	// ===============================================================================================================
	
	assign w0	= buffer[511:480];
	assign w1	= buffer[479:448];
	assign w2	= buffer[447:416];
	assign w3	= buffer[415:384];
	assign w4	= buffer[383:352];
	assign w5	= buffer[351:320];
	assign w6	= buffer[319:288];
	assign w7	= buffer[287:256];
	assign w8	= buffer[255:224];
	assign w9	= buffer[223:192];
	assign w10	= buffer[191:160];
	assign w11	= buffer[159:128];
	assign w12	= buffer[127:96];
	assign w13	= buffer[95:64];
	assign w14	= buffer[63:32];
	assign w15	= buffer[31:0];
	
	// ===============================================================================================================
	
	assign d0_256 = {w1[6:0], w1[31:7]} ^ {w1[17:0], w1[31:18]} ^ {3'b000, w1[31:3]};
	assign d1_256 = {w14[16:0], w14[31:17]} ^ {w14[18:0], w14[31:19]} ^ {10'b0000000000, w14[31:10]};
	
	assign w_i = (counter_w_reg == 0)	? w0: 
					(counter_w_reg == 1)		? w1:
					(counter_w_reg == 2)		? w2:
					(counter_w_reg == 3)		? w3:
					(counter_w_reg == 4)		? w4:
					(counter_w_reg == 5)		? w5:
					(counter_w_reg == 6)		? w6:
					(counter_w_reg == 7)		? w7:
					(counter_w_reg == 8)		? w8:
					(counter_w_reg == 9)		? w9:
					(counter_w_reg == 10)	? w10:
					(counter_w_reg == 11)	? w11:
					(counter_w_reg == 12)	? w12:
					(counter_w_reg == 13)	? w13:
					(counter_w_reg == 14)	? w14:
					(counter_w_reg == 15)	? w15: d0_256 + w9 + d1_256 + w0;  
					
	assign block_out_wire = {w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w_i};
	
	// ===============================================================================================================
	
	always @(posedge clk or negedge clr) begin
		if (~clr) begin
			buffer <= 512'd0;
		end
		else begin
			if (start)
				buffer <= message;
			if (counter_reg >= 17 && counter_reg <= 64)
				buffer <= block_out_wire;
		end
	end
	// ===============================================================================================================
	
	assign h0 = 32'h6a09e667; // a0
	assign h1 = 32'hbb67ae85; // b0
	assign h2 = 32'h3c6ef372; // c0
	assign h3 = 32'ha54ff53a; // d0
	assign h4 = 32'h510e527f; // e0
	assign h5 = 32'h9b05688c; // f0
	assign h6 = 32'h1f83d9ab; // g0
	assign h7 = 32'h5be0cd19; // h0
	
	// ===============================================================================================================
	
	assign ei = tmp1 + tmp0;
	assign at = reg_in[319:288] + reg_ac;
	
	// ===============================================================================================================
	// Tinh S0, N0
	ch ch0(h4, h5, h6, N0);
	sum_1 s1_0(h4, S0);
	// ===============================================================================================================
	
	ch ch1(ei, reg_in[223:192], reg_in[191:160], ni);
	sum_1 sum1_1(ei, si);
	sum_0 sum0_0(at, com0);
	maj maj0(at, reg_in[287:256], reg_in[255:224], com1);
	
	// ===============================================================================================================
	
	csa csa0(reg_in[127:96], reg_in[95:64], reg_in[63:32], M1, M2); // s + n + p
	
	csa csa1(M1 + M2, com1, com0, as, ac);
	
	csa csa2(reg_in[127:96], reg_in[95:64], reg_in[31:0], tmp0, tmp1);
	csa csa3(reg_in[159:128], K_i, w_i, tmp2, tmp3);		// g[t] + K[t+1] + W[t+1]
	csa csa4(reg_in[255:224], tmp2, tmp3, tmp4, tmp5);
	
	// ===============================================================================================================
	
	always @(posedge clk or negedge clr) begin
		if(~clr) begin
			reg_in <= 320'd0;
			reg_ac <= 32'd0;
		end
		else begin
			if(counter_reg == 0) begin
				reg_in[255:224] 	<= h3;	// d0
				reg_in[159:128]	<= h7;	// h0
			end
			else begin
				reg_in[319:288] 	<= (counter_reg == 1) ? h0 	: as;		// as
				reg_ac 				<= (counter_reg == 1) ? 32'b0	: ac;	// ac
				reg_in[287:256] 	<= (counter_reg == 1) ? h1		: at;		// b
				reg_in[255:224] 	<= (counter_reg == 1) ? h2		: reg_in[287:256];	// c
				reg_in[223:192] 	<= (counter_reg == 1) ? h4		: ei;		// e
				reg_in[191:160] 	<= (counter_reg == 1) ? h5		: reg_in[223:192];	// f
				reg_in[159:128] 	<= (counter_reg == 1) ? h6		: reg_in[191:160];	// g
				reg_in[127:96] 	<= (counter_reg == 1) ? S0		: si;		// s
				reg_in[95:64] 		<= (counter_reg == 1) ? N0		: ni; // n
				reg_in[63:32] 		<= tmp2 + tmp3;	// p
				reg_in[31:0] 		<= tmp4 + tmp5;	// q
			end
		end
	end
	
	// ===============================================================================================================
	
	always @(posedge clk or negedge clr) begin
		if (~clr) begin
			counter_reg	<= 7'd0;	
			reg_d <= 32'd0;
			reg_g <= 32'd0;
		end
		else begin
			if (counter_reg < 66) begin
				if(counter_reg == 0) begin
					counter_reg	<= (start == 1) ? 1'b1 : 1'b0;
				end
				else begin 
					if (counter_reg == 65) begin
						reg_d	<= (h3 + reg_in[255:224]);	// d
						reg_g	<= (h7 + reg_in[159:128]);	
					end	
					counter_reg <= counter_reg + 1'b1;
				end
			end
			else
				counter_reg	<= 7'd0;
		end
	end
	
	// ===============================================================================================================
	
	assign K_i = (counter_reg == 0)? 0: K;
	
	assign counter_w_reg = (counter_reg <= 7'd64) ? counter_reg - 1'b1 : 6'd63;
									
	always @(*) begin
		case(counter_w_reg)
			00: K = 32'h428a2f98;
			01: K = 32'h71374491;
			02: K = 32'hb5c0fbcf;
			03: K = 32'he9b5dba5;
			04: K = 32'h3956c25b;
			05: K = 32'h59f111f1;
			06: K = 32'h923f82a4;
			07: K = 32'hab1c5ed5;
			08: K = 32'hd807aa98;
			09: K = 32'h12835b01;
			10: K = 32'h243185be;
			11: K = 32'h550c7dc3;
			12: K = 32'h72be5d74;
			13: K = 32'h80deb1fe;
			14: K = 32'h9bdc06a7;
			15: K = 32'hc19bf174;
			16: K = 32'he49b69c1;
			17: K = 32'hefbe4786;
			18: K = 32'h0fc19dc6;
			19: K = 32'h240ca1cc;
			20: K = 32'h2de92c6f;
			21: K = 32'h4a7484aa;
			22: K = 32'h5cb0a9dc;
			23: K = 32'h76f988da;
			24: K = 32'h983e5152;
			25: K = 32'ha831c66d;
			26: K = 32'hb00327c8;
			27: K = 32'hbf597fc7;
			28: K = 32'hc6e00bf3;
			29: K = 32'hd5a79147;
			30: K = 32'h06ca6351;
			31: K = 32'h14292967;
			32: K = 32'h27b70a85;
			33: K = 32'h2e1b2138;
			34: K = 32'h4d2c6dfc;
			35: K = 32'h53380d13;
			36: K = 32'h650a7354;
			37: K = 32'h766a0abb;
			38: K = 32'h81c2c92e;
			39: K = 32'h92722c85;
			40: K = 32'ha2bfe8a1;
			41: K = 32'ha81a664b;
			42: K = 32'hc24b8b70;
			43: K = 32'hc76c51a3;
			44: K = 32'hd192e819;
			45: K = 32'hd6990624;
			46: K = 32'hf40e3585;
			47: K = 32'h106aa070;
			48: K = 32'h19a4c116;
			49: K = 32'h1e376c08;
			50: K = 32'h2748774c;
			51: K = 32'h34b0bcb5;
			52: K = 32'h391c0cb3;
			53: K = 32'h4ed8aa4a;
			54: K = 32'h5b9cca4f;
			55: K = 32'h682e6ff3;
			56: K = 32'h748f82ee;
			57: K = 32'h78a5636f;
			58: K = 32'h84c87814;
			59: K = 32'h8cc70208;
			60: K = 32'h90befffa;
			61: K = 32'ha4506ceb;
			62: K = 32'hbef9a3f7;
			63: K = 32'hc67178f2;
			default: K = 0;
		endcase
	end
	
	// ======================================================================
	// debug
	/*assign hashvalue[159:128]	= (counter_reg < 65)  ? 32'd0 :
											(counter_reg == 65) ? (h3 + reg_in[255:224]) : hashvalue[159:128];     // d
	assign hashvalue[31:0] 		= (counter_reg < 65)  ? 32'd0 :
											(counter_reg == 65) ? (h7 + reg_in[159:128]) : hashvalue[31:0];        // g*/
											
	assign hashvalue[159:128]	= (counter_reg < 66)  ? 32'd0 : reg_d;
	assign hashvalue[31:0] 		= (counter_reg < 66)  ? 32'd0 : reg_g;
	assign hashvalue[255:224]	= (counter_reg == 66) ? h0 + at : 0;                   // a
	assign hashvalue[223:192]	= (counter_reg == 66) ? h1 + reg_in[287:256] : 0;     // b
	assign hashvalue[191:160]	= (counter_reg == 66) ? h2 + reg_in[255:224] : 0;     // c
	assign hashvalue[127:96]	= (counter_reg == 66) ? h4 + reg_in[223:192] : 0;     // e
	assign hashvalue[95:64] 	= (counter_reg == 66) ? h5 + reg_in[191:160] : 0;     // f
	assign hashvalue[63:32]		= (counter_reg == 66) ? h6 + reg_in[159:128] : 0;     // g


	// ======================================================================
endmodule 

