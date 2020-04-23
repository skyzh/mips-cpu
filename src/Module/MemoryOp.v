`timescale 1ns / 1ps

// This module decodes memory op
module MemoryOp(
    input [5:0] opcode,
    output reg store,
    output reg load,
    output reg memory_op,
    output reg [2:0] memory_mode);

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
        case (opcode)
            // lb, sb
            6'h20: memory_mode = 1;
            6'h28: memory_mode = 1;
            // lw, sw
            6'h23: memory_mode = 2;
            6'h2B: memory_mode = 2;
            default: memory_mode = 0;
        endcase
        memory_op = load | store;
    end
endmodule
