all: multiplexer.o ALU.o shifter.o shift_left.o shift_right.o ror.o fifo_72b.o exec.o exec_tb.o
	ghdl -e -v exec_tb

%.o: %.vhdl
	ghdl -a -v $^


clean: 
	rm -f *.o exec_tb