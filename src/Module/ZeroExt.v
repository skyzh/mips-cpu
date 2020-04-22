`timescale 1ns / 1ps

module ZeroExt(
    input [15:0] unextended,
    output reg [31:0] extended);

    always @ (unextended) begin
        extended = {{16{'0}}, unextended};
    end
endmodule
