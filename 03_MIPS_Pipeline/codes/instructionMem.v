module instructionMem (pc, out);
    parameter size = (1 << 11); 
    input [31:0] pc;
    output reg [31:0] out;

    reg [31:0] instruction [size-1:0];

    initial begin
		$readmemb("instructionMem.txt", instruction);
	end

    always @ (pc)
		out = instruction[pc[31:2]];
            
endmodule