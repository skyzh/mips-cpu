`timescale 1ns / 1ps

module Execute(
    input [`OP] alu_op,
    input [`WORD] alu_src1,
    input [`WORD] alu_src2,
    input [`OP] id_opcode,
    input [`WORD] id_pc,
    input alu_branch_mask,
    input [`WORD] branch_pc,
    input [`WORD] next_pc,
    input [`REG] id_rf_dest,
    input [`WORD] id_mem_data,
    input id_branch_taken,
    input force_jump,
    output [`WORD] alu_out,
    output [`OP] ex_opcode,
    output [`WORD] ex_pc,
    output [`REG] ex_rf_dest,
    output [`WORD] ex_mem_data,
    output correct_branch_prediction,
    output [`WORD] branch_jump_target
);
    assign ex_mem_data = id_mem_data;
    assign ex_rf_dest = id_rf_dest;
    assign ex_opcode = id_opcode;
    
    ALU alu (
            .ALUopcode (alu_op), 
            .op1 (alu_src1),
            .op2 (alu_src2),
            .out (alu_out),
            .zero (alu_zero));

    // MODULE: Branch
    wire is_branch;
    BranchOp branchOp(
        .opcode (opcode), 
        .branch_op (is_branch)
    );

    wire take_branch = is_branch && (alu_zero ^ alu_branch_mask);
    assign ex_pc = take_branch ? branch_pc : next_pc;

    assign correct_branch_prediction = 
        !((take_branch != id_branch_taken) || force_jump);

    assign branch_jump_target = (take_branch != id_branch_taken) ? ex_pc :
        (force_jump ? next_pc : 0);

endmodule