`timescale 1ns / 1ns

module CPU_tb;
    reg reset;
    reg clk;

    parameter PERIOD = 10;
    always #(PERIOD) clk = !clk;
    
    CPU cpu (clk, reset);

    integer i;

    initial begin
        $dumpfile("result.vcd");
        $dumpvars;
        reset = 1;
        clk = 0;
        #30;
        reset = 0;
        #2000;
        reset = 1;
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%-2d %x %d", i, cpu.rf.regs[i], cpu.rf.regs[i]);
        end
        $display("ALEX_TEST_SUCCESS");
        $finish;
    end
endmodule
