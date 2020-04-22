`timescale 1ns / 1ps

module IsShift_tb;
    reg [5:0] funct;
    wire [5:0] shift;
    IsShift isShift(funct, shift);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        for (funct = 0; funct < 6'h3f; funct = funct + 1) begin
            #1;
        end
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
