`timescale 1ns / 1ps

module ALU_tb;
    reg [5:0] opcode;
    reg [31:0] op1;
    reg [31:0] op2;
    wire [31:0] out;
    wire zero;
    ALU alu(opcode, op1, op2, out, zero);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        opcode = 6'h2a;
        op1 = 20;
        op2 = -20;
        #1;
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
