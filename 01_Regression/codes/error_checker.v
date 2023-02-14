module error_checker(B_0, B_1, x_i, y_i, en, err);
    input[19:0] B_0,B_1;
    input[19:0] x_i,y_i;
    input en;
    output[19:0] err;

    wire [39:0] pr;
    wire [19:0] h_x, out;

    multiplier m1(B_1,x_i,pr);
    adder m2(B_0,pr[29:10],h_x);
    subtractor m3(y_i,h_x,out);

    assign err = (en) ? out : 20'bz;
endmodule
