`timescale 1ns / 1ps

module DataMemory(
    input clk,
    input [31:0] address,
    input [31:0] writeData,
    input memWrite,
    input memRead,
    input reset,
    output reg [31:0] readData);

    reg [31:0] memFile [0:63];
    
    always @ (negedge clk) begin
        if (memWrite)
            memFile[address] <= writeData;
    end

    always @ (*) begin
        if (reset)
            readData = 0;
        else if (memRead)
            readData = memFile[address];
    end
endmodule
