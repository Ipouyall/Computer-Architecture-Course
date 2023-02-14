    `timescale 1ps/1ps

module mips_tb();

    reg clk=1'b0,rst=1'b1;

    MIPS mips(clk,rst);

    initial
        #15 rst=1'b0;
    
    always #10 clk <= ~clk;

endmodule
