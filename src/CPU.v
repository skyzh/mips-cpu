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

    // --- Execute STAGE INTERMEDIATES ---
    wire [`WORD] out_ex_alu_out;
    wire [`OP] out_ex_opcode;
    wire [`WORD] out_ex_pc;
    wire [`REG] out_ex_rf_dest;
    wire [`WORD] out_ex_mem_data;

    // Forwarding
    Forward forward1(
        .ex_opcode (out_ex_opcode),
        .ex_dest (out_ex_rf_dest),
        .ex_val (out_ex_alu_out),
        .mem_opcode (mem_opcode),
        .mem_dest (mem_dest),
        .mem_alu_val (mem_alu_val),
        .mem_val (mem_val),
        .wb_opcode (wb_opcode),
        .wb_dest (wb_dest),
        .wb_val (wb_val),
        .src (out_id_forward_op1),
        .data (forward_result_1),
        .depends (forward_depends_1),
        .stall (forward_stalls_1)
    );

    Forward forward2(
        .ex_opcode (out_ex_opcode),
        .ex_dest (out_ex_rf_dest),
        .ex_val (out_ex_alu_out),
        .mem_opcode (mem_opcode),
        .mem_dest (mem_dest),
        .mem_alu_val (mem_alu_val),
        .mem_val (mem_val),
        .wb_opcode (wb_opcode),
        .wb_dest (wb_dest),
        .wb_val (wb_val),
        .src (out_id_forward_op2),
        .data (forward_result_2),
        .depends (forward_depends_2),
        .stall (forward_stalls_2)
    );

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
        .stall (out_id_stall),
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

    // --- CLOCK ---
    always @ (negedge clk) begin
        if (!correct_branch_prediction || out_id_stall) begin
            // Bubble
            stage_id_alu_op <= 0;
            stage_id_alu_src1 <= 0;
            stage_id_alu_src2 <= 0;
            stage_id_opcode <= 0;
            stage_id_pc <= 0;
            stage_id_alu_branch_mask <= 0;
            stage_id_branch_pc <= 0;
            stage_id_next_pc <= 0;
            stage_id_rf_dest <= 0;
            stage_id_mem_data <= 0;
            stage_id_branch_taken <= 0;
            stage_id_force_jump <= 0;
        end else begin
            stage_id_alu_op <= out_id_alu_op;
            stage_id_alu_src1 <= out_id_alu_src1;
            stage_id_alu_src2 <= out_id_alu_src2;
            stage_id_opcode <= out_id_opcode;
            stage_id_pc <= out_id_pc;
            stage_id_alu_branch_mask <= out_id_alu_branch_mask;
            stage_id_branch_pc <= out_id_branch_pc;
            stage_id_next_pc <= out_id_next_pc;
            stage_id_rf_dest <= out_id_rf_dest;
            stage_id_mem_data <= out_id_mem_data;
            stage_id_branch_taken <= out_id_branch_taken;
            stage_id_force_jump <= out_id_force_jump;
        end
    end

    // --- STAGE ---
    //   Execute
    // --- STAGE REGS ---
    reg [`WORD] stage_ex_alu_out;
    reg [`OP] stage_ex_opcode;
    reg [`WORD] stage_ex_pc;
    reg [`REG] stage_ex_rf_dest;
    reg [`WORD] stage_ex_mem_data;

    Execute execute(
        .alu_op (stage_id_opcode),
        .alu_src1 (stage_id_alu_src1),
        .alu_src2 (stage_id_alu_src2),
        .id_opcode (stage_id_opcode),
        .id_pc (stage_id_pc),
        .alu_branch_mask (stage_id_alu_branch_mask),
        .branch_pc (stage_id_branch_pc),
        .next_pc (stage_id_next_pc),
        .id_rf_dest (stage_id_rf_dest),
        .id_mem_data (stage_id_mem_data),
        .id_branch_taken (stage_id_branch_taken),
        .force_jump (stage_id_force_jump),
        .alu_out (out_ex_alu_out),
        .ex_opcode (out_ex_opcode),
        .ex_pc (out_ex_pc),
        .ex_rf_dest (out_ex_rf_dest),
        .ex_mem_data (out_ex_mem_data),
        .correct_branch_prediction (correct_branch_prediction),
        .branch_jump_target (branch_jump_target)
    );

    // --- CLOCK ---
    always @ (negedge clk) begin
        stage_ex_alu_out <= out_ex_alu_out;
        stage_ex_opcode <= out_ex_opcode;
        stage_ex_pc <= out_ex_pc;
        stage_ex_rf_dest <= out_ex_rf_dest;
        stage_ex_mem_data <= out_ex_mem_data;
    end

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
    
    always @ (negedge reset) begin
        pc <= 0;
        stage_if_inst <= 0;
        stage_if_pc <= 0;
        stage_if_branch_taken <= 0;
        stage_id_alu_op <= 0;
        stage_id_alu_src1 <= 0;
        stage_id_alu_src2 <= 0;
        stage_id_opcode <= 0;
        stage_id_pc <= 0;
        stage_id_alu_branch_mask <= 0;
        stage_id_branch_pc <= 0;
        stage_id_next_pc <= 0;
        stage_id_rf_dest <= 0;
        stage_id_mem_data <= 0;
        stage_id_branch_taken <= 0;
        stage_id_force_jump <= 0;
        stage_ex_alu_out <= 0;
        stage_ex_opcode <= 0;
        stage_ex_pc <= 0;
        stage_ex_rf_dest <= 0;
        stage_ex_mem_data <= 0;
    end
endmodule
