    `timescale 1ps/1ps

module PC (clk,rst,write,in,out);
    input clk,rst,write;
    input [11:0]in;
    output reg [11:0]out;

    always @(posedge clk, posedge rst) begin
        if(rst)
            out=12'd0;
        else if(write)
            out=in;
    end
endmodule