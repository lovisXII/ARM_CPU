WORKDIR=../work

MBK_TARGET_LIB?=/home/timo/Documents/Cours/alliance/alliance/src/cells/src/sxlib/
GHDL?=ghdl
GHDLFLAGS?=--workdir=$(WORKDIR)
GHDLRUNFLAGS?=
COMPONENTS=core IFETCH/ifetch MEM/mem
MODS=$(COMPONENTS)

# Default target : elaborate
all : bind core.c
	cd $(WORKDIR) && clang core.c -Wl,`ghdl --list-link exec_tb`

elab: 
	ghdl -e $(GHDLFLAGS) arm_core
bind: analyse
	cd $(WORKDIR) && ghdl --bind exec_tb

# Targets to analyze libraries
analyse: $(addsuffix .vhdl,$(MODS))
		cd DEC && make analyse
		cd EXE && make analyse 
		$(GHDL) -a $(GHDLFLAGS) $^

clean:
		rm -f $(WORKDIR)/* *.vst *.vbe *.xsc