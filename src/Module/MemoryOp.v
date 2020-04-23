`timescale 1ns / 1ps

// This module checks if an operation requires shamt
module MemoryOp(
    input [5:0] opcode,
    output reg store,
    output reg load,
    output reg memory_op);

    always @ (*) begin
        case (opcode)
            6'h20: load = 1;
            6'h23: load = 1;
            default: load = 0;
        endcase
        case (opcode)
            6'h28: store = 1;
            6'h2b: store = 1;
            default: store = 0;
        endcase
        memory_op = load | store;
    end
endmodule
