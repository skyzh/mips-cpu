`timescale 1ns / 1ps

// This module checks if an operation requires shamt
module IsShift(
    input [5:0] funct,
    output reg shift);

    always @ (funct) begin
        case (funct)
            6'h02: shift = 1;
            6'h03: shift = 1;
            6'h00: shift = 1;
            default: shift = 0;
        endcase
    end
endmodule
