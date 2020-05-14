# MIPS-CPU

A MIPS CPU in Verilog.

Making a MIPS CPU is a non-trivial task. But with the help of mips-simulator,
my previous project on describing circuit logic in functional programming language,
this project can be done easily by directly translating Haskell into Verilog.


All CPU and CPU simulators I've made are listed below.

|                                                                     | Technique                                      | Implementation |
|---------------------------------------------------------------------|------------------------------------------------|----------------|
| [RISC-V v1](https://github.com/skyzh/RISCV-Simulator/tree/pipeline) | 5-stage pipeline  simulator                 | C++            |
| [RISC-V v2](https://github.com/skyzh/RISCV-Simulator)               | dynamic scheduling simulator <br> Tomasulo + Speculation | C++            |
| [MIPS](https://github.com/skyzh/mips-simulator)                     | 5-stage pipeline  simulator                             | Haskell        |
| [MIPS](https://github.com/skyzh/mips-cpu)                           | 5-stage pipeline CPU         | Verilog        |


Variable naming and wire naming are nearly identical in Haskell version and Verilog version.
Here I compare some code snippets between Verilog and Haskell.

## Circuit Logic in Haskell and Verilog

**signals and circuit logic**

```haskell
pc'' = 
    if take_branch then branch_pc 
    else next_pc
```

```verilog
assign ex_pc = take_branch ? 
    branch_pc : next_pc;
```

**stage input**

```haskell
-- use stage reg data type

data ID_EX_Reg = ID_EX_Reg {
    id_alu_op :: Word32,
    id_alu_src1 :: Word32,
    id_alu_src2 :: Word32,
    id_opcode :: Word32,
    id_pc :: Word32,
    ...
    }

stageExecute :: ID_EX_Reg -> (EX_MEM_Reg, (Bool, Word32))
```

```verilog
// feed signals directly

module Execute(
    input [`OP] alu_op,
    input [`WORD] alu_src1,
    input [`WORD] alu_src2,
    input [`OP] id_opcode,
    input [`WORD] id_pc,
    ...
```

**cycle on clock**

```haskell
-- return data from this cycle

cpu_cycle :: Registers -> Registers

next_regs = Registers   new_rf
                        new_hi
                        new_lo
                        imem'
                        new_dmem
                        new_pc
                        next_if_id_reg
                        next_id_ex_reg
                        next_ex_mem_reg
                        next_mem_wb_reg
```

```verilog
// events

always @ (negedge clk) begin
    if (!out_id_stall) begin
        stage_if_inst <= out_if_inst;
        stage_if_pc <= out_if_pc;
        stage_if_branch_taken <= 0;
        pc <= out_if_next_pc;
    end
end
```

**stage with multiple outputs**

```haskell
-- use tuple

out_id_stall   = snd stage_id_out
stage_id_regs  = fst stage_id_out
```

```verilog
// use signals directly

InstDecode instDecode (
    ... (stage regs)
    .stall (out_id_stall),
    ... (other modules)
);
```

**decode helper**

```haskell
-- defined as functions

extMode :: Word32 -> Bool
extMode 0x0C = False
extMode 0x0D = False
extMode 0x0E = False
extMode 0x24 = False
extMode 0x25 = False
extMode _    = True
```

```verilog
module ExtMode(
    input [5:0] opcode,
    output reg signExt);

    always @ (opcode) begin
        case (opcode)
            6'h0c: signExt = 0;
            6'h0d: signExt = 0;
            6'h0e: signExt = 0;
            6'h24: signExt = 0;
            6'h25: signExt = 0;
            default: signExt = 1;
        endcase
    end
endmodule
```

## Relationship

| Verilog      | Haskell                                                                   |
|--------------|---------------------------------------------------------------------------|
| ALU          | aluRead in ALU                                                            |
| ALUOp        | mapALUOp + isArithmeticOp in ALU                                          |
| BranchOp     | isBranchOp + branchRtVal = overrideRt in Branch                           |
| BranchOut    | branchOut in Branch                                                       |
| ExtMode      | extMode in ALU                                                            |
| Forward      | Forward                                                                   |
| IsShift      | isShift in ALU                                                            |
| MemoryOp     | memoryMode + memoryLoad + memoryStore + isMemoryOp + memoryMode in Memory |
| SignExt      | signExt in ALU                                                            |
| ZeroExt      | zeroExt in ALU                                                            |
| Execute      | StageExecute                                                              |
| InstDecode   | InstDecode                                                                |
| InstFetch    | InstFetch                                                                 |
| Memory       | StageMem                                                                  |
| WriteBack    | embedded in CPU                                                           |
| CPU          | CPU                                                                       |
| RegisterFile | RegisterFile                                                              |
| DataMemory   | dmem in Registers                                                         |
| InstMemory   | imem in Registers                                                         |
| signals in CPU   | StageReg                                                                  |

All signals in stage registers and in stage modules are exactly the same, except that:

* Stage with multiple outputs has multiple output signals in Verilog.
* In Verilog, forward module logic is located in CPU.
* In Verilog, memory is located, and operates in CPU. Memory stage sends signals out of the module.
* In Verilog, write back is a standalone stage.
