module regression_tb ();
	reg start = 0, clk = 0, rst = 0, write = 0;
	wire [19:0] error;
	wire ready;

	regression UUT(start, clk, rst, ready, error);

	always #5 clk <= !clk;

	integer f;
	initial begin
		f = $fopen("output.txt","w");
		#8 rst = 1;
		#10 rst = 0;
		#10 start = 1;
		#10 start = 0;
		#5000;
		$fclose(f);
 		$stop; // <== end simulation
	end


	always @(posedge clk)
	begin
		if (error === 20'bzzzzzzzzzzzzzzzzzzzz) begin end
		else if (error === 20'bxxxxxxxxxxxxxxxxxxxx) begin end
		else
  			$fwrite(f,"%b\n", error);
	end

endmodule
