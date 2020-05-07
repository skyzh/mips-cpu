`timescale 1ns / 1ps

module InstDecode(
    input [`WORD] inst,
    input [`WORD] if_pc,
    input if_branch_taken,
    output [`OP] alu_op,
    output [`WORD] alu_src1,
    output [`WORD] alu_src2,
    output [`OP] opcode,
    output [`WORD] id_pc,
    output alu_branch_mask,
    output [`WORD] branch_pc,
    output [`WORD] next_pc,
    output [`REG] rf_dest,
    output [`WORD] mem_data,
    output id_branch_taken,
    output force_jump,
    // MODULE: Forward
    input forward_depends_1,
    input forward_depends_2,
    input forward_stalls_1,
    input forward_stalls_2,
    input [`WORD] forward_result_1,
    input [`WORD] forward_result_2,
    output wire [`REG] forward_op1,
    output wire [`REG] forward_op2,
    // MODULE: RegisterFile
    output wire [`REG] rf_src1,
    output wire [`REG] rf_src2,
    input wire [`WORD] rf_out1_prev,
    input wire [`WORD] rf_out2_prev
);
    wire [`WORD] pc = if_pc;
    assign opcode = inst[31:26];
    wire [`REG] rs = inst[25:21];
    wire [`REG] rt = inst[20:16];
    wire [`REG] rd = inst[15:11];
    wire [`REG] shamt = inst[10:6];
    wire [`OP] funct = inst[`OP];
    wire [1`OP] imm = inst[1`OP];
    wire [`WORD] imm_sign_ext;
    wire [`WORD] imm_zero_ext;
    wire [`WORD] shamt_zero_ext = {{27'b0}, shamt};
    SignExt signExt(.unextended (imm), .extended (imm_sign_ext));
    ZeroExt zeroExt(.unextended (imm), .extended (imm_zero_ext));
    wire is_shift;
    IsShift isShift(.funct (funct), .shift (is_shift));
    wire is_type_R = (opcode == 0);
    wire use_shamt = is_shift && is_type_R;
    wire [`WORD] jump_target = {4'b00, inst[2`OP], 2'b00} | (pc & 32'hf0000000);
    wire is_branch;
    wire is_memory;

    // MODULE: Register File
    assign rf_src1 = rs;
    assign rf_src2 = is_type_R || is_branch || is_memory_store ? rt : 0;
    assign rf_dest =  is_type_R ? rd : (
                            opcode == 3 ? 31 : rt);
    wire [`WORD] rf_out1 = forward_depends_1 ? forward_result_1 : rf_out1_prev;
    wire [`WORD] rf_out2 = override_rt ? branch_alu_rt_val : 
                            (forward_depends_2 ? forward_result_2 : rf_out2_prev);
    
    // MODULE: Branch
    wire [`WORD] imm_offset = imm_sign_ext <<< 2;
    assign branch_pc = pc + 4 + imm_offset;
    assign next_pc = (opcode == 2 || opcode == 3) ? jump_target :
                            (opcode == 0 && funct == 8 ? rf_out1 : pc + 4);
    wire override_rt;
    wire [`WORD] branch_alu_rt_val;
    BranchOp branchOp(
        .opcode (opcode), 
        .branch_op (is_branch),
        .override_rt (override_rt),
        .rt_val (branch_alu_rt_val)
    );
    BranchOut branchOut(
        .opcode (opcode),
        .rt (rt),
        .alu_branch_mask (alu_branch_mask)
    );
    assign force_jump = opcode == 2 || opcode == 3 || (opcode == 0 && funct == 8);

    // MODULE: Forward
    assign forward_op1 = rf_src1;
    assign forward_op2 = rf_src2;
    wire alu_use_rf_out_1;
    wire alu_use_rf_out_2;
    wire stall = (alu_use_rf_out_1 && forward_stalls_1) || 
                    (alu_use_rf_out_2 && forward_stalls_2) ||
                    (is_memory_store && forward_stalls_2);

    
    // MODULE: Memory
    wire [`OP] mapped_op;
    ALUOp aluOp(
        .opcode (opcode), 
        .ALUopcode (mapped_op));
    wire is_memory_load;
    wire is_memory_store;
    wire [2:0] memory_mode;
    MemoryOp memoryOp(
        .opcode (opcode),
        .store (is_memory_store),
        .load (is_memory_load),
        .memory_op (is_memory),
        .memory_mode (memory_mode));
    assign mem_data = forward_depends_2 ? forward_result_2 : rf_out2;

    // MODULE: ALU
    wire ext_mode;
    ExtMode extMode (
        .opcode (opcode),
        .signExt (ext_mode));
    assign alu_op = is_type_R ? funct : mapped_op;
    wire [`WORD] alu_imm = ext_mode ? imm_sign_ext : imm_zero_ext;
    assign alu_use_rf_out_1 = !use_shamt && opcode != 3;
    assign alu_use_rf_out_2 = is_type_R || is_branch;
    assign alu_src1 = use_shamt ? shamt_zero_ext : 
                            (opcode == 3 ? pc : rf_out1);
    assign alu_src2 = alu_use_rf_out_2 ? rf_out2 :
                            (opcode == 3 ? 4 : alu_imm);

    // Other Modules
    assign id_pc = pc;
    assign id_branch_taken = if_branch_taken;
endmodule
