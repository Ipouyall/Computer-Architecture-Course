    `timescale 1ps/1ps

module dataPath(clk,rst,PCWrite,PCWriteCond,IorD,DM,MemWrite,
                MemRead,IRWrite,ARS,MemToReg,RegWrite,
                IMS,NI,ALUop,PCSrc,instruction);

    input clk,rst,PCWrite,PCWriteCond,IorD,DM,MemWrite,MemRead,IRWrite,
            ARS,RegWrite,IMS,NI;
    input [2:0] ALUop;
    input [1:0] PCSrc,MemToReg;
    output[15:0] instruction;

    // wires for multiplexers' outputs
    wire[11:0] m_pcsrc,m_iord,m_dm;
    wire[15:0] m_mtor,m_ims,m_ni_top,m_ni_bottom;
    wire[3:0] m_ars;

    // wires for registers' outputs
    wire[15:0] reg_IR,reg_MDR,reg_A,reg_B,reg_ALUout;

    // other components outputs
    wire alu_zero, pc_write;
    wire[15:0] alu_res,readdata1,readdata2,readdata,se_IR;
    wire[11:0] pc_res;


    // PC area
    assign pc_write = (PCWrite | (PCWriteCond & alu_zero));
    PC pc(clk,rst,pc_write,m_pcsrc,pc_res);

    // PC to memory area
    Mux2to1 #(12) m1 (IorD, pc_res, alu_res[11:0], m_iord);
    Mux2to1 #(12) m2 (DM, m_iord, reg_IR[11:0], m_dm);

    // memory area
    Memory memory(clk,MemRead,MemWrite,m_dm,reg_B,readdata);
    Register ir(clk,rst,IRWrite,readdata,reg_IR);
    Register mdr(clk,rst,1'b1,readdata,reg_MDR);

    // memory to register_file area
    Mux2to1 #(3) m3 (ARS, reg_IR[11:9], 3'd0, m_ars);
    Mux3to1 #(16) m4 (MemToReg, reg_B, reg_MDR, reg_ALUout, m_mtor);

    // register_file area
    Reg_file rf(clk,RegWrite,reg_IR[11:9],m_ars,m_ars,
                m_mtor,readdata1,readdata2);
    Register a(clk,rst,1'b1,readdata1,reg_A);
    Register b(clk,rst,1'b1,readdata2,reg_B);
    Sign_extend ss(reg_IR[11:0],se_IR);

    // register_file to ALU area
    Mux2to1 #(16) m5 (IMS, reg_A, se_IR, m_ims);
    Mux2to1 #(16) m6 (NI, m_ims, {4'd0,pc_res}, m_ni_top);
    Mux2to1 #(16) m7 (NI, reg_B, 16'd1, m_ni_bottom);

    // ALU area
    alu_dp aluDataPath(m_ni_top,m_ni_bottom,ALUop,alu_zero,alu_res);

    // right side
    Register aluOut(clk,rst,1'b1,alu_res,reg_ALUout);
    Mux3to1 #(12) m8 (PCSrc, alu_res[11:0], reg_IR[11:0], {pc_res[11:9],reg_IR[8:0]}, m_pcsrc);

    // send inst. for controller
    assign instruction = reg_IR;
endmodule
