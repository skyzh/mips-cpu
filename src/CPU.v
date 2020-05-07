`timescale 1ns / 1ps

`define WORD 31:0
`define REG 4:0
`define OP 5:0

module CPU(
    input wire clk,
    input reset);

    // PC Register
    reg [`WORD] pc;

    // Branch Prediction Result
    wire correct_branch_prediction;
    wire [`WORD] branch_jump_target;

    // --- STAGE ---
    //   InstFetch

    // --- INPUT ---
    wire [`WORD] if_pc = !correct_branch_prediction ? branch_jump_target : pc;

    // --- STAGE REGS ---
    reg [`WORD] stage_if_inst;
    reg [`WORD] stage_if_pc;
    reg stage_if_branch_taken;

    // --- OUTPUT ---
    wire [`WORD] out_if_next_pc;
    wire [`WORD] out_if_inst;
    wire [`WORD] out_if_pc;

    InstFetch instFetch(
        .if_pc (if_pc),
        .inst (out_if_inst),
        .pc (out_if_pc),
        .next_pc (out_if_next_pc)
    );

    wire out_id_stall;
    wire [`WORD] if_next_pc = out_id_stall ? if_pc : out_if_next_pc;

    // --- CLOCK ---
    always @ (negedge clk) begin
        if (!out_id_stall) begin
            stage_if_inst <= out_if_inst;
            stage_if_pc <= out_if_pc;
            stage_if_branch_taken <= 0; // branch prediction: always not taken
        end
    end

    // --- STAGE ---
    //   InstDecode
    // --- STAGE REGS ---
    reg [`OP] stage_id_alu_op;
    reg [`WORD] stage_id_alu_src1;
    reg [`WORD] stage_id_alu_src2;
    reg [`OP] stage_id_opcode;
    reg [`WORD] stage_id_pc;
    reg stage_id_alu_branch_mask;
    reg [`WORD] stage_id_branch_pc;
    reg [`WORD] stage_id_next_pc;
    reg [`REG] stage_id_rf_dest;
    reg [`WORD] stage_id_mem_data;
    reg stage_id_branch_taken;
    reg stage_id_force_jump;

    // --- STAGE INTERMEDIATES ---
    wire [`REG] out_id_forward_op1;
    wire [`REG] out_id_forward_op2;
    wire forward_depends_1;
    wire forward_depends_2;
    wire forward_stalls_1;
    wire forward_stalls_2;
    wire [`WORD] forward_result_1;
    wire [`WORD] forward_result_2;
    wire [`REG] rf_src1;
    wire [`REG] rf_src2;
    wire [`WORD] rf_out1;
    wire [`WORD] rf_out2;
    wire [`OP] out_id_alu_op;
    wire [`WORD] out_id_alu_src1;
    wire [`WORD] out_id_alu_src2;
    wire [`OP] out_id_opcode;
    wire [`WORD] out_id_pc;
    wire out_id_alu_branch_mask;
    wire [`WORD] out_id_branch_pc;
    wire [`WORD] out_id_next_pc;
    wire [`REG] out_id_rf_dest;
    wire [`WORD] out_id_mem_data;
    wire out_id_branch_taken;
    wire out_id_force_jump;

    Forward forward1();
    Forward forward2();

    wire [`REG] rf_dest;
    wire [`WORD] rf_data;
    wire rf_write;

    RegisterFile rf(
        .clk (clk),
        .src1 (rf_src1),
        .src2 (rf_src2),
        .dest (rf_dest),
        .data (rf_data),
        .write (rf_write),
        .out1 (rf_out1),
        .out2 (rf_out2),
        .reset (reset)
    );

    InstDecode instDecode(
        .if_pc (stage_if_pc),
        .inst (stage_if_inst),
        .if_branch_taken (stage_if_branch_taken),
        .alu_op (out_id_alu_op),
        .alu_src1 (out_id_alu_src1),
        .alu_src2 (out_id_alu_src2),
        .opcode (out_id_opcode),
        .id_pc (out_id_pc),
        .alu_branch_mask (out_id_alu_branch_mask),
        .branch_pc (out_id_branch_pc),
        .next_pc (out_id_next_pc),
        .rf_dest (out_id_rf_dest),
        .mem_data (out_id_mem_data),
        .id_branch_taken (out_id_branch_taken),
        .force_jump (out_id_force_jump),
        // MODULE: Forward
        .forward_op1 (out_id_forward_op1),
        .forward_op2 (out_id_forward_op2),
        .forward_depends_1 (forward_depends_1),
        .forward_depends_2 (forward_depends_2),
        .forward_stalls_1 (forward_stalls_1),
        .forward_stalls_2 (forward_stalls_2),
        .forward_result_1 (forward_result_1),
        .forward_result_2 (forward_result_2),
        // MODULE: RegisterFile
        .rf_src1 (rf_src1),
        .rf_src2 (rf_src2),
        .rf_out1_prev (rf_out1),
        .rf_out2_prev (rf_out2)
    );

    // Data Memory
    wire [`WORD] dmem_addr;
    wire [`WORD] dmem_in;
    wire dmem_write;
    wire dmem_read;
    wire [2:0] dmem_mode;
    wire [`WORD] dmem_out;

    DataMemory dmem(
        .clk (clk),
        .address (dmem_addr),
        .writeData (dmem_in),
        .memWrite (dmem_write),
        .memRead (dmem_read),
        .mode (dmem_mode),
        .reset (reset),
        .readData (dmem_out)
    );

    // Instruction Memory
    wire [`WORD] imem_addr;
    wire [`WORD] imem_out;

    InstMemory imem(
        .address (imem_addr),
        .readData (imem_out)
    );

    // STAGE: Instruction Fetch
    assign imem_addr = pc;
    
    wire [`WORD] inst = imem_out;
    
    // STAGE: Decode
    // STAGE: Execute
    
    

    wire [`WORD] alu_out;
    wire alu_zero;
    ALU alu (
            .ALUopcode (alu_op), 
            .op1 (alu_src1),
            .op2 (alu_src2),
            .out (alu_out),
            .zero (alu_zero));

    // MODULE: Branch
    wire take_branch;
    TakeBranch takeBranch(
            .opcode (opcode),
            .rt (rt),
            .alu_zero (alu_zero),
            .take_branch (take_branch)
        );
    
    wire [`WORD] new_pc = take_branch ? branch_pc : (
                            (opcode == 2 || opcode == 3) ? jump_target : (
                                (opcode == 0 && funct == 8) ? rf_out1 : next_pc));

    
    // STAGE: Memory
    assign dmem_addr = alu_out;
    assign dmem_in = rf_out2;
    assign dmem_write = is_memory_store;
    // MISSING: mem_mode
    assign dmem_read = is_memory_load;

    // STAGE: Write Back
    assign rf_write = !is_branch && !dmem_write && opcode != 2;
    assign rf_data = is_memory_load ? dmem_out : (
        opcode == 3 ? pc + 4 : alu_out);

    always @ (negedge clk) begin
        pc <= reset ? 0 : new_pc;
    end
    always @ (negedge reset) begin
        pc <= 0;
    end
endmodule
