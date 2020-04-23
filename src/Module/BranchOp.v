`timescale 1ns / 1ps

// This module checks if an operation requires shamt
module BranchOp(
    input [5:0] opcode,
    output reg branch_op);

    always @ (*) begin
        case (opcode)
            // beq
            6'h04: branch_op = 1;
            // bne
            6'h05: branch_op = 1;
            // bgez, bltz
            6'h01: branch_op = 1;
            // bgtz
            6'h07: branch_op = 1;
            // blez
            6'h06: branch_op = 1;        
            default: branch_op = 0;
        endcase
    end
endmodule
