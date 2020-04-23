`timescale 1ns / 1ps

// This module decides whether to take branch
module TakeBranch(
    input [5:0] opcode,
    input [4:0] rt,
    input alu_zero,
    output reg take_branch);

    always @ (*) begin
        casez ({opcode, rt[3:0]})
            10'h4?: take_branch = alu_zero;
            10'h5?: take_branch = !alu_zero;
            10'h11: take_branch = alu_zero;
            10'h10: take_branch = !alu_zero;
            10'h70: take_branch = alu_zero;
            10'h60: take_branch = !alu_zero;
            default: take_branch = 0;
        endcase
    end
endmodule
