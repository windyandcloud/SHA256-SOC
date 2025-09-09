`timescale 1ns/1ps

module test_wrap();

    reg clk;
    reg rst_n;
    reg chipselect_n;
    reg write_n;
    reg read_n;
    reg [4:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;
	// wire [255:0] outdata;

    // DUT
    wrapper uut (
        .iClk(clk),
        .iReset_n(rst_n),
        .iChipSelect_n(chipselect_n),
        .iWrite_n(write_n),
        .iRead_n(read_n),
        .iAddress(address),
        .iData(data_in),
        .oData(data_out)
		//  .outdata(outdata)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns period
    initial begin
        // Initial setup
        clk = 0;
        rst_n = 0;
        write_n = 1;
        read_n = 1;
        address = 0;
        data_in = 0;
			chipselect_n = 0;
        // Reset
        #10 
		  chipselect_n = 0;
		  rst_n = 1;
		  write_n = 0;
		  address = 5'd0; data_in = 32'h00000018;
		#10 address = 5'd1; data_in = 32'h00000000;
		#10 address = 5'd2; data_in = 32'h00000000;
		#10 address = 5'd3; data_in = 32'h00000000;
		#10 address = 5'd4; data_in = 32'h00000000;
		#10 address = 5'd5; data_in = 32'h00000000;
		#10 address = 5'd6; data_in = 32'h00000000;
		#10 address = 5'd7; data_in = 32'h00000000;
		#10 address = 5'd8; data_in = 32'h00000000;
		#10 address = 5'd9; data_in = 32'h00000000;
		#10 address = 5'd10; data_in = 32'h00000000;
		#10 address = 5'd11; data_in = 32'h00000000;
		#10 address = 5'd12; data_in = 32'h00000000;
		#10 address = 5'd13; data_in = 32'h00000000;
		#10 address = 5'd14; data_in = 32'h00000000;
		#10 address = 5'd15; data_in = 32'h61626380;
		#10 address = 5'd24; data_in = 32'd1;
		
		
		
		#10 
		write_n = 1;
		
		#700
		read_n = 0;
		address = 5'd16;
		#10 address = 5'd17;
		#10 address = 5'd18;
		#10 address = 5'd19;
		#10 address = 5'd20;
		#10 address = 5'd21;
		#10 address = 5'd22;
		#10 address = 5'd23;
		
		#10 
		read_n = 1;
		#10
		$stop;
    end

endmodule
