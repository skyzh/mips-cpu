`timescale 1ns / 1ps

module TakeBranch_tb;
    reg [5:0] opcode;
    reg [4:0] rt;
    reg alu_zero;
    wire take_branch;
    TakeBranch takeBranch(opcode, rt, alu_zero, take_branch);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        for (opcode = 0; opcode < 6'h3f; opcode = opcode + 1) begin
            #1;
            rt = 0;
            alu_zero = 0;
            #1;
            rt = 1;
            alu_zero = 0;
            #1;
            rt = 0;
            alu_zero = 1;
            #1;
            rt = 1;
            alu_zero = 1;
        end
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
