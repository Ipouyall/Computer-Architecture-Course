    `timescale 1ps/1ps

module Mux2to1 #(parameter N=16)(s, a, b, out);
	input s;
	input [N-1:0]a,b;
	output [N-1:0]out;

	assign out = s ? b : a;
endmodule

module Mux3to1 #(parameter N=16)(s, a, b, c, out);
		input [1:0]s;
		input [N-1:0]a,b,c;
		output reg[N-1:0]out;

	always @(s, a, b, c)begin
		case (s)
			2'b00 : out = a;
			2'b01 : out = b;
			2'b10 : out = c;
			default : out = 0;
		endcase
	end
endmodule

module Register(clk,rst,ld,in,out);
    input clk,rst,ld;
    input [15:0]in;
    output reg [15:0]out;

    always @(posedge clk, posedge rst)
        if(rst)
            out<=16'd0;
        else if(ld)
             out<=in;
    
endmodule

module Sign_extend(in,out);
    input [11:0]in;
    output [15:0]out;

    assign out = {{4{in[11]}}, in};

endmodule