`timescale 1ns / 1ps

module SignExt_tb;
    reg signed [15:0] unextended;
    wire signed [31:0] extended;
    SignExt signExt(unextended, extended);

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        for (unextended = -32768; unextended < 32767; unextended = unextended + 1) begin
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
