`timescale 1ns / 1ps

module InstMemory(
    input wire clk,
    input [31:0] address,
    output [31:0] readData);

    parameter mem_size = 65536;
    // parameter mem_file = "C:/Archlabs/mips_cpu/mips_hex/2-basic-arithmetic.dat";
    parameter mem_file = "mips_hex/7-jump.mem";

    reg [31:0] memFile [0:mem_size];

    integer i;
    initial begin
        for(i = 0; i < mem_size; i = i + 1) begin
			memFile[i] = 0;
		end
        $readmemh(mem_file, memFile);
    end

    assign readData = memFile[address >>> 2];
endmodule
