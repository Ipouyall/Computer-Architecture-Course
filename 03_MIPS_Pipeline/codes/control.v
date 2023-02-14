`timescale 1ps/1ps

`define ADD 6'b111000
`define SUB 6'b111001
`define AND 6'b111010
`define OR 6'b111011
`define SLT 6'b111100
`define JR 6'b111101
`define NOP 6'b000000

`define R_TYPE 6'b000000
`define ADDI 6'b001000
`define SLTI 6'b001010
`define LW 6'b100011
`define SW 6'b101011
`define BEQ 6'b000100
`define J 6'b000010
`define JAL 6'b000011 

// for the R-type function part
`define func_add 6'b100000
`define func_sub 6'b100010
`define func_and 6'b100100
`define func_or 6'b100101
`define func_slt 6'b101010
`define func_jr 6'b001000
`define func_nop 6'b000000

// ALU operations
`define push_add 2'd0
`define push_sub 2'd1
`define diagnostic 2'd2
`define nop 2'd3


module control(inst, RegDst, Jal, regWrite, slt, ALUsrc, ALUop, branch, jump, memRead, memWrite, memToReg);
    input [31:0] inst;
    output reg [1:0] ALUop;
    output reg RegDst, Jal, regWrite, slt, ALUsrc, memRead, memWrite, memToReg, branch, jump;

    reg [5:0] instDecoded;
    wire [5:0] opcode, func;

    assign opcode = inst[31:26];
    assign func = inst[5:0];

    // decode instruction
    always @(opcode, func)
        case(opcode)
            `R_TYPE:
                case(func)
                    `func_add: instDecoded=`ADD;
                    `func_sub: instDecoded=`SUB;
                    `func_and: instDecoded=`AND;
                    `func_or: instDecoded=`OR;
                    `func_slt: instDecoded=`SLT;
                    `func_jr: instDecoded=`JR;
                    `func_nop: instDecoded=`NOP;
                endcase
            `ADDI: instDecoded=`ADDI;
            `SLTI: instDecoded=`SLTI;
            `LW: instDecoded=`LW;
            `SW: instDecoded=`SW;
            `BEQ: instDecoded=`BEQ;
            `J: instDecoded=`J;
            `JAL: instDecoded=`JAL;

            default: instDecoded=`ADD;
        endcase


    // control signals
    always @(instDecoded) begin
        {RegDst, Jal, regWrite, slt, ALUsrc, memRead, memWrite, memToReg, branch, jump} = 10'd0;
        case(instDecoded)
            `ADD: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b1;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `SUB: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b1;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `AND: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b1;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `OR: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b1;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `SLT: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b1;
                Jal = 1'b0;
                regWrite = 1'b1; 
                slt = 1'b1;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `JR: begin
                branch = 1'b0;
                jump = 1'b1;
                RegDst = 1'b0; // don't care
                Jal = 1'b0;
                regWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `diagnostic; // don't care
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0; // don't care
            end
            `ADDI: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b0;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `SLTI: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b0;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b1;
                ALUsrc = 1'b1;
                ALUop = `push_sub;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
            end
            `LW: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b0;
                Jal = 1'b0;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                memRead = 1'b1;
                memWrite = 1'b0;
                memToReg = 1'b1;
            end
            `SW: begin
                branch = 1'b0;
                jump = 1'b0;
                RegDst = 1'b0; // dont't care
                Jal = 1'b0;
                regWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                memRead = 1'b0;
                memWrite = 1'b1;
                memToReg = 1'b0;
            end
            `BEQ: begin
                branch = 1'b1;
                jump = 1'b0;
                RegDst = 1'b0; // don't care
                Jal = 1'b0; 
                regWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `push_sub;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0; // don't care
            end
            `J: begin
                branch = 1'b0;
                jump = 1'b1;
                RegDst = 1'b0; // don't care
                Jal = 1'b0;
                regWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0; // don't care
            end
            `JAL: begin
                branch = 1'b0;
                jump = 1'b1;
                RegDst = 1'b0; // don't care
                Jal = 1'b1;
                regWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0; // don't care
            end            
            `NOP: begin
                branch = 1'b0; // don't care
                jump = 1'b0; // don't care
                RegDst = 1'b0; // don't care
                Jal = 1'b0; // don't care
                regWrite = 1'b0; // don't care
                slt = 1'b0; // don't care
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                memRead = 1'b0; // don't care
                memWrite = 1'b0; // don't care
                memToReg = 1'b0; // don't care
            end
            default: begin
                branch = 1'b0; // don't care
                jump = 1'b0; // don't care
                RegDst = 1'b0; // don't care
                Jal = 1'b0; // don't care
                regWrite = 1'b0; // don't care
                slt = 1'b0; // don't care
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                memRead = 1'b0; // don't care
                memWrite = 1'b0; // don't care
                memToReg = 1'b0; // don't care
            end
        endcase
    end

endmodule