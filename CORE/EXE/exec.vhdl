library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXEC is
	port(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;
			exe_pop			: out Std_logic;

	-- Decode interface operands
			dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: in Std_Logic; -- Rd destination write back
			dec_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R
			dec_pre_index 	: in Std_logic; -- selectionne le résultat de l'ALU 

			dec_mem_lw		: in Std_Logic;
			dec_mem_lb		: in Std_Logic;
			dec_mem_sw		: in Std_Logic;
			dec_mem_sb		: in Std_Logic;

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;
			dec_shift_lsr	: in Std_Logic;
			dec_shift_asr	: in Std_Logic;
			dec_shift_ror	: in Std_Logic;
			dec_shift_rrx	: in Std_Logic;
			dec_shift_val	: in Std_Logic_Vector(4 downto 0);
			dec_cy			: in Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: in Std_Logic; -- say if we took the opposite of op1
			dec_comp_op2	: in Std_Logic;
			dec_alu_cy 		: in Std_Logic;

	-- Alu command
			dec_alu_cmd		: in Std_Logic_Vector(1 downto 0);

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0);

			exe_c				: out Std_Logic;
			exe_v				: out Std_Logic;
			exe_n				: out Std_Logic;
			exe_z				: out Std_Logic;

			exe_dest			: out Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: out Std_Logic; -- Rd destination write back
			exe_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Mem interface
			exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register
			exe_mem_data	: out Std_Logic_Vector(31 downto 0);
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0);

			exe_mem_lw		: out Std_Logic;
			exe_mem_lb		: out Std_Logic;
			exe_mem_sw		: out Std_Logic;
			exe_mem_sb		: out Std_Logic;

			exe2mem_empty	: out Std_logic;
			mem_pop			: in Std_logic;

	-- global interface
			ck					: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in Std_Logic;
			vss				: in Std_Logic);
end EXEC;

----------------------------------------------------------------------

architecture Behavior OF EXEC is

signal res_shift : std_logic_vector(31 downto 0);
signal not_res_shift : std_logic_vector(31 downto 0);

signal not_dec_op1 : std_logic_vector(31 downto 0);
signal alu_in_op2 : std_logic_vector(31 downto 0);
signal alu_in_op1 : std_logic_vector(31 downto 0);
signal cy_shift_out : std_logic;
signal cy_alu_out : std_logic;
signal res_alu : std_logic_vector(31 downto 0);
signal exe2mem_full : std_logic;
signal mem_adr : std_logic_vector(31 downto 0);
signal exe_push : std_logic;


component alu
    port ( op1			: in Std_Logic_Vector(31 downto 0);
           op2			: in Std_Logic_Vector(31 downto 0);
           cin			: in Std_Logic;

           cmd			: in Std_Logic_Vector(1 downto 0);

           res			: out Std_Logic_Vector(31 downto 0);
           cout		: out Std_Logic;
           z			: out Std_Logic;
           n			: out Std_Logic;
           v			: out Std_Logic;
			  
			  vdd			: in Std_Logic;
			  vss			: in Std_Logic);
end component;

component Shifter
	PORT(
    shift_lsl : IN  Std_Logic;-- permet de dire quel type de shift on effectue
    shift_lsr : IN  Std_Logic;
    shift_asr : IN  Std_Logic;
    shift_ror : IN  Std_Logic;
    shift_rrx : IN  Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic;
    -- global interface
    vdd       : IN  Std_Logic;
    vss       : IN  Std_Logic );
END component;

component fifo_72b
	port(
		din		: in std_logic_vector(71 downto 0);
		dout		: out std_logic_vector(71 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in Std_Logic;
		vss		: in Std_Logic
	);
end component;

	begin
--  Signal assignment
exe_pop 	<= NOT(dec2exe_empty) AND NOT(exe2mem_full);
exe_push 	<= NOT(dec2exe_empty) AND NOT(exe2mem_full);
exe_res 	<= res_alu; 
exe_c 		<= (dec_alu_cy AND cy_alu_out) OR (NOT(dec_alu_cy) AND cy_shift_out);

alu_in_op2 	<= res_shift 	when dec_comp_op2 	= '1' else not(res_shift);
alu_in_op1 	<= dec_op1 		when dec_comp_op1 	= '1' else not(dec_op1);
mem_adr 	<= dec_op1 		when dec_pre_index 	= '1' else res_alu;

exe_dest 	<= dec_exe_dest;
exe_wb 		<= dec_exe_wb;
exe_flag_wb <= dec_flag_wb; 
--  Component instantiation.

  	shifter_inst : shifter port map(
  					shift_lsl => dec_shift_lsl,
  					shift_lsr => dec_shift_lsr,
  					shift_asr => dec_shift_asr,
  					shift_ror => dec_shift_ror,
  					shift_rrx => dec_shift_rrx,
  					shift_val => dec_shift_val,
  					din => dec_op2,
				    cin => dec_cy,
			        dout => res_shift,
  					cout => cy_shift_out,
  					vdd => vdd,
  					vss => vss) ;


	alu_inst : alu port map(
					op1 => alu_in_op1, 
					op2 => alu_in_op2, 
					cin => dec_cy, 
					cmd => dec_alu_cmd, 
					res => res_alu, 
					cout => cy_alu_out, 
					z => exe_z, 
					n => exe_n, 
					v => exe_v, 
					vdd => vdd, 
					vss => vss) ;

	exec2mem : fifo_72b
	port map (	din(71)	 => dec_mem_lw,
					din(70)	 => dec_mem_lb,
					din(69)	 => dec_mem_sw,
					din(68)	 => dec_mem_sb,

					din(67 downto 64) => dec_mem_dest,
					din(63 downto 32) => dec_mem_data,
					din(31 downto 0)	 => mem_adr,

					dout(71)	 => exe_mem_lw,
					dout(70)	 => exe_mem_lb,
					dout(69)	 => exe_mem_sw,
					dout(68)	 => exe_mem_sb,

					dout(67 downto 64) => exe_mem_dest,
					dout(63 downto 32) => exe_mem_data,
					dout(31 downto 0)	 => exe_mem_adr,

					push		 => exe_push,
					pop		 => mem_pop,

					empty		 => exe2mem_empty,
					full		 => exe2mem_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);


end Behavior;
