`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input [4:0] src1,
    input [4:0] src2,
    input [4:0] dest,
    input [31:0] data,
    input write,
    input reset,
    output wire [31:0] out1,
    output wire [31:0] out2);

    reg [31:0] regs [31:0];

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 0;
        end
    end
    
    always @ (negedge clk) begin
        if (write) begin
            regs[dest] <= data;
        end
    end

    assign out1 = (src1 == 0 || reset) ? 0 : regs[src1];
    assign out2 = (src2 == 0 || reset) ? 0 : regs[src2];
endmodule
