`timescale 1ns / 1ps

// This module decodes branch op
module BranchOp(
    input [5:0] opcode,
    output reg branch_op,
    output reg override_rt,
    output reg [31:0] rt_val);

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
        case (opcode)
            // blez
            6'h06: begin override_rt = 1; rt_val = 1; end
            // bgtz
            6'h07: begin override_rt = 1; rt_val = 1; end
            // bgez, bltz
            6'h01: begin override_rt = 1; rt_val = 0; end
            default: begin override_rt = 0; rt_val = 0; end
        endcase
    end
endmodule
