    `timescale 1ps/1ps

`define MEMORY_SIZE 4095

module Memory(clk,mem_read,mem_write,addr,write_data,read_data);
    input clk,mem_read,mem_write;
    input [11:0]addr;
    input [15:0]write_data;
    output [15:0]read_data;

    reg [15:0] mem [`MEMORY_SIZE:0];

    initial
        $readmemb("memory.txt",mem);
    
    assign read_data=(mem_read) ? mem[addr] : read_data;

    always @(posedge clk)
        if(mem_write)begin
            mem[addr]=write_data;
            $writememb("memory.txt",mem);
        end

endmodule