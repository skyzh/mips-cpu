`timescale 1ns / 1ps

module DataMemory(
    input clk,
    input [31:0] address,
    input [31:0] writeData,
    input [2:0] mode,
    input memWrite,
    input memRead,
    input reset,
    output [31:0] readData);

    parameter mem_size = 65536;
    reg [7:0] memFile [0:mem_size];
    
    always @ (negedge clk) begin
        if (memWrite)
            case (mode)
                1: memFile[address] <= writeData[7:0];
                2: begin 
                    // assume little endian
                    memFile[address] <= writeData[7:0];
                    memFile[address + 1] <= writeData[15:8];
                    memFile[address + 2] <= writeData[23:16];
                    memFile[address + 3] <= writeData[31:24];
                end
            endcase
    end

    assign readData = (reset || !memRead) ? 0 : (
        mode == 1 ? {{24{memFile[address][7]}}, memFile[address]} : (
            mode == 2 ? {memFile[address + 3], memFile[address + 2], memFile[address + 1], memFile[address]} : 0
        ));
endmodule
