`timescale 1ns / 1ps

module DataMemory_tb;
    reg clk;
    reg [31:0] address;
    reg [31:0] writeData;
    reg memWrite;
    reg memRead;
    wire [31:0] readData;

    parameter PERIOD = 10;
    always #(PERIOD*2) clk = !clk;

    DataMemory dataMemory(clk, address, writeData, memWrite, memRead, 1'b0, readData);
    
    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        clk = 1;
        #20;
        memWrite = 1;
        address = 10;
        writeData = 100;
        #20;
        address = 20;
        writeData = 200;
        #20;
        memWrite = 0;
        memRead = 1;
        address = 10;
        #1;
        if (readData != 100) begin
            $display("ALEX_TEST_FAILED %m %d", readData);
            $finish;
        end
        #20;
        address = 20;
        #1;
        if (readData != 200) begin
            $display("ALEX_TEST_FAILED %m %d", readData);
            $finish;
        end
        #20;
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
