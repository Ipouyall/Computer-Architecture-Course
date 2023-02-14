    `timescale 1ps/1ps

module Reg_file(clk,RegWrite,read_reg1,read_reg2,write_reg,write_data,read_data1,read_data2);
    input clk,RegWrite;
    input [2:0]read_reg1,read_reg2,write_reg;
    input [15:0]write_data;
    output reg [15:0]read_data1,read_data2;

    reg [15:0] registers [0:7];

    initial begin
		$readmemb("registers.txt", registers);
		registers[0] = 16'd0;
	end

    always @(posedge clk)
        if(RegWrite)begin
            registers[write_reg]<=write_data;
            $writememb("registers.txt",registers);
        end

    always @(read_reg1,read_reg2,registers[read_reg1],registers[read_reg2])
        {read_data1,read_data2} <= {registers[read_reg1],registers[read_reg2]};
endmodule