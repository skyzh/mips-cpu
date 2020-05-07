`timescale 1ns / 1ps

// This module generates alu for branch op
module BranchOut(
    input [5:0] opcode,
    input [`REG] rt,
    output reg alu_branch_mask);

    always @ (*) begin
        case (opcode)
            // beq
            6'h04: alu_branch_mask = 0;
            // bne
            6'h05: alu_branch_mask = 1;
            // bgez, bltz
            6'h01: alu_branch_mask = rt == 0;
            // bgtz
            6'h07: alu_branch_mask = 0;
            // blez
            6'h06: alu_branch_mask = 1;
            default: alu_branch_mask = 0;
        endcase
    end
endmodule
