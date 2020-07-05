`timescale 1ns / 1ps

module InstMemory(
    input [31:0] address,
    output [31:0] data);

    parameter mem_size = 65536;
    // parameter mem_file = "2-basic-arithmetic.mem";
    // parameter mem_file = "3-basic-compare.mem";
    // parameter mem_file = "4-branch.mem";
    // parameter mem_file = "5-simple-mem.mem";
    parameter mem_file = "6-mem.mem";
    // parameter mem_file = "load-use.mem";
    // parameter mem_file = "control-hazard.mem";
    // parameter mem_file = "data-hazard.mem.mem";

    reg [31:0] memFile [0:mem_size];

    integer i;
    initial begin
        for(i = 0; i < mem_size; i = i + 1) begin
			memFile[i] = 0;
		end
        $readmemh(mem_file, memFile);
    end

    assign data = memFile[address >>> 2];
endmodule
