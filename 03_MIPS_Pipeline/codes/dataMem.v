module dataMem (clk, address, writeData, memRead, memWrite, out);
    parameter size = (1 << 11); 
    input [31:0] address, writeData;
    input clk, memRead, memWrite;
    output reg [31:0] out;
	
    reg [31:0] data [size-1:0];

    initial begin
		$readmemb("dataMem.txt", data);
    end

    always @(posedge clk) 
        if (memWrite) 
            data[address[31:2]] = writeData;
    
    always @(address, memRead) 
        if (memRead)
            out = data[address[31:2]];

endmodule