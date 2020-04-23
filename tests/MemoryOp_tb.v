`timescale 1ns / 1ps

module MemoryOp_tb;
    reg [5:0] opcode;
    wire store;
    wire load;
    wire memory_op;
    wire [2:0] memory_mode;
    MemoryOp memoryOp(opcode, store, load, memory_op, memory_mode);

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
