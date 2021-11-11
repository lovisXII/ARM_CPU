all: multiplexer.o ALU.o shifter.o fifo_72b.o EXE.o EXE_tb.o
	ghdl -e -v EXE_tb

%.o: %.vhdl
	ghdl -a -v $^

%.o: ../ALU/%.vhdl
	ghdl -a -v $^

%.o: ../Shifter/%.vhdl
	ghdl -a -v $^

%.o: ../util/%.vhdl
	ghdl -a -v $^

clean: 
	rm -f *.o exe_tb