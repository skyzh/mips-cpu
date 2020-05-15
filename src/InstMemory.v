`timescale 1ns / 1ps

module InstMemory(
    input clk,
    input [31:0] address,
    input reset,
    output reg [31:0] readData,
    output reg ready);

    parameter mem_size = 65536;
    // parameter mem_file = "C:/Archlabs/mips_cpu/mips_hex/2-basic-arithmetic.dat";
    parameter mem_file = "mips_hex/2-basic-arithmetic.mem";
    // parameter mem_file = "mips_hex/3-basic-compare.mem";
    // parameter mem_file = "mips_hex/4-branch.mem";
    // parameter mem_file = "mips_hex/5-simple-mem.mem";
    // parameter mem_file = "mips_hex/6-mem.mem";
    // parameter mem_file = "mips_hex/load-use.mem";
    // parameter mem_file = "mips_hex/2-basic-arithmetic.mem";

    reg [31:0] memFile [0:mem_size];
    reg [3:0] ready_cycle;

    integer i;
    initial begin
        for(i = 0; i < mem_size; i = i + 1) begin
			memFile[i] = 0;
		end
        $readmemh(mem_file, memFile);
    end

    always @ (address) begin
        ready_cycle = 0;
        ready = 0;
    end
        
    always @ (negedge clk) begin
        if (!ready) begin
            ready_cycle <= ready_cycle + 1;
            if (ready_cycle == 3) begin
                ready = 1;
                readData = memFile[address >>> 2];
            end
        end
    end

    always @ (negedge reset) begin
        ready = 0;
    end
endmodule
