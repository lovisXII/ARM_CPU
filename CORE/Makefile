BUILD=../work
MBK_TARGET_LIB?=/home/timo/Documents/Cours/alliance/alliance/src/cells/src/sxlib/
GHDL?=ghdl
GHDLFLAGS?=--workdir=$(BUILD)
GHDLRUNFLAGS?=
COMPONENTS=core IFETCH/ifetch DEC/decod EXE/shift_left EXE/shift_right EXE/exec EXE/ror EXE/shifter EXE/alu MEM/mem REG/reg REG/one_hot util/fifo_127b util/fifo_32b util/fifo_72b
TB=core_tb
MODS=$(TB) $(COMPONENTS) 
SOURCES=$(addsuffix .vhdl, $(MODS))
OBJ=$(addsuffix .o, $(addprefix $(BUILD)/, $(notdir $(MODS))))


all : $(BUILD)/a.out

analyse: $(OBJ)

$(BUILD)/a.out: $(BUILD)/e~$(TB).o core.c
	cd $(BUILD) && clang ../CORE/core.c -Wl,`ghdl --list-link $(TB)`


$(BUILD)/e~$(TB).o: $(OBJ)
	cd $(BUILD) && ghdl --bind $(TB)
	
$(BUILD)/core_tb.o: $(SOURCES)
	$(GHDL) -a $(GHDLFLAGS) $^

clean:
		rm -f $(BUILD)/* *.vst *.vbe *.xsc *.lst *.o