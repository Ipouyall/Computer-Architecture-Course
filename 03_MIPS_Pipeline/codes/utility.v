module register(rst, load, clk, d, q);
	parameter n = 32;
	input rst, load, clk;
	input [n-1:0] d;
	output reg [n-1:0] q;

	always @(posedge clk)
		if (rst)
			q <= {n{1'b0}};
		else if (load)
			q <= d;
		else 
			q <= q;
endmodule

module mux2to1(a, b, s, w);
	parameter n = 32;
	input [n-1:0] a, b;
	input s;
	output [n-1:0] w;

	assign w = s ? b : a;
endmodule

module mux3to1(a, b, c, s, w);
	parameter n = 32;
	input [n-1:0] a, b, c;
	input [1:0] s;
	output [n-1:0] w;

	assign w = (s == 0) ? a : (s == 1) ? b : c;
endmodule

module adder(a, b, w);
	parameter n = 32;
	input [n-1:0] a, b;
	output [n-1:0] w;

	assign w = a + b;
endmodule

module SignExtend(in, out);
	parameter from = 16;
	parameter to = 32;
	input [from-1:0]in;
	output [to-1:0]out;

	assign out = {{(to-from){in[from-1]}},in};
endmodule

module shiftLeft2(in, out);
	parameter n = 32;
	input [n-1:0]in;
	output [n-1:0]out;

	assign out = {in[n-3:0], 2'b00};
endmodule

module comprator (a, b, w);
	parameter n = 32;
	input [n-1:0] a, b;
	output w;

	assign w = (a==b) ? 1'b1 : 1'b0;
endmodule