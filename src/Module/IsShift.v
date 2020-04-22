`timescale 1ns / 1ps

module IsShift(
    input [5:0] funct,
    output reg shift);

    always @ (funct) begin
        case (funct)
            6'h02: shift = 0;
            6'h03: shift = 0;
            6'h00: shift = 0;
            default: shift = 1;
        endcase
    end
endmodule
