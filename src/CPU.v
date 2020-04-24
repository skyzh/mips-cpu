`timescale 1ns / 1ps

module CPU(
    input wire clk,
    input reset);

    // PC Register
    reg [31:0] pc;

    // Data Memory
    wire [31:0] dmem_addr;
    wire [31:0] dmem_in;
    wire dmem_write;
    wire dmem_read;
    wire [2:0] dmem_mode;
    wire [31:0] dmem_out;

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
    wire [31:0] imem_addr;
    wire [31:0] imem_out;

    InstMemory imem(
        .clk (clk),
        .address (imem_addr),
        .readData (imem_out)
    );

    // STAGE: Instruction Fetch
    assign imem_addr = pc;
    
    wire [31:0] inst = imem_out;
    
    // STAGE: Decode
    wire [5:0] opcode = inst[31:26];
    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [4:0] shamt = inst[10:6];
    wire [5:0] funct = inst[5:0];
    wire [15:0] imm = inst[15:0];
    wire [31:0] imm_sign_ext;
    wire [31:0] imm_zero_ext;
    wire [31:0] shamt_zero_ext = {{27'b0}, shamt};
    SignExt signExt(.unextended (imm), .extended (imm_sign_ext));
    ZeroExt zeroExt(.unextended (imm), .extended (imm_zero_ext));
    wire is_shift;
    IsShift isShift(.funct (funct), .shift (is_shift));
    wire is_type_R = (opcode == 0);
    wire use_shamt = is_shift && is_type_R;
    wire is_branch;
    wire is_memory;

    // MODULE: Register File
    wire [4:0] rf_src1 = rs;
    wire [4:0] rf_src2 = is_type_R || is_branch || is_memory ? rt : 0;
    wire [4:0] rf_dest =  is_type_R ? rd : rt;
    wire [31:0] rf_out1;
    wire [31:0] rf_out2;
    wire [31:0] rf_data;
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

    // MODULE: Branch
    wire [31:0] imm_offset = imm_sign_ext <<< 2;
    wire [31:0] branch_pc = pc + 4 + imm_offset;
    wire [31:0] next_pc = pc + 4;
    wire override_rt;
    wire [31:0] branch_rt_val;
    BranchOp branchOp(
        .opcode (opcode), 
        .branch_op (is_branch),
        .override_rt (override_rt),
        .rt_val (branch_rt_val)
    );
    
    // MODULE: Memory
    wire [5:0] mapped_op;
    ALUOp aluOp(.opcode (opcode), .ALUopcode (mapped_op));
    wire is_memory_load;
    wire is_memory_store;
    wire [2:0] memory_mode;
    MemoryOp memoryOp(
        .opcode (opcode),
        .store (is_memory_store),
        .load (is_memory_load),
        .memory_op (is_memory),
        .memory_mode (memory_mode));
    assign dmem_mode = memory_mode;
    
    // STAGE: Execute
    wire ext_mode;
    ExtMode extMode (.opcode (opcode), .signExt (ext_mode));
    wire [5:0] alu_op = is_type_R ? funct : mapped_op;
    wire [31:0] alu_imm = ext_mode ? imm_sign_ext : imm_zero_ext;
    wire [31:0] alu_src1 = use_shamt ? shamt_zero_ext : rf_out1;
    wire [31:0] alu_src2 = is_type_R ? rf_out2 : (
                            is_branch ? 
                                (override_rt ? branch_rt_val : rf_out2) 
                            : alu_imm);
    wire [31:0] alu_out;
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
    
    wire [31:0] new_pc = take_branch ? branch_pc : next_pc;

    
    // STAGE: Memory
    assign dmem_addr = alu_out;
    assign dmem_in = rf_out2;
    assign dmem_write = is_memory_store;
    // MISSING: mem_mode
    assign dmem_read = is_memory_load;

    // STAGE: Write Back
    assign rf_write = !is_branch && !dmem_write;
    assign rf_data = is_memory_load ? dmem_out : alu_out;

    always @ (negedge clk) begin
        pc <= reset ? 0 : new_pc;
    end
    always @ (negedge reset) begin
        pc <= 0;
    end
endmodule
