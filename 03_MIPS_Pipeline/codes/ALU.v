`define ALU_add 3'd2
`define ALU_sub 3'd6
`define ALU_and 3'd0
`define ALU_or 3'd1
`define ALU_deactive `ALU_add

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

module ALUDP(A, B, ALUOp, zero, ALURes);
    input [31:0] A,B;
    input [2:0] ALUOp;
    output reg [31:0] ALURes;
    output zero;

    always @(A,B,ALUOp)
        case(ALUOp)
            `ALU_add: ALURes = A + B;
            `ALU_sub: ALURes = A + (~B + 1'b1);
            `ALU_and: ALURes = A & B;
            `ALU_or: ALURes = A | B;
            default: ALURes = 32'd0;
        endcase
    
    assign zero = ~(|ALURes);
endmodule

module ALUCU(INOp, func, ALUOp);
    input [1:0] INOp;
    input [5:0] func;
    output reg [2:0] ALUOp;
    reg[2:0] Op;

    always @(func) begin
        case(func)
            `func_add: Op =`ALU_add;
            `func_sub: Op =`ALU_sub;
            `func_and: Op =`ALU_and;
            `func_or: Op =`ALU_or;
            `func_slt: Op =`ALU_sub;
            `func_jr: Op =`ALU_deactive;
            default: Op =`ALU_deactive;
        endcase
    end

    always @(INOp, Op) begin
        if(INOp == `push_add)
            ALUOp <= `ALU_add;
        else if(INOp == `push_sub)
            ALUOp <= `push_sub;
        else if(INOp == `nop)
            ALUOp <= `ALU_deactive;
        else
            ALUOp <= Op;
    end
endmodule
