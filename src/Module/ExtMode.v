`timescale 1ns / 1ps

// This module checks if an operation requires zero extenstion
module ExtMode(
    input [5:0] opcode,
    output reg signExt);

    always @ (opcode) begin
        case (opcode)
            6'h0c: signExt = 0;
            6'h0d: signExt = 0;
            6'h0e: signExt = 0;
            6'h24: signExt = 0;
            6'h25: signExt = 0;
            default: signExt = 1;
        endcase
    end
endmodule
