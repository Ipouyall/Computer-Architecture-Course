    `timescale 1ps/1ps

module TB();
    reg clk=1'b1,rst=1'b1;

    proccesor p(.clk(clk),.rst(rst));

    always #10 clk <= ~clk;

    initial begin
        #10 rst = 1'b1;
        #20 rst = 1'b0;
    end

endmodule
