module counter(sr, clk, cnt, co, out);
	input sr, clk, cnt;
	output co;
	output reg [7:0] out;

	always @(posedge clk)
		if (sr)
			out <= 8'b0;
		else if (cnt)
			if (out == 149)
				out <= 8'b0;
			else
				out <= out + 1'b1;

	assign co = (out == 149) ? 1'b1 : 1'b0;
endmodule

`define idle 4'd0
`define init 4'd1
`define input_sum 4'd2
`define save_mean_x 4'd3
`define save_mean_y 4'd4
`define partial_sum 4'd5
`define save_beta1 4'd6
`define save_beta0 4'd7
`define cal_err 4'd8

module controller(rst, init_cnt, cnt_en, cnt_co, clk, rst_beta, rst_means, rst_temps, select_150, select_y,
	load_temps, load_mean_x, load_mean_y, load_beta0, load_beta1, mean_en, error_en, start, ready);
	input rst, cnt_co, clk, start;
	output reg init_cnt, cnt_en, rst_beta, rst_means, rst_temps, load_temps, select_150, select_y,
		load_mean_x, load_mean_y, load_beta0, load_beta1, mean_en, error_en, ready;

	reg[3:0] ps, ns;

	always @(posedge clk)
		if (rst)
			ps <= `idle;
		else
			ps <= ns;


	always @(ps, start, cnt_co) begin
		ns = `idle;
		case (ps)
			`idle: ns = start ? `init : `idle;
			`init: ns = start ? `init : `input_sum;
			`input_sum: ns = cnt_co ? `save_mean_y : `input_sum;
			`save_mean_y: ns = `save_mean_x;
			`save_mean_x: ns = `partial_sum;
			`partial_sum: ns = cnt_co ? `save_beta1 : `partial_sum;
			`save_beta1: ns = `save_beta0;
			`save_beta0: ns = `cal_err;
			`cal_err: ns = cnt_co ? `idle : `cal_err;
			default: ns = `idle;
		endcase
	end

	always @(ps) begin
		{init_cnt, cnt_en, rst_beta, rst_means, rst_temps, load_temps, select_150, select_y,
		 load_mean_x, load_mean_y, load_beta0, load_beta1, mean_en, error_en, ready} = 15'b0;

		case (ps)
			`idle: {ready} = 1'b1;
			`init: {init_cnt, rst_beta, rst_means, rst_temps} = 4'b1111;
			`input_sum: {cnt_en, load_temps, mean_en} = 3'b111;
			`save_mean_y: {load_mean_y, select_150, select_y} = 3'b111;
			`save_mean_x: {load_mean_x, select_150, init_cnt, rst_temps} = 4'b1111;
			`partial_sum: {cnt_en, load_temps} = 2'b11;
			`save_beta1: {load_beta1, select_y} = 2'b11;
			`save_beta0: {load_beta0, init_cnt, select_y} = 3'b111;
			`cal_err: {error_en, cnt_en} = 2'b11;
			default: ;
		endcase
	end

endmodule
		

