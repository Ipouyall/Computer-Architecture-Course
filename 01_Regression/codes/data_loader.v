module data_loader(address, x_bus, y_bus);
	input [7:0] address;
	output [19:0] x_bus, y_bus;
	
	reg [19:0] x_mem[0:149];
	reg [19:0] y_mem[0:149];


	initial begin
		$readmemb("x_value.txt", x_mem);
		$readmemb("y_value.txt", y_mem);
	end

	assign x_bus = x_mem[address];
	assign y_bus = y_mem[address];
	
endmodule
