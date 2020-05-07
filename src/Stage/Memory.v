`timescale 1ns / 1ps

module Memory(
    input [`WORD] ex_alu_out,
    input [`OP] ex_opcode,
    input [`WORD] ex_pc,
    input [`REG] ex_rf_dest,
    input [`WORD] ex_mem_data,
    output [`WORD] mem_pc,
    output [`WORD] mem_out,
    output [`WORD] mem_alu_out,
    output [`OP] mem_opcode,
    output [`REG] mem_rf_dest,
    // MODULE: Data Memory
    input [`WORD] dmem_out,
    output [`WORD] dmem_addr,
    output [`WORD] dmem_in,
    output dmem_write,
    output dmem_read,
    output [2:0] dmem_mode
);
    assign mem_pc = ex_pc;
    assign mem_out = dmem_out;
    assign mem_alu_out = ex_alu_out;
    assign mem_opcode = ex_opcode;
    assign mem_rf_dest = ex_rf_dest;

    /* verilator lint_off PINMISSING */
    MemoryOp memoryOp(
        .opcode (ex_opcode),
        .store (dmem_write),
        .load (dmem_read),
        .memory_mode (dmem_mode));
    /* verilator lint_on PINMISSING */
    assign dmem_addr = ex_alu_out;
    assign dmem_in = ex_mem_data;
    
endmodule
