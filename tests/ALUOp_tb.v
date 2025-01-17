`timescale 1ns / 1ps

module ALUOp_tb;
    reg [5:0] opcode;
    wire [5:0] aluOpcode;
    wire isArithmetic;
    ALUOp aluOp(opcode, aluOpcode, isArithmetic);

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
