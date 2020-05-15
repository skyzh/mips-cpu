`timescale 1ns / 1ps

module InstFetch(
    input [`WORD] if_pc,
    output [`WORD] inst,
    output [`WORD] pc,
    output [`WORD] next_pc,
    output [`WORD] inst_pc,
    input inst_ready,
    input [`WORD] if_inst
);
    wire [`WORD] imem_addr = if_pc;
    assign inst_pc = if_pc;
    assign inst = inst_ready ? if_inst : 0;
    assign pc = if_pc;
    assign next_pc = inst_ready ? pc + 4 : pc;
endmodule
