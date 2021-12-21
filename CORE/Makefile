WORKDIR=../work
MBK_TARGET_LIB?=/home/timo/Documents/Cours/alliance/alliance/src/cells/src/sxlib/
GHDL?=ghdl
GHDLFLAGS?=--workdir=$(WORKDIR)
GHDLRUNFLAGS?=
COMPONENTS=core IFETCH/ifetch MEM/mem
TB=core_tb
MODS=$(COMPONENTS) $(TB)


# Default target : elaborate
all : bind core.c
	cd $(WORKDIR) && clang ../CORE/core.c -Wl,`ghdl --list-link $(TB)`

elab: analyse
	$(GHDL) -c $(GHDLFLAGS) -e $(TB)


bind: analyse
	cd $(WORKDIR) && ghdl --bind $(TB)

# Targets to analyze libraries
analyse: $(addsuffix .vhdl,$(MODS))
		cd DEC && make analyse
		cd EXE && make analyse 
		$(GHDL) -a $(GHDLFLAGS) $^

clean:
		rm -f $(WORKDIR)/* *.vst *.vbe *.xsc *.lst *.o