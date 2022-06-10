GHDL=/opt/ghdl/bin/ghdl
BUILD=../work
GHDL_OP = -v --workdir=$(BUILD)
C_MOD_DIR = ../C_model/
CORE_DIR = ../CORE/
all : main_tb

ram.o : ram.vhdl
	${GHDL} -a ${GHDL_OP} ram.vhdl

icache.o : icache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} icache.vhdl

dcache.o : dcache.vhdl ram.o
	${GHDL} -a ${GHDL_OP} dcache.vhdl

main_tb.o : main_tb.vhdl icache.o dcache.o ram.o 
	${GHDL} -a ${GHDL_OP} main_tb.vhdl

core.o : $(shell find ../CORE -name '*.vhdl')
	make -C ../CORE analyse
	cp $(BUILD)/* .

fifo_generic.o : ../FIFO/fifo_generic.vhdl
	${GHDL} -a ${GHDL_OP} ../FIFO/fifo_generic.vhdl

${C_MOD_DIR}/lib/arm_ghdl.o: ${C_MOD_DIR}/ReadElf/lib/ElfObj.o
	make -C ${C_MOD_DIR}/src

${C_MOD_DIR}/ReadElf/lib/ElfObj.o:
	make -C ${C_MOD_DIR}/ReadElf/src

main_tb : main_tb.o ram.o icache.o dcache.o core.o ${C_MOD_DIR}/lib/arm_ghdl.o ${C_MOD_DIR}/ReadElf/lib/ElfObj.o
	${GHDL} -e ${GHDL_OP} -Wl,${C_MOD_DIR}/lib/mem.o -Wl,${C_MOD_DIR}/lib/arm_ghdl.o -Wl,${C_MOD_DIR}/ReadElf/lib/ElfObj.o main_tb

clean :
	rm -f *.o main_tb work-obj93.cf *.lst *.out $(BUILD)/*
	make -C ${C_MOD_DIR}/ReadElf/src clean
	make -C ${C_MOD_DIR}/src clean
	make -C ../CORE clean
