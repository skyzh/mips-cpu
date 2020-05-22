TESTBENCH = tests
SRCS	  = src/ZeroExt.v
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

test: test_ZeroExt
	@echo "Test Complete."

gtkwave:
	gtkwave $(RESULT).vcd

scansion: simulate
	open /Applications/Scansion.app $(RESULT).vcd

clean:
	rm -rf $(TESTBENCH).vvp $(RESULT).vcd $(TESTBENCH)_log.txt $(TESTBENCH)/*_log.txt  $(TESTBENCH)/*.vvp
