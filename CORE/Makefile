BUILD=../work
MBK_TARGET_LIB?=/home/timo/Documents/Cours/alliance/alliance/src/cells/src/sxlib/
GHDL?=/opt/ghdl/bin/ghdl
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
	cd $(BUILD) && clang ../CORE/core.c -Wl,`$(GHDL) --list-link $(TB)`


$(BUILD)/e~$(TB).o: $(OBJ)
	cd $(BUILD) && $(GHDL) --bind $(TB)
	
$(BUILD)/core_tb.o: $(SOURCES)
	$(GHDL) -a $(GHDLFLAGS) $^

clean:
		rm -f *.vst *.vbe *.xsc *.lst *.o

synth: chip.vst
	cp *.vst $(BUILD)/../synth/.

ifetch.vhdl: IFETCH/ifetch.vhdl
	cp IFETCH/ifetch.vhdl ifetch.vhdl

ifetch.vst : ifetch.vhdl mem.vst ifetch.vst decod.vst fifo_127b.vst
		vasy -I vhdl -V -o -a -p	 ifetch.vhdl ifetch

ifetch_model_o.vbe : ifetch.vst
		boom -V -O ifetch_model ifetch_model_o

ifetch_model.vst : ifetch_model_o.vbe
		boog ifetch_model_o ifetch_model
		rm ifetch.vhdl

mem.vhdl: MEM/mem.vhdl
	cp MEM/mem.vhdl mem.vhdl

mem.vbe: mem.vhdl
		vasy -I vhdl -V -o -p -a mem.vhdl mem

mem_o.vbe : mem.vbe
		boom -V mem mem_o

mem.vst : mem_o.vbe
		boog mem_o mem
		rm mem.vhdl

fifo_127b.vhdl: util/fifo_127b.vhdl
	cp util/fifo_127b.vhdl fifo_127b.vhdl

fifo_127b.vbe: fifo_127b.vhdl
		vasy -I vhdl -V -o -p -a fifo_127b.vhdl fifo_127b

fifo_127b_o.vbe : fifo_127b.vbe
		boom -V fifo_127b fifo_127b_o

fifo_127b.vst : fifo_127b_o.vbe
		boog fifo_127b_o fifo_127b
		rm fifo_127b.vhdl

decod.vst: $(BUILD)/../synth/decod.vst
	cp $(BUILD)/../synth/*.vst .

core.vst : core.vhdl mem.vst ifetch_model.vst decod.vst fifo_127b.vst 
		vasy -I vhdl -V -o -a -p	 core.vhdl core

core_model_o.vbe : core.vst
		boom -V -O core_model core_model_o

core_model.vst : core_model_o.vbe
		boog core_model_o core_model

chip.vhdl: ../CHIP/chip.vhdl
	cp ../CHIP/chip.vhdl .
 
chip.vst : chip.vhdl core.vst core_model.vst
		vasy -I vhdl -V -o -a	 chip.vhdl chip