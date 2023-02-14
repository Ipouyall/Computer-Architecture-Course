    `timescale 1ps/1ps

module proccesor(clk,rst);
    input clk, rst;

    wire [15:0] instruction;
    wire PCWrite,PCWriteCond,IorD,DM,MemWrite,MemRead,IRWrite,
                ARS,RegWrite,IMS,NI;
    wire [2:0] ALUop;
    wire [1:0] PCSrc,MemToReg;

    controller cu(clk,rst,instruction,PCWrite,PCWriteCond,IorD,DM,MemWrite,
                MemRead,IRWrite,ARS,MemToReg,RegWrite,IMS,NI,ALUop,PCSrc);
    dataPath dp(clk,rst,PCWrite,PCWriteCond,IorD,DM,MemWrite,
                MemRead,IRWrite,ARS,MemToReg,RegWrite,
                IMS,NI,ALUop,PCSrc,instruction);

endmodule
