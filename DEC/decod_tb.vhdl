library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity decod_tb is
end entity ;


architecture behavior of decod_tb is
	-- Exec  operands
signal dec_op1			:  Std_Logic_Vector(31 downto 0); -- first alu input
signal dec_op2			:  Std_Logic_Vector(31 downto 0); -- shifter input
signal dec_exe_dest		:  Std_Logic_Vector(3 downto 0); -- Rd destination
signal dec_exe_wb		:  Std_Logic; -- Rd destination write back
signal dec_flag_wb		:  Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
signal dec_mem_data		:  Std_Logic_Vector(31 downto 0); -- data to MEM
signal dec_mem_dest		:  Std_Logic_Vector(3 downto 0); -- @ of MEM
signal dec_pre_index 	:  Std_logic; -- say if we do pre index or no []!

signal dec_mem_lw		:  Std_Logic; -- type of memory access
signal dec_mem_lb		:  Std_Logic;
signal dec_mem_sw		:  Std_Logic;
signal dec_mem_sb		:  Std_Logic;

	-- Shifter command
signal dec_shift_lsl	:  Std_Logic; --meme signaux que dans exe
signal dec_shift_lsr	:  Std_Logic;
signal dec_shift_asr	:  Std_Logic;
signal dec_shift_ror	:  Std_Logic;
signal dec_shift_rrx	:  Std_Logic;
signal dec_shift_val	:  Std_Logic_Vector(4 downto 0);
signal dec_cy			:  Std_Logic;

	-- Alu operand selection
signal dec_comp_op1	 	:  Std_Logic;
signal dec_comp_op2		:  Std_Logic;
signal dec_alu_cy 		:  Std_Logic;

	-- Exec Synchro
signal dec2exe_empty	:  Std_Logic; --fifo en entree dec/exe
signal exe_pop			:  Std_logic;

	-- Alu command
signal dec_alu_add		:  Std_Logic;
signal dec_alu_and		:  Std_Logic;
signal dec_alu_or		:  Std_Logic;
signal dec_alu_xor		:  Std_Logic;

	-- Exe Write Back to reg
signal exe_res			:   Std_Logic_Vector(31 downto 0);

signal exe_c			:   Std_Logic;
signal exe_v			:   Std_Logic;
signal exe_n			:   Std_Logic;
signal exe_z			:   Std_Logic;

signal exe_dest			:   Std_Logic_Vector(3 downto 0); -- Rd destination
signal exe_wb           :   Std_Logic; -- Rd destination write back
signal exe_flag_wb		:   Std_Logic; -- CSPR modifiy

	-- Ifetch  terface
signal dec_pc 			:  	Std_Logic_Vector(31 downto 0) ; -- pc
signal if_ir 			:   Std_Logic_Vector(31 downto 0) ; -- 32 bits to decode

	-- Ifetch synchro : fifo dec2if et if2dec
signal dec2if_empty		:  	Std_Logic; -- si la fifo qui recup pc est vide
signal if_pop 			:   Std_Logic; -- pop de la fifo dec2if

signal if2dec_empty		:   Std_Logic; -- si la fifo qui envoie l'inst est vide
signal dec_pop 			:  	Std_Logic; -- 

	-- Mem Write back to reg
signal mem_res 			:   Std_Logic_Vector(31 downto 0);
signal mem_dest			:   Std_Logic_Vector(3 downto 0);
signal mem_wb 			:   Std_Logic;
signal 
	-- global  terface
signal ck		 		:   Std_Logic;
signal reset_n 			:   Std_Logic;
signal vdd 				:   bit;
signal vss 				:   bit;


component decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0); -- @ of MEM
			dec_pre_index 	: out Std_logic; -- say if we do pre index or no []!

			dec_mem_lw		: out Std_Logic; -- type of memory access
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic; --meme signaux que dans exe
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic; --fifo en entree dec/exe
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_add		: out Std_Logic;
			dec_alu_and		: out Std_Logic;
			dec_alu_or		: out Std_Logic;
			dec_alu_xor		: out Std_Logic;

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ; -- pc
			if_ir			: in Std_Logic_Vector(31 downto 0) ; -- 32 bits to decode

	-- Ifetch synchro : fifo dec2if et if2dec
			dec2if_empty	: out Std_Logic; -- si la fifo qui recup pc est vide
			if_pop			: in Std_Logic; -- pop de la fifo dec2if

			if2dec_empty	: in Std_Logic; -- si la fifo qui envoie l'inst est vide
			dec_pop			: out Std_Logic; -- 

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck				: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end component ;

begin 

decod0 : decod port map
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0); -- @ of MEM
			dec_pre_index 	: out Std_logic; -- say if we do pre index or no []!

			dec_mem_lw		: out Std_Logic; -- type of memory access
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic; --meme signaux que dans exe
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic; --fifo en entree dec/exe
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_add		: out Std_Logic;
			dec_alu_and		: out Std_Logic;
			dec_alu_or		: out Std_Logic;
			dec_alu_xor		: out Std_Logic;

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ; -- pc
			if_ir			: in Std_Logic_Vector(31 downto 0) ; -- 32 bits to decode

	-- Ifetch synchro : fifo dec2if et if2dec
			dec2if_empty	: out Std_Logic; -- si la fifo qui recup pc est vide
			if_pop			: in Std_Logic; -- pop de la fifo dec2if

			if2dec_empty	: in Std_Logic; -- si la fifo qui envoie l'inst est vide
			dec_pop			: out Std_Logic; -- 

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck				: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit
);