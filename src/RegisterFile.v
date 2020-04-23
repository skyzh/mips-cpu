`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input [4:0] src1,
    input [4:0] src2,
    input [4:0] dest,
    input [31:0] data,
    input write,
    input reset,
    output reg [31:0] out1,
    output reg [31:0] out2);

    reg [31:0] regs [31:0];
    
    always @ (negedge clk) begin
        if (write) begin
            regs[dest] <= data;
        end
    end
    
    always @ (src1 or reset) begin
        if (src1 == 0 || reset)
            out1 = 0;
        else
            out1 = regs[src1];
    end

    always @ (src2 or reset) begin
        if (src2 == 0 || reset)
            out2 = 0;
        else
            out2 = regs[src2];
    end
endmodule
