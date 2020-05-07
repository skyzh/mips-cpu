`timescale 1ns / 1ps

module InstFetch(
    input [`WORD] if_pc,
    output [`WORD] inst,
    output [`WORD] pc,
    output [`WORD] next_pc
);
    wire [`WORD] imem_addr = if_pc;
    InstMemory imem(
        .address (imem_addr),
        .readData (inst)
    );
    assign pc = if_pc;
    assign next_pc = pc + 4;
endmodule
