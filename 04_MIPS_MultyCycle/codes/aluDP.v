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


module alu_dp (A,B,ALU_OP,ZERO,ALU_RES);
    input [15:0] A,B;
    input [2:0] ALU_OP;
    output reg [15:0] ALU_RES;
    output ZERO;

    always @(A,B,ALU_OP)
        case(ALU_OP)
            `ALU_add: ALU_RES = A + B;
            `ALU_sub: ALU_RES = B + (~A + 1'b1);
            `ALU_and: ALU_RES = A & B;
            `ALU_or: ALU_RES = A | B;
            `ALU_not: ALU_RES = ~A;
            default: ALU_RES=32'd0;
        endcase
    
    assign ZERO = ~(|ALU_RES);
endmodule