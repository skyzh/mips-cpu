`timescale 1ns / 1ps

module ALUOp(
    input [5:0] opcode,
    output reg [5:0] ALUopcode);

    always @ (opcode) begin
        case (opcode)
            // branch instructions
            // beq, bne = sub
            6'h04: ALUopcode = 6'h22;
            6'h05: ALUopcode = 6'h22;
            // bgez, bltz = slt
            6'h01: ALUopcode = 6'h2A;
            // bgtz, blez = slt
            6'h06: ALUopcode = 6'h2A;
            6'h07: ALUopcode = 6'h2A;
            // lb, lw, sb, sw = add
            6'h20: ALUopcode = 6'h20;
            6'h23: ALUopcode = 6'h20;
            6'h28: ALUopcode = 6'h20;
            6'h2B: ALUopcode = 6'h20;
            // other instructions stay the same
            default: ALUopcode = opcode;
        endcase
    end
endmodule
