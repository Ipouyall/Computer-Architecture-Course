module adder(a, b, w);
	parameter n = 20;
	input [n-1:0] a, b;
	output [n-1:0] w;

	assign w = a + b;
endmodule

module subtractor(a, b, w);
	parameter n = 20;
	input [n-1:0] a, b;
	output [n-1:0] w;

	assign w = a + ~b + 1'b1;
endmodule

module multiplier(a, b, p);
	parameter n = 20;
	input signed [n-1:0] a, b;
	output signed [2*n - 1:0] p;

	assign p = a * b;
endmodule

module divider(a, b, r);
	parameter n = 20;
	parameter f = 10;
	input signed [n-1:0] a, b;
	output signed [n-1:0] r;
	wire signed [n-1:0] p;
	assign p = b >>> (f);

	assign r = a / p;
endmodule

module register(rst, load, clk, d, q);
	parameter n = 20;
	input rst, load, clk;
	input [n-1:0] d;
	output reg [n-1:0] q;

	always @(posedge clk)
		if (rst)
			q <= {n{1'b0}};
		else if (load)
			q <= d;
		else 
			q <= q;
endmodule

module mux(a, b, s, w);
	parameter n = 20;
	input [n-1:0] a, b;
	input s;
	output [n-1:0] w;

	assign w = s ? b : a;
endmodule

module coefficient_calculator(mean_en, rst_temps, rst_means, clk, load_mean_x,
	load_mean_y, load_temps, x_bus, y_bus, beta0_bus, beta1_bus, select_150, select_y);
	input mean_en, rst_temps, rst_means, clk, load_mean_x, load_mean_y, load_temps, select_150, select_y;
	input [19:0] x_bus, y_bus;
	output [19:0] beta0_bus, beta1_bus;
	
	wire [39:0] x_ex, y_ex;
	wire [39:0] s_xx, s_xy;
	wire [39:0] x_sel, y_sel;
	wire [47:0] x_sel_ex, y_sel_ex;
	wire [47:0] x_add_res, y_add_res;
	wire [47:0] x_temp_res, y_temp_res;
	wire [47:0] divisor, dividend, divide_res;
	wire [47:0] one_hundred_fifty;
	wire [19:0] x_mean_res, y_mean_res;
	wire [19:0] x_sub_res, y_sub_res;
	wire [39:0] beta1_mean_x;

	assign one_hundred_fifty = {28'd150, 20'b0};

	assign x_ex = { {20{x_bus[19]}}, x_bus };
	assign y_ex = { {20{y_bus[19]}}, y_bus };

	mux #(40) x_mux(s_xx, x_ex, mean_en, x_sel);
	mux #(40) y_mux(s_xy, y_ex, mean_en, y_sel);

	assign x_sel_ex = { {8{x_sel[39]}}, x_sel };
	assign y_sel_ex = { {8{y_sel[39]}}, y_sel };

	register #(48) x_temp(rst_temps, load_temps, clk, x_add_res, x_temp_res);
	register #(48) y_temp(rst_temps, load_temps, clk, y_add_res, y_temp_res);

	adder #(48) x_adder(x_sel_ex, x_temp_res, x_add_res);
	adder #(48) y_adder(y_sel_ex, y_temp_res, y_add_res);

	register #(20) x_mean(rst_means, load_mean_x, clk, divide_res[19:0], x_mean_res);
	register #(20) y_mean(rst_means, load_mean_y, clk, divide_res[19:0], y_mean_res);

	subtractor #(20) x_sub(x_bus, x_mean_res, x_sub_res);
	subtractor #(20) y_sub(y_bus, y_mean_res, y_sub_res);

	multiplier #(20) x_mult(x_sub_res, x_sub_res, s_xx);
	multiplier #(20) y_mult(x_sub_res, y_sub_res, s_xy);

	mux #(48) dividend_mux(x_temp_res, y_temp_res, select_y, dividend);
	mux #(48) divisor_mux(x_temp_res, one_hundred_fifty, select_150, divisor);

	divider #(48, 20) div(dividend, divisor, divide_res);

	assign beta1_bus = divide_res[29:10];

	multiplier #(20) beta1_mean_x_mutl(beta1_bus, x_mean_res, beta1_mean_x);
	subtractor #(20) beta0_sub(y_mean_res, beta1_mean_x[29:10], beta0_bus);
endmodule
