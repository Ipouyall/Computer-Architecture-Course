    `timescale 1ps/1ps
    
`define ALU_add 3'd0
`define ALU_sub 3'd1
`define ALU_and 3'd2
`define ALU_or 3'd3
`define ALU_not 3'd4
`define ALU_deactive 3'd7

`define push_add 3'd0
`define push_sub 3'd1
`define diagnostic 3'd2
`define nop 3'd3
`define push_and 3'd4
`define push_or 3'd5

`define func_add 9'b000000100
`define func_sub 9'b000001000
`define func_and 9'b000010000
`define func_or 9'b000100000
// `define func_slt 9'b101010
// `define func_jr 9'b001000
`define func_moveTo 9'b000000001
`define func_moveFrom 9'b000000010
`define func_not 9'b001000000
`define func_nop 9'b010000000

module alu_ctrlr(aluop,func,ALU_OP);
    input [2:0] aluop;
    input [8:0] func;
    output reg [2:0] ALU_OP;

    reg[2:0] cnd;

    always @(func) begin
        case(func)
            `func_add: cnd=`ALU_add;
            `func_sub: cnd=`ALU_sub;
            `func_and: cnd=`ALU_and;
            `func_or: cnd=`ALU_or;
            // `func_slt: cnd=`ALU_sub;
            // `func_jr: cnd=`ALU_deactive;
            `func_moveTo: cnd=`ALU_deactive;
            `func_moveFrom: cnd=`ALU_deactive;
            `func_not: cnd=`ALU_not;
            `func_nop: cnd=`ALU_deactive;
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
        else if(aluop==`push_and)
            ALU_OP <= `ALU_and;
        else if(aluop==`push_or)
            ALU_OP <= `ALU_or;
        else
            ALU_OP <= cnd;
    end

endmodule