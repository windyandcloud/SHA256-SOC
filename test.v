`timescale 1ns/1ps

module test();
	// Tín hiệu điều khiển và dữ liệu
	reg clk;
	reg clr;
	reg start;
	reg [511:0] data_in;
	wire [255:0] hashvalue;
	wire valid;
	//wire [6:0] counter;

	// SHA Core wrapper: Bạn cần wrapper xử lý buffer và start từ 4 lần ghi
	sha_core dut (
	.clk				(clk),
	.clr				(clr),
	.start			(start),
	.message			(data_in),
	.hashvalue		(hashvalue),
	.valid			(valid)
	//.out_count		(counter)
	);

	// Clock generator: 10ns period
	always #5 clk = ~clk;

	// Test logic
	initial begin
		// Init
		clk = 0;
		clr = 0;
		start = 0;
		data_in = 128'd0;

		// Reset
		#10;
		clr = 1;

		// Gửi 512 bit message ("abc" với padding)
		// SHA-256 input: "abc" = 616263
		// Padded full message: 512-bit = 4x128-bit
		start = 1;
		data_in = 512'h61626380_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000018;

		// Tắt write_en
		#10;
		start = 0;

		// Đợi cho tới khi valid
		wait (valid == 1);
		$display("SHA-256 Hash Output: %h", hashvalue);

		#100;
		$finish;
	end
endmodule
