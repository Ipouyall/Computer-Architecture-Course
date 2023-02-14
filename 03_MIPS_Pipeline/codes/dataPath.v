module dataPath (input clk, rst);

    wire [31:0] pcIn, pcOut, pcAdded, pcJump, pcEq, instruction;
    wire [31:0] IFIDinstructionOut, regAout, regBout, writeData;
    wire [27:0] shiftedIns;

    wire [31:0] memOrALUout, MEMWBALUresOut, EXMEMALUresOut, MEMWBMemOut, memOut, EXMEMALUsrcBOut;
    wire [31:0] ALUsrcB, ALUsrcA, ALURes, IDEXregBout, IDEXregAout, IFIDpcOut;
    wire [31:0] selectedBout, extendedIns, shiftedAdr, IDEXextendedInsOut;

    wire [14:0] controlSignalMuxOut, CntOut;

    wire [5:0] func;
    wire [4:0] MEMWBselectedRegOut, EXMEMselectedRegOut, selectedRegOut, IDEXrtOut, IDEXrdOut, IDEXrsOut;
    wire [2:0] EXMEMWBout, IDEXWBout, ALUop;
    wire [1:0] PCsrc, forwardA, forwardB, INOp, IDEXMout;
    wire regWrite, memToReg, memRead, memWrite, zero, regDst, branch, jump, ALUsrc, EXNop, isRegEq, PCStall;

    // Instruction Fetch
    shiftLeft2 #(28) shiftIns ({2'b00, IFIDinstructionOut[25:0]}, shiftedIns);
    assign pcJump = {pcAdded[31:28], shiftedIns};

    mux3to1 pcMux(pcEq, pcAdded, pcJump, PCsrc, pcIn);
    register pc(rst, (~PCStall), clk, pcIn, pcOut);
    instructionMem insMem(pcOut, instruction);
    adder pcPlus4(pcOut, 32'd4, pcAdded);

    register IFIDpc((rst | IFFlush), (~IFstall), clk, pcAdded, IFIDpcOut);
    register IFIDinstruction((rst | IFFlush), (~IFstall), clk, instruction, IFIDinstructionOut);

    // Instruction Decode
    control cu(IFIDinstructionOut, CntOut[14], Jal, CntOut[2], CntOut[0], CntOut[5], CntOut[13:12], branch, jump, CntOut[4], CntOut[3], CntOut[1]);
    HDU hdu(IDEXMout[1], IDEXrtOut, IFIDinstructionOut[25:21], IFIDinstructionOut[20:16], branch, jump, isRegEq, IFstall, PCStall, IFFlush, EXNop, PCsrc);

    SignExtend signEx(IFIDinstructionOut[15:0], extendedIns);
    shiftLeft2 shiftAdr(extendedIns, shiftedAdr);
    registerFile regFile(clk, IFIDinstructionOut[25:21], IFIDinstructionOut[20:16],
                        MEMWBselectedRegOut, regWrite, writeData, regAout, regBout);
    comprator compReg(regAout, regBout, isRegEq);
    adder pcPlusEq(IFIDpcOut, shiftedAdr, pcEq);
    mux2to1 #(15) controlSignalMux({CntOut[14:12], IFIDinstructionOut[5:0], CntOut[5:0]}, 15'd0, EXNop, controlSignalMuxOut);

    register #(3) IDEXWB(rst, 1'b1, clk, controlSignalMuxOut[2:0], IDEXWBout);
    register #(2) IDEXM(rst, 1'b1, clk, controlSignalMuxOut[4:3], IDEXMout);
    register #(10) IDEXEX(rst, 1'b1, clk, controlSignalMuxOut[14:5], {regDst, INOp, func, ALUsrc});
    register IDEXregA(rst, 1'b1, clk, regAout, IDEXregAout);
    register IDEXregB(rst, 1'b1, clk, regBout, IDEXregBout);
    register IDEXsignEX(rst, 1'b1, clk, extendedIns, IDEXextendedInsOut);
    register #(5) IDEXrs(rst, 1'b1, clk, IFIDinstructionOut[25:21], IDEXrsOut);
    register #(5) IDEXrt(rst, 1'b1, clk, IFIDinstructionOut[20:16], IDEXrtOut);
    register #(5) IDEXrd(rst, 1'b1, clk, IFIDinstructionOut[15:11], IDEXrdOut);

    // Execution
    forwardUnit fu(EXMEMWBout[2], EXMEMselectedRegOut, regWrite, MEMWBselectedRegOut, IDEXrsOut, IDEXrtOut, forwardA, forwardB);

    mux3to1 aluSelA(IDEXregAout, writeData, EXMEMALUresOut, forwardA, ALUsrcA);
    mux3to1 aluSelB(IDEXregBout, writeData, EXMEMALUresOut, forwardB, selectedBout);
    mux2to1 selectB(selectedBout, IDEXextendedInsOut, ALUsrc, ALUsrcB);
    mux2to1 #(5) regSel(IDEXrtOut, IDEXrdOut, regDst, selectedRegOut);
    ALUDP aluDP(ALUsrcA, ALUsrcB, ALUop, zero, ALURes);
    ALUCU aluCU(INOp, func, ALUop);

    register #(3) EXMEMWB(rst, 1'b1, clk, IDEXWBout, EXMEMWBout);
    register #(2) EXMEMM(rst, 1'b1, clk, IDEXMout, {memRead, memWrite});
    register EXMEMALUres(rst, 1'b1, clk, ALURes, EXMEMALUresOut);
    register EXMEMALUsrcB(rst, 1'b1, clk, selectedBout, EXMEMALUsrcBOut);
    register #(5) EXMEMselectedReg(rst, 1'b1, clk, selectedRegOut, EXMEMselectedRegOut);

    // Memory
    dataMem dMem(clk, EXMEMALUresOut, EXMEMALUsrcBOut, memRead, memWrite, memOut);

    register #(3) MEMWBWB(rst, 1'b1, clk, EXMEMWBout, {regWrite, memToReg, slt});
    register MEMWBMem(rst, 1'b1, clk, memOut, MEMWBMemOut);
    register MEMWBALURes(rst, 1'b1, clk, EXMEMALUresOut, MEMWBALUresOut);
    register #(5) MEMWBselectedReg(rst, 1'b1, clk, EXMEMselectedRegOut, MEMWBselectedRegOut);

    // Write Back
    mux2to1 memOrALU(MEMWBALUresOut, MEMWBMemOut, memToReg, memOrALUout);
    mux2to1 sltMux(memOrALUout, {31'b0, MEMWBALUresOut[31]}, slt, writeData);




endmodule