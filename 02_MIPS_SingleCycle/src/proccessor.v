    `timescale 1ps/1ps
// need to add controller and alu controller ans datapath

module MIPS(clk,rst);
    input clk,rst;

    wire slt,Jal,RegDst,RegWrite,ALUsrc,MemRead,MemWrite,MemToReg,ALUzero;
    wire [31:0] INST;
    wire [2:0]ALU_OP;
    wire[1:0] ALUop,PCsrc;

    controller ctrlr(INST,ALUzero,RegDst,Jal,RegWrite,slt,ALUsrc,ALUop,PCsrc,MemRead,MemWrite,MemToReg);
    alu_ctrlr alu_ctrl(ALUop,INST[5:0],ALU_OP);
    mips_dp dp(clk,rst,slt,Jal,RegDst,RegWrite,ALUsrc,PCsrc,ALU_OP,MemRead,MemWrite,MemToReg,ALUzero,INST);

endmodule
