    `timescale 1ps/1ps
    
`define ALU_add 3'd0
`define ALU_sub 3'd1
`define ALU_and 3'd2
`define ALU_or 3'd3
`define ALU_deactive 3'd7

`define push_add 2'd0
`define push_sub 2'd1
`define diagnostic 2'd2
`define nop 2'd3

`define func_add 6'b100000
`define func_sub 6'b100010
`define func_and 6'b100100
`define func_or 6'b100101
`define func_slt 6'b101010
`define func_jr 6'b001000


module alu_dp (A,B,ALU_OP,ZERO,ALU_RES);
    input [31:0] A,B;
    input [2:0] ALU_OP;
    output reg [31:0] ALU_RES;
    output ZERO;

    always @(A,B,ALU_OP)
        case(ALU_OP)
            `ALU_add: ALU_RES = A + B;
            `ALU_sub: ALU_RES = A + (~B + 1'b1);
            `ALU_and: ALU_RES = A & B;
            `ALU_or: ALU_RES = A | B;
            default: ALU_RES=32'd0;
        endcase
    
    assign ZERO = ~(|ALU_RES);
endmodule

module alu_ctrlr(aluop,func,ALU_OP);
    input [1:0] aluop;
    input [5:0] func;
    output reg [2:0] ALU_OP;

    reg[2:0] cnd;

    always @(func) begin
        case(func)
            `func_add: cnd=`ALU_add;
            `func_sub: cnd=`ALU_sub;
            `func_and: cnd=`ALU_and;
            `func_or: cnd=`ALU_or;
            `func_slt: cnd=`ALU_sub;
            `func_jr: cnd=`ALU_deactive;
            default: cnd=`ALU_deactive;
        endcase
    end

    always @(aluop,cnd) begin
        if(aluop==`push_add)
            ALU_OP <= `ALU_add;
        else if(aluop==`push_sub)
            ALU_OP <= `push_sub;
        else if(aluop==`nop)
            ALU_OP <= `ALU_deactive;
        else
            ALU_OP <= cnd;
    end

endmodule