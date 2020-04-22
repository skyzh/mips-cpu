`timescale 1ns / 1ps

module SignExt(
    input [15:0] unextended,
    output reg [31:0] extended);

    always @ (unextended) begin
        extended = {{16{unextended[15]}}, unextended};
    end
endmodule
