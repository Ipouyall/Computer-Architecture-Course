module HDU (input IDEXMemRead, input [4:0] IDEXrt, IFIDrs, IFIDrt, input branch, jump, regEq,
    output reg IFstall, PCStall, IFFlush, EXNop, output reg [1:0] PCsrc);
    always @(IDEXMemRead, IDEXrt, IFIDrs, IFIDrt, branch, regEq, jump) begin
        {IFstall, PCStall, IFFlush, EXNop, PCsrc} = 6'b000001;
        if (branch && regEq)
            {IFFlush, EXNop, PCsrc} = 4'b1100;
        if (IDEXMemRead && ((IDEXrt == IFIDrs) || (IDEXrt == IFIDrt)))
            {IFstall, PCStall, EXNop} = 3'b111;
        if (jump)
            {IFFlush, EXNop, PCsrc} = 4'b1110;
    end
endmodule