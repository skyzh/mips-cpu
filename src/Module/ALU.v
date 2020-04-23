`timescale 1ns / 1ps

// ALU module
module ALU(
    input [5:0] ALUopcode,
    input [31:0] op1,
    input [31:0] op2,
    output reg [31:0] out,
    output reg zero);

    always @ (ALUopcode or op1 or op2) begin
        case (ALUopcode)
            // add
            6'h20: out = op1 + op2;
            // addu
            6'h21: out = op1 + op2;
            // addi
            6'h08: out = op1 + op2;
            // addiu
            6'h09: out = op1 + op2;
            // sub
            6'h22: out = op1 - op2;
            // subu
            6'h23: out = op1 - op2;
            // and
            6'h24: out = op1 & op2;
            // andi
            6'h0C: out = op1 & op2;
            // nor
            6'h27: out = ~(op1 | op2);
            // or
            6'h25: out = op1 | op2;
            // or
            6'h0D: out = op1 | op2;
            // xor
            6'h26: out = op1 ^ op2;
            // xori
            6'h0E: out = op1 ^ op2;
            // lui
            6'h0F: out = {op2[15:0], op1[15:0]};
            // sll
            6'h00: out = op2 <<< op1;
            // sllv
            6'h04: out = op2 <<< op1;
            // sra
            6'h03: out = $signed(op2) >>> op1;
            // srav
            6'h07: out = $signed(op2) >>> op1;
            // srl
            6'h02: out = op2 >>> op1;
            // srlv
            6'h06: out = op2 >>> op1;
            // slt
            6'h2A: if ($signed(op1) < $signed(op2)) out = 1; else out = 0;
            // slti
            6'h0A: if ($signed(op1) < $signed(op2)) out = 1; else out = 0;
            // sltu
            6'h2B: if (op1 < op2) out = 1; else out = 0;
            // sltiu
            6'h0B: if (op1 < op2) out = 1; else out = 0;
            default: out = 0;
        endcase

        if (out == 0) zero = 1; else zero = 0;
    end
endmodule
