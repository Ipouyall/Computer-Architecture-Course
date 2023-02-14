    `timescale 1ps/1ps

`define DATA_MEMORY_SIZE 1048576  // 2^20
`define INSTRUCTIONS_MEMORY_SIZE 1048576  //2^20
    
module mips_dp(clk,rst,slt,Jal,RegDst,RegWrite,ALUsrc,PCsrc,ALU_OP,MemRead,MemWrite,MemToReg,ALUzero,INST);//stil, we need to write out signals
    input clk,slt,Jal,RegDst,RegWrite,ALUsrc,MemRead,MemWrite,MemToReg,rst;
    input [2:0]ALU_OP;
    input[1:0] PCsrc;
    output ALUzero;
    output[31:0] INST;

    wire[31:0] PC, PC_next, regData1, regData2;
    wire[31:0]  PCsrc0, PCsrc1, PCsrc2, PCsrc3;
    wire[31:0] Oslt,Om3, Omtr, extended1,OmALU,ALUout,shifted, MemoryData;
    wire[4:0] Om1,Om2;
    wire Neg;

    // assign PC=32'd0;
    // assign PC_next=32'd0;

    // inst.mem area
    register prog_counter(.clk(clk), .load(1'b1),.rst(rst), .in(PC_next), .out(PC));
    instructions_memory #(`INSTRUCTIONS_MEMORY_SIZE) instMem(.program_counter(PC), .instruction(INST));
    
    adder pc_increament(PC,32'd4,PCsrc1);

    // register_file area
    RegisterFile rf(.clk(clk), .reg_write(RegWrite), .reg1(INST[25:21]), .reg2(INST[20:16]),
                    .write_reg(Om2), .write_data(Om3), .data1(regData1), .data2(regData2));
    Mux2to1 #(5) m1(RegDst, INST[20:16], INST[15:11], Om1);
    Mux2to1 #(5) m2(Jal, Om1, 5'd31, Om2);
    Mux2to1 #(32) m3(Jal, Oslt, PCsrc1, Om3);
    assign PCsrc3=regData1;

    SignExtend se1(INST[15:0], extended1);

    Lshifter2 sh1({2'b00,PCsrc1[31:28],INST[25:0]}, PCsrc2);

    Mux2to1 #(32) mSLT(slt, Omtr, {{31{1'b0}},Neg}, Oslt);


    // ALU area
    Mux2to1 #(32) mALU(ALUsrc, regData2, extended1, OmALU);
    alu_dp ALU(.A(regData1),.B(OmALU),.ALU_OP(ALU_OP),.ZERO(ALUzero),.ALU_RES(ALUout));
    assign Neg=ALUout[31];

    Lshifter2 sh2(extended1, shifted);
    adder add2(shifted, PCsrc1, PCsrc0);

    // DataMemory 
    data_memory #(`DATA_MEMORY_SIZE) dataMem(.clk(clk), .address(ALUout), .write_data(regData2), .readSig(MemRead),.writeSig(MemWrite), 
                        .read_data(MemoryData));

    Mux2to1 #(32) mMtR(MemToReg, ALUout, MemoryData, Omtr);


    // PCsrc area    
    Mux4to1 #(32) PCsel(PCsrc, PCsrc0, PCsrc1, PCsrc2, PCsrc3, PC_next);

endmodule
