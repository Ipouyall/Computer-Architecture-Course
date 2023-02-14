module forwardUnit (input EXMEMRegWrite, input [4:0] EXMEMRegisterRd, input MEMWBRegWrite, input [4:0] MEMWBRegisterRd, IDEXRegisterRs, IDEXRegisterRt,
    output reg [1:0] forwardA, forwardB);

    always @(EXMEMRegWrite, EXMEMRegisterRd, MEMWBRegWrite, MEMWBRegisterRd, IDEXRegisterRs, IDEXRegisterRt) begin
        {forwardA, forwardB} = 4'b0000;
        if (EXMEMRegWrite && (EXMEMRegisterRd != 0) && (EXMEMRegisterRd == IDEXRegisterRs)) 
            forwardA = 2'b10;
        else if (MEMWBRegWrite && (MEMWBRegisterRd != 0) && ( MEMWBRegisterRd == IDEXRegisterRs))
            forwardA = 2'b01;
        else
            forwardA = 2'b00;

        if (EXMEMRegWrite && (EXMEMRegisterRd != 0) && (EXMEMRegisterRd == IDEXRegisterRt))
            forwardB = 2'b10;
        else if (MEMWBRegWrite && (MEMWBRegisterRd != 0) && (MEMWBRegisterRd == IDEXRegisterRt))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end   
endmodule