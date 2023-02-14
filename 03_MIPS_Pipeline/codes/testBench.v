`timescale 1ps/1ps
module testBench();
	reg rst = 0, clk = 0;
	
	dataPath mips(clk, rst);

	always #5 clk <= ~clk;

	initial begin
		#7 rst = 1;
		#16 rst = 0;
		#2000 $stop;
	end
endmodule
