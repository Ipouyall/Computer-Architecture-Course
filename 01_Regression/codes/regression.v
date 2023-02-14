module regression(start, clk, rst, ready, vect_e);
	input start, clk, rst;
	output ready;
	output [19:0] vect_e;

	wire [7:0] address;
	wire [19:0] x_bus, y_bus, beta0_in_bus, beta0_out_bus, beta1_in_bus, beta1_out_bus;
	wire co, init_cnt, cnt_en, rst_beta, load_beta0, load_beta1, select_150, select_y,
		load_mean_x, load_mean_y, load_temps, rst_means, rst_temps, mean_en, error_en;

	counter count(init_cnt, clk, cnt_en, co, address);

	controller ctrl(rst, init_cnt, cnt_en, co, clk, rst_beta, rst_means, rst_temps, select_150, select_y,
	load_temps, load_mean_x, load_mean_y, load_beta0, load_beta1, mean_en, error_en, start, ready);

	data_loader dl(address, x_bus, y_bus);

	coefficient_calculator cc(mean_en, rst_temps, rst_means, clk, load_mean_x,
	load_mean_y, load_temps, x_bus, y_bus, beta0_in_bus, beta1_in_bus, select_150, select_y);

	register beta0(rst_beta, load_beta0, clk, beta0_in_bus, beta0_out_bus);
	register beta1(rst_beta, load_beta1, clk, beta1_in_bus, beta1_out_bus);

	error_checker ec(beta0_out_bus, beta1_out_bus, x_bus, y_bus, error_en, vect_e);
endmodule


