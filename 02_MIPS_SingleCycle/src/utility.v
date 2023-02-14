    `timescale 1ps/1ps

module Mux2to1 #(parameter N=32)(s, a, b, out);
	input s;
	input [N-1:0]a,b;
	output [N-1:0]out;

	assign out = s ? b : a;
endmodule

module Mux4to1 #(parameter N=32)(s, a, b, c, d, out);
		input [1:0]s;
		input [N-1:0]a,b,c,d;
		output reg[N-1:0]out;

	always @(s, a, b, c, d)
	begin
		case (s)
			2'b00 : out = a;
			2'b01 : out = b;
			2'b10 : out = c;
			2'b11 : out = d;
			default : out = 0;
		endcase
	end
endmodule

module SignExtend(in, out);
	input [15:0]in;
	output [31:0]out;

	assign out={{16{in[15]}},in};
endmodule

module RegisterFile(clk, reg_write, reg1, reg2, write_reg, write_data, data1, data2);

	input clk, reg_write;
	input [4:0] reg1, reg2, write_reg;
	input [31:0]write_data;
	output reg [31:0]data1,data2;

	reg [31:0]registers[31:0];

	initial begin
		$readmemb("registers.txt", registers);
		$monitor("registers loaded as: %p", registers);
		registers[0] = 32'd0;
	end

	always @(posedge clk)
		if ((reg_write) & (write_reg != 5'd0)) begin
			registers[write_reg] = write_data;
			$writememb("registers.txt",registers);
		end
	
	always@ (reg1, reg2, registers) begin 
			data1 = registers[reg1];
			data2 = registers[reg2];
	end
	
endmodule

module adder #(parameter N=32)(a, b, w);
	input [N-1:0] a, b;
	output [N-1:0] w;

	assign w = a + b;
endmodule

module instructions_memory #(parameter inst_count = 256)(program_counter, instruction);

	input [31:0] program_counter;
	output reg [31:0] instruction;
	
	reg [7:0] instructions [inst_count-1:0];
	
	initial begin 
		$readmemb("instruction.txt", instructions);
	end
	
	always @ (program_counter) begin
		instruction = {instructions[{program_counter[31:2],2'b00}+2'd3], instructions[{program_counter[31:2],2'b00}+2'd2],
						instructions[{program_counter[31:2],2'b00}+2'd1], instructions[{program_counter[31:2],2'b00}]};
	end

endmodule

module data_memory #(parameter size = 256)(clk, address, write_data, readSig,writeSig, read_data);
	input  [31:0] address,write_data;
	input readSig,writeSig,clk;
	output reg [31:0] read_data;

	reg [7:0] memory [size-1:0];
	initial begin
		$readmemb("data.txt", memory);
	end

	always @(address,readSig,memory) begin
		if(readSig) begin
			read_data = {memory[{address[31:2],2'b00}+2'd3], memory[{address[31:2],2'b00}+2'd2],
						memory[{address[31:2],2'b00}+2'd1], memory[{address[31:2],2'b00}]};
		end
	end

	always @(posedge clk) begin
		if(writeSig) begin
				{memory[{address[31:2],2'b00}+2'd3],memory[{address[31:2],2'b00}+2'd2],
						memory[{address[31:2],2'b00}+2'd1],memory[{address[31:2],2'b00}]} = write_data;
			$writememb("data.txt",memory);
		end
	end
endmodule

module shiftl2 #(parameter  n=26)(in, out);
	input[n-1:0] in;
	output[n+1:0] out;

	assign out={in,2'b00};

endmodule

module Lshifter2 #(parameter  n=32)(in, out);
	input[n-1:0] in;
	output[n-1:0] out;

	assign out={in[n-3:0],2'b00};

endmodule

module register #(parameter n = 32)(clk,load, rst, in, out);
	input load, clk,rst;
	input [n-1:0] in;
	output reg [n-1:0] out;

	always @(posedge clk)
		if(rst)
			out <= {n{1'b0}};
		else if (load)
			out <= in;
		else 
			out <= out;
endmodule
