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
    wire ex_is_link_op;
    wire ex_is_memory_load;
    wire mem_is_arithmetic_op;
    wire mem_is_link_op;
    wire mem_is_memory_load;
    wire wb_is_arithmetic_op;
    wire wb_is_link_op;
    wire wb_is_memory_load;
    
    always @(*) begin
        data = 0;
        depends = 0;
        stall = 0;
        if (src == 0) begin
            data = 0;
            depends = 0;
            stall = 0;
        end else if (ex_dest == src) begin
            if (ex_is_arithmetic_op || ex_is_link_op) begin
                data = ex_val;
                stall = 0;
                depends = 1;
            end
            if (ex_is_memory_load) begin
                data = 0;
                stall = 1;
                depends = 1;
            end
        end else if (mem_dest == src) begin
            if (mem_is_arithmetic_op || mem_is_link_op) data = mem_alu_val;
            if (mem_is_memory_load) data = mem_val;
            if (mem_is_arithmetic_op || mem_is_memory_load || mem_is_link_op) begin
                stall = 0;
                depends = 1;
            end
        end else if (wb_dest == src) begin
            if (wb_is_arithmetic_op || wb_is_memory_load || wb_is_link_op)
                data = wb_val;
                stall = 0;
                depends = 1;
            end
        end
            
    end
endmodule
