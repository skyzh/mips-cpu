`timescale 1ns / 1ps

module Registers_tb;
    reg clk;
    reg [4:0] readReg1;
    reg [4:0] readReg2;
    reg [4:0]   writeReg;
    reg [31:0] writeData;
    reg regWrite;
    wire [31:0] readData1;
    wire [31:0] readData2;

    parameter PERIOD = 10;
    always #(PERIOD*2) clk = !clk;

    RegisterFile registerFile(clk, readReg1, readReg2, writeReg, writeData, regWrite, 1'b0, readData1, readData2);
    
    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        clk = 1;
        #100;
        regWrite = 1;
        writeReg = 10;
        writeData = -1;
        #110;
        writeReg = 20;
        writeData = -2;
        #120;
        writeReg = 30;
        writeData = -3;
        #130;
        readReg1 = 20;
        readReg2 = 30;
        if (readData1 != -2 || readData2 != -3) begin
            $display("ALEX_TEST_FAILED %m");
            $finish;
        end
        #500;
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule