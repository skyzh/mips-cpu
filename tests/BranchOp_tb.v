`timescale 1ns / 1ps

module BranchOp_tb;
    reg [5:0] opcode;
    wire [5:0] is_branch;
    wire override_rt;
    wire [31:0] rt_val;
    BranchOp branchOp(opcode, is_branch, override_rt, rt_val);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        for (opcode = 0; opcode < 6'h3f; opcode = opcode + 1) begin
            #1;
        end
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
