module registerFile (clk, adrA, adrB, adrW, writeEn, inW, outA, outB);
    input [4:0] adrA, adrB, adrW;
    input clk, writeEn;
    input [31:0] inW;
    output [31:0] outA, outB;

    reg [31:0] registers [31:0];

    initial begin
		//$readmemb("registerFile.txt", registers);
		registers[0] = 32'd0;
	end

	always @(negedge clk)
		if (writeEn)
            if (adrW != 5'd0)
		registers[adrW] = inW;
	
	assign outA = registers[adrA];
	assign outB = registers[adrB];
endmodule
