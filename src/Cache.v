`timescale 1ns / 1ps

module Cache(
    input clk,
    input [`WORD] address,
    input reset,
    output[`WORD] data,
    output ready,
    // MODULE: Inst Memory
    input [`WORD] inst_data,
    output reg [`WORD] inst_addr);

    parameter cache_size = 256;

    reg valid [255:0];
    reg [21:0] cache_tag [255:0];
    reg [`WORD] cache_line [255:0];

    integer i;

    always @ (negedge reset) begin
        for (i = 0; i < cache_size; i++) begin
            valid[i] = 0;
        end
    end
    
    wire [21:0] tag = address[31:10];
    wire [7:0] index = address[9:2];

    wire [21:0] inst_tag = inst_addr[31:10];
    wire [7:0] inst_index = inst_addr[9:2];

    assign ready = (tag == cache_tag[index] && valid[index]);
    assign data = ready ? cache_line[index] : 0;

    always @ (negedge clk) begin
        inst_addr <= address;
        valid[inst_index] <= 1;
        cache_tag[inst_index] <= inst_tag;
        cache_line[inst_index] <= inst_data;
    end
endmodule
