TESTBENCH = tests
SRCS	  = src/CPU.v src/Module/SignExt.v src/Module/ZeroExt.v src/Module/ALUOp.v \
			src/Module/ExtMode.v src/Module/IsShift.v src/Module/ALU.v \
			src/DataMemory.v src/InstMemory.v src/RegisterFile.v \
			src/Module/MemoryOp.v src/Module/BranchOp.v
RESULT    = result
V_FLAG    = -g2005-sv

#------------------------------------------------------------------------------
# You should't be changing what is below
#------------------------------------------------------------------------------
all: simulate

lint:
	verilator --lint-only $(SRCS)

simulate:
	iverilog -o $(TESTBENCH).vvp $(SRCS) $(TESTBENCH).v
	vvp $(TESTBENCH).vvp > $(TESTBENCH)_log.txt

test_%:
	@echo "test: $*"
	iverilog -o $(TESTBENCH)/$*_tb.vvp $(SRCS) $(TESTBENCH)/$*_tb.v
	vvp $(TESTBENCH)/$*_tb.vvp > $(TESTBENCH)/$*_log.txt
	@grep "ALEX_TEST_SUCCESS" $(TESTBENCH)/$*_log.txt

test: test_SignExt test_ZeroExt test_ALU test_ALUOp test_DataMemory test_InstMemory test_IsShift test_RegisterFile test_IsShift test_ExtMode
	@echo "Test Complete."

gtkwave:
	gtkwave $(RESULT).vcd

scansion: simulate
	open /Applications/Scansion.app $(RESULT).vcd

clean:
	rm -rf $(TESTBENCH)/*.vvp $(RESULT).vcd $(TESTBENCH)/*_log.txt
