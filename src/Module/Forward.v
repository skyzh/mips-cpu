`timescale 1ns / 1ps

// This module forwards information
module Forward(
    input [`OP] ex_opcode,
    input [`REG] ex_dest,
    input [`WORD] ex_val,
    input [`OP] mem_opcode,
    input [`REG] mem_dest,
    input [`WORD] mem_alu_val,
    input [`WORD] mem_val,
    input [`OP] wb_opcode,
    input [`REG] wb_dest,
    input [`WORD] wb_val,
    input [`REG] src,
    output reg [`WORD] data,
    output reg depends,
    output reg stall
);
    wire ex_is_arithmetic_op;
    wire ex_is_link_op = ex_opcode == 3;
    wire ex_is_memory_load;
    wire mem_is_arithmetic_op;
    wire mem_is_link_op = mem_opcode == 3;
    wire mem_is_memory_load;
    wire wb_is_arithmetic_op;
    wire wb_is_link_op = wb_opcode == 3;
    wire wb_is_memory_load;

    /* verilator lint_off PINMISSING */
    ALUOp ex_aluop(.opcode (ex_opcode), .arithmetic_op (ex_is_arithmetic_op));
    ALUOp mem_aluop(.opcode (mem_opcode), .arithmetic_op (mem_is_arithmetic_op));
    ALUOp wb_aluop(.opcode (wb_opcode), .arithmetic_op (wb_is_arithmetic_op));
    
    MemoryOp ex_memop(.opcode (ex_opcode), .load (ex_is_memory_load));
    MemoryOp mem_memop(.opcode (mem_opcode), .load (mem_is_memory_load));
    MemoryOp wb_memop(.opcode (wb_opcode), .load (wb_is_memory_load));
    /* verilator lint_on PINMISSING */
    
    always @(*) begin
        data = 0;
        depends = 0;
        stall = 0;
        if (src == 0) begin
            data = 0;
            depends = 0;
            stall = 0;
        end else if (ex_dest == src && (ex_is_arithmetic_op || ex_is_link_op)) begin
            data = ex_val;
            stall = 0;
            depends = 1;
        end else if (ex_dest == src && ex_is_memory_load) begin
            data = 0;
            stall = 1;
            depends = 1;
        end else if (mem_dest == src && (mem_is_arithmetic_op || mem_is_link_op)) begin
            data = mem_alu_val;
            stall = 0;
            depends = 1;
        end else if (mem_dest == src && mem_is_memory_load) begin 
            data = mem_val;
            stall = 0;
            depends = 1;
        end else if (wb_dest == src && (wb_is_arithmetic_op || wb_is_memory_load || wb_is_link_op)) begin
            data = wb_val;
            stall = 0;
            depends = 1;
        end
    end
endmodule
