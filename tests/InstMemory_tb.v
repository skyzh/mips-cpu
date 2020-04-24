`timescale 1ns / 1ps

module InstMemory_tb;
    reg clk;
    reg [31:0] address;
    wire [31:0] readData;

    parameter PERIOD = 10;
    always #(PERIOD*2) clk = !clk;

    InstMemory instMemory(clk, address, readData);
    
    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        clk = 1;
        #20;
        address = 0;
        #20;
        address = 1;
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
