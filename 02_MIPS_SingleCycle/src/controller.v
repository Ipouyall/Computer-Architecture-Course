    `timescale 1ps/1ps

`define R_TYPE 6'b000000
`define ADD 6'b111000
`define SUB 6'b111001
`define AND 6'b111010
`define OR 6'b111011
`define SLT 6'b111100
`define JR 6'b111101

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

// ALU operations
`define push_add 2'd0
`define push_sub 2'd1
`define diagnostic 2'd2
`define nop 2'd3


module controller (Inst,zero,RegDst,Jal,RegWrite,slt,ALUsrc,ALUop,PCsrc,MemRead,MemWrite,MemToReg);
    input zero;
    input [31:0] Inst;
    output reg[1:0] ALUop,PCsrc;
    output reg RegDst,Jal,RegWrite,slt,ALUsrc,MemRead,MemWrite,MemToReg;

    reg[5:0] instDecoded;

    wire[5:0] opcode,func;
    assign opcode=Inst[31:26];
    assign func=Inst[5:0];

    // decode instruction
    always @(opcode,func)
        case(opcode)
            `R_TYPE:
                case(func)
                    `func_add: instDecoded=`ADD;
                    `func_sub: instDecoded=`SUB;
                    `func_and: instDecoded=`AND;
                    `func_or: instDecoded=`OR;
                    `func_slt: instDecoded=`SLT;
                    `func_jr: instDecoded=`JR;
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

    // actually, we don't need this part, as we are synced by PC
    // always @(posedge clk,ns)
    //     ps <= ns;

    // control signals
    always @(instDecoded,zero) begin
        case(instDecoded)
            `ADD: begin
                PCsrc = 2'd1;
                RegDst = 1'b1;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `SUB: begin
                PCsrc = 2'd1;
                RegDst = 1'b1;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `AND: begin
                PCsrc = 2'd1;
                RegDst = 1'b1;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `OR: begin
                PCsrc = 2'd1;
                RegDst = 1'b1;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `SLT: begin
                PCsrc = 2'd1;
                RegDst = 1'b1; // don't care
                Jal = 1'b0;
                RegWrite = 1'b1; 
                slt = 1'b1;
                ALUsrc = 1'b0;
                ALUop = `diagnostic;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `JR: begin
                PCsrc = 2'd3;
                RegDst = 1'b0; // don't care
                Jal = 1'b0;
                RegWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `diagnostic; // don't care
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0; // don't care
            end
            `ADDI: begin
                PCsrc = 2'd1;
                RegDst = 1'b0;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `SLTI: begin
                PCsrc = 2'd1;
                RegDst = 1'b0;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b1;
                ALUsrc = 1'b1;
                ALUop = `push_sub;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
            end
            `LW: begin
                PCsrc = 2'd1;
                RegDst = 1'b0;
                Jal = 1'b0;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                MemToReg = 1'b1;
            end
            `SW: begin
                PCsrc = 2'd1;
                RegDst = 1'b0;
                Jal = 1'b0;
                RegWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b1;
                ALUop = `push_add;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                MemToReg = 1'b0;
            end
            `BEQ: begin
                PCsrc = (zero) ? 2'd0 : 2'd1; 
                RegDst = 1'b0; // don't care
                Jal = 1'b0; 
                RegWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0;
                ALUop = `push_sub;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0; // don't care
            end
            `J: begin
                PCsrc = 2'd2;
                RegDst = 1'b0; // don't care
                Jal = 1'b0;
                RegWrite = 1'b0;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0; // don't care
            end
            `JAL: begin
                PCsrc = 2'd2;
                RegDst = 1'b0; // don't care
                Jal = 1'b1;
                RegWrite = 1'b1;
                slt = 1'b0;
                ALUsrc = 1'b0; // don't care
                ALUop = `nop; // don't care
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0; // don't care
            end
            default: begin
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUop = `nop;
            end
        endcase
    end

endmodule

