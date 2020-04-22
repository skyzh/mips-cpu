`timescale 1ns / 1ps

module ZeroExt_tb;
    reg [15:0] unextended;
    wire [31:0] extended;
    ZeroExt zeroExt(unextended, extended);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        for (unextended = 0; unextended < 65535; unextended = unextended + 1) begin
            #1;
            if (unextended != extended) begin
                $display("ALEX_TEST_FAILED %m");
                $finish;
            end
        end
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
