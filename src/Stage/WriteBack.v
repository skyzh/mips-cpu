`timescale 1ns / 1ps

module WriteBack(
    input [`WORD] pc,
    input [`WORD] mem_out,
    input [`WORD] alu_out,
    input [`REG] mem_rf_dest,
    input [`OP] opcode,
    output [`REG] rf_dest,
    output [`WORD] rf_data,
    output rf_write
);
    wire is_branch;
    /* verilator lint_off PINMISSING */
    BranchOp branchOp(
        .opcode (opcode), 
        .branch_op (is_branch)
    );
    /* verilator lint_on PINMISSING */

    wire is_mem_store;
    wire is_mem_load;

    /* verilator lint_off PINMISSING */
    MemoryOp memoryOp(
        .opcode (opcode),
        .store (is_mem_store),
        .load (is_mem_load));
    /* verilator lint_on PINMISSING */

    assign rf_data = is_mem_load ? mem_out : alu_out;
    assign rf_write = !is_branch && !is_mem_store && opcode != 2;
    assign rf_dest = mem_rf_dest;
endmodule
