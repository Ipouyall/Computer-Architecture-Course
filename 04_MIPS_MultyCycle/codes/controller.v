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

`define IF 5'd0
`define ID 5'd1
`define AM 5'd2
`define WM 5'd3
`define STORE 5'd4
`define JAMP 5'd5
`define BRANCHZ 5'd6
`define MT 5'd7
`define MF0 5'd8
`define MF1 5'd9
`define R1 5'd10
`define R2 5'd11
`define R3 5'd12
`define ADDI 5'd13
`define SUBI 5'd14
`define ANDI 5'd15
`define ORI 5'd16
`define II 5'd17
`define NOP `IF


`define OP_LOAD 4'b0000
`define OP_STORE 4'b0001
`define OP_JUMP 4'b0010
`define OP_BRANCHZ 4'b0100
`define OP_CTYPE 4'b1000
`define OP_ADDI 4'b1100
`define OP_SUBI 4'b1101
`define OP_ANDI 4'b1110
`define OP_ORI 4'b1111

`define F_MOVETO 9'b000000001
`define F_MOVFROM 9'b000000010
`define F_ADD 9'b000000100
`define F_SUB 9'b000001000
`define F_AND 9'b000010000
`define F_OR 9'b000100000
`define F_NOT 9'b001000000
`define F_NOP 9'b010000000





module controller(clk,rst,instruction,PCWrite,PCWriteCond,IorD,DM,MemWrite,
                MemRead,IRWrite,ARS,MemToReg,RegWrite,IMS,NI,ALUop,PCSrc);
    input[15:0] instruction;
    input clk,rst;
    output reg PCWrite,PCWriteCond,IorD,DM,MemWrite,MemRead,IRWrite,
                ARS,RegWrite,IMS,NI;
    output [2:0] ALUop;
    output reg [1:0] PCSrc,MemToReg;

    // alu controller
    reg [2:0] aluop_fromcontroller;
    alu_ctrlr alu_controller(aluop_fromcontroller,instruction[8:0],ALUop);

    // find state
    reg [4:0] ps,ns;
    always @(instruction,ps)begin
        ns  = `IF;
        case (ps)
            `IF: ns = `ID;
            `ID: case (instruction[15:12])
                    `OP_LOAD: ns = `AM;
                    `OP_STORE: ns = `STORE;
                    `OP_JUMP: ns = `JAMP;
                    `OP_BRANCHZ: ns = `BRANCHZ;
                    `OP_CTYPE: case(instruction[8:0])
                                `F_MOVETO: ns = `MT;
                                `F_MOVFROM: ns = `MF0;
                                `F_ADD: ns = `R1;
                                `F_SUB: ns = `R1;
                                `F_AND: ns = `R1;
                                `F_OR: ns = `R1;
                                `F_NOT: ns = `R1;
                                `F_NOP: ns = `IF;
                                default: ns = `IF;
                            endcase
                    `OP_ADDI: ns = `ADDI;
                    `OP_SUBI: ns = `SUBI;
                    `OP_ANDI: ns = `ANDI;
                    `OP_ORI: ns = `ORI;
                endcase
            `AM: ns = `WM;
            `WM: ns = `IF;
            `STORE: ns = `IF;
            `JAMP: ns = `IF;
            `BRANCHZ: ns = `IF;
            `MT: ns = `IF;
            `MF0: ns = `MF1;
            `MF1: ns = `IF;
            `R1: ns = `R2;
            `R2: ns = `R3;
            `R3: ns = `IF;
            `ADDI: ns = `II;
            `SUBI: ns = `II;
            `ANDI: ns = `II;
            `ORI: ns = `II;
            `II: ns = `IF;
        endcase
    end

    // issue signals
    always@(ps)begin
        {PCWrite,PCWriteCond,MemWrite,IRWrite,RegWrite} = 0;
        case(ps)
            `IF:{DM,IorD,IRWrite,MemRead,PCSrc,aluop_fromcontroller,NI,PCWrite}=
                {1'b0,1'b0,1'b1,1'b1,2'b00,`push_add,1'b1,1'b1};
            `ID:{ARS,RegWrite,MemWrite} = {1'b1,1'b0,1'b0};
            `AM:{DM,MemRead} = {1'b1,1'b1};
            `WM:{ARS,MemToReg,RegWrite} = {1'b1,2'b01,1'b1};
            `STORE:{DM,ARS,MemWrite} = {1'b1,1'b1,1'b1};
            `JAMP:{PCSrc,PCWrite} = {2'b01,1'b1};
            `BRANCHZ:{ARS,PCSrc,aluop_fromcontroller,PCWriteCond,NI,IMS} = 
                    {1'b1,2'b10,`push_sub,1'b1,1'b0,1'b0};
            `MT:{ARS,MemToReg,RegWrite} = {1'b0,2'b00,1'b1};
            `MF0:{ARS} = {1'b0};
            `MF1:{ARS,MemToReg,RegWrite} = {1'b1,2'b00,1'b1};
            `R1:{ARS} = {1'b1};
            `R2:{IMS,NI,aluop_fromcontroller} = {1'b0,1'b0,`diagnostic};
            `R3:{ARS,MemToReg,RegWrite} = {1'b1,2'b10,1'b1};
            `ADDI:{NI,IMS,aluop_fromcontroller} = {1'b0,1'b1,`push_add};
            `SUBI:{NI,IMS,aluop_fromcontroller} = {1'b0,1'b1,`push_sub};
            `ANDI:{NI,IMS,aluop_fromcontroller} = {1'b0,1'b1,`push_and};
            `ORI:{NI,IMS,aluop_fromcontroller} = {1'b0,1'b1,`push_or};
            `II:{ARS,MemToReg,RegWrite} = {1'b1,2'b10,1'b1};
        endcase
    end

    // go to next state
    always@(posedge clk, posedge rst)
        if(rst)
            ps <= `IF;
        else
            ps <= ns;

endmodule
