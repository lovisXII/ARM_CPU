LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;

--revoir les gestions des @ decriture et des opérandes 
entity test_decode_exe is
	port(
		dec_pc 	: out 	std_logic_vector(31 downto 0);
		if_ir 		: in 	std_logic_vector(31 downto 0);
		exe_result  : out 	std_logic_vector(31 downto 0);
		exe_c_result	: out 	Std_Logic ;
		exe_v_result	: out 	Std_Logic ;
		exe_n_result	: out 	Std_Logic ;
		exe_z_result 	: out 	Std_Logic ;
		reset_n : in    Std_Logic ;
		ck 		: in 	std_logic ;
		vss 	: in 	bit ;
		vdd 	: in 	bit 
		); 
	end entity ;

architecture behavior of test_decode_exe is

Component Decod
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
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
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;
			dec2exe_push 	: out std_logic ;

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
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir			: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck				: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Component;


Component fifo_129b
	PORT(
		din				: in  std_logic_vector(128 downto 0);
		dout			: out std_logic_vector(128 downto 0);

		-- commands
		push			: in std_logic;
		pop				: in std_logic;

		-- flags
		full			: out std_logic;
		empty			: out std_logic;

		reset_n			: in std_logic;
		ck				: in std_logic;
		vdd				: in bit;
		vss				: in bit);
end component ;


Component EXec
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
			dec_pre_index 	: in Std_logic;

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
			dec_comp_op1	: in Std_Logic;
			dec_comp_op2	: in Std_Logic;
			dec_alu_cy 		: in Std_Logic;

	-- Alu command
			dec_alu_cmd		: in Std_Logic_Vector(1 downto 0);

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0);

			exe_c			: out Std_Logic;
			exe_v			: out Std_Logic;
			exe_n			: out Std_Logic;
			exe_z			: out Std_Logic;

			exe_dest		: out Std_Logic_Vector(3 downto 0); -- Rd destination
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
			ck				: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in bit;
			vss				: in bit);
end Component;

signal dec_op1 : Std_Logic_Vector(31 downto 0); 
signal dec_op2 : Std_Logic_Vector(31 downto 0); 
signal dec_exe_dest : Std_Logic_Vector(3 downto 0);  
signal dec_exe_wb : Std_Logic; 
signal dec_flag_wb : Std_Logic; 

	-- Decod to mem via exec
signal dec_mem_data : Std_Logic_Vector(31 downto 0); 
signal dec_mem_dest : Std_Logic_Vector(3 downto 0); 
signal dec_pre_index : Std_logic; 
signal dec_mem_lw : Std_Logic; 
signal dec_mem_lb : Std_Logic; 
signal dec_mem_sw : Std_Logic; 
signal dec_mem_sb : Std_Logic; 

	-- Shifter command
signal dec_shift_lsl : Std_Logic; 
signal dec_shift_lsr : Std_Logic; 
signal dec_shift_asr : Std_Logic; 
signal dec_shift_ror : Std_Logic; 
signal dec_shift_rrx : Std_Logic; 
signal dec_shift_val : Std_Logic_Vector(4 downto 0); 
signal dec_cy : Std_Logic; 

	-- Alu operand selection

signal dec_comp_op1 : Std_Logic; 
signal dec_comp_op2 : Std_Logic; 
signal dec_alu_cy : Std_Logic; 

	-- Exec Synchro
signal exe_pop : Std_logic; 
signal dec2exe_push : std_logic ; 

	-- Alu command

signal dec_alu_add : Std_Logic; 
signal dec_alu_and : Std_Logic; 
signal dec_alu_or : Std_Logic; 
signal dec_alu_xor : Std_Logic; 

	-- Exe Write Back to reg

signal exe_res : std_logic_vector(31 downto 0) ;
signal exe_c : Std_Logic ;
signal exe_n : Std_Logic ;
signal exe_v : Std_Logic ;
signal exe_z : Std_Logic ;
signal exe_dest : Std_Logic_Vector(3 downto 0); 
signal exe_wb : Std_Logic; 
signal exe_flag_wb : Std_Logic; 

	-- Ifetch synchro
signal dec2if_empty : Std_Logic; 
signal if_pop : Std_Logic; 
signal if2dec_empty : Std_Logic; 
signal dec_pop : Std_Logic; 

	-- Mem Write back to reg
signal mem_res : Std_Logic_Vector(31 downto 0); 
signal mem_dest : Std_Logic_Vector(3 downto 0); 
signal mem_wb : Std_Logic; 
			

--Exec :
	-- Decode interface synchro
signal dec2exe_empty : Std_logic;


	-- Mem interface
signal exe_mem_adr 		: Std_Logic_Vector(31 downto 0); 
signal exe_mem_data 	: Std_Logic_Vector(31 downto 0); 
signal exe_mem_dest 	: Std_Logic_Vector(3 downto 0); 
signal exe_mem_lw 		: Std_Logic; 
signal exe_mem_lb 		: Std_Logic; 
signal exe_mem_sw 		: Std_Logic; 
signal exe_mem_sb 		: Std_Logic; 
signal exe2mem_empty 	: Std_logic; 
signal mem_pop 			: Std_logic; 



-- Internal signal
signal dec2exe_input : std_logic_vector(128 downto 0) ;
signal dec_alu_cmd_signal : std_logic_vector(1 downto 0) ;
signal dec2exe_output : std_logic_vector(128 downto 0) ;  
Signal dec2exe_full  	 	: Std_Logic ; 



begin

dec2exe_input 		 <= 	dec_op1 			& dec_op2 		& dec_exe_dest 	& dec_exe_wb 	& dec_flag_wb 	&
					   		dec_mem_data 		& dec_mem_dest 	& dec_pre_index & dec_mem_lw 	& dec_mem_sw 	& dec_mem_lb 	& dec_mem_sb 	&
					   		dec_shift_lsl 		& dec_shift_lsr & dec_shift_asr & dec_shift_ror & dec_shift_rrx & dec_shift_val 				&
					   		dec_cy 				& dec_comp_op1 	& dec_comp_op2 	& dec_alu_cy  	&
					   		dec_alu_add 		& dec_alu_and  	& dec_alu_or 	& dec_alu_xor ;

dec_alu_cmd_signal	  <= 	"00" when dec2exe_output(3) 	= '1' else -- add
							"01" when dec2exe_output(2)		= '1' else -- or
							"10" when dec2exe_output(1) 	= '1' else -- and
							"11" when dec2exe_output(0) 	= '1' ; -- xor


exe_result <= exe_res ;
exe_c_result <= exe_c ;
exe_v_result <= exe_v ;
exe_n_result <= exe_n ;
exe_z_result <= exe_z ;

decod_i : decod
	port map (
	-- Exec  operands
					dec_op1			=> dec_op1,
					dec_op2			=> dec_op2,
					dec_exe_dest	=> dec_exe_dest,
					dec_exe_wb		=> dec_exe_wb,
					dec_flag_wb		=> dec_flag_wb,

	-- Decod to mem via exec
					dec_mem_data	=> dec_mem_data,
					dec_mem_dest	=> dec_mem_dest,
					dec_pre_index 	=> dec_pre_index ,

					dec_mem_lw		=> dec_mem_lw,
					dec_mem_lb		=> dec_mem_lb,
					dec_mem_sw		=> dec_mem_sw,
					dec_mem_sb		=> dec_mem_sb,

	-- Shifter command
					dec_shift_lsl	=> dec_shift_lsl,
					dec_shift_lsr	=> dec_shift_lsr,
					dec_shift_asr	=> dec_shift_asr,
					dec_shift_ror	=> dec_shift_ror,
					dec_shift_rrx	=> dec_shift_rrx,
					dec_shift_val	=> dec_shift_val,
					dec_cy			=> dec_cy,

	-- Alu operand selection
					dec_comp_op1	=> dec_comp_op1,
					dec_comp_op2	=> dec_comp_op2,
					dec_alu_cy 		=> dec_alu_cy ,

	-- Exec Synchro
					dec2exe_empty	=> dec2exe_empty,
					exe_pop			=> '1',
					dec2exe_push	=> dec2exe_push ,

	-- Alu command
					dec_alu_add => dec_alu_add ,
					dec_alu_and => dec_alu_and ,
					dec_alu_or => dec_alu_or ,
					dec_alu_xor => dec_alu_xor ,

	-- Exe Write Back to reg
					exe_res				=> exe_res,

					exe_c				=> exe_c,
					exe_v				=> exe_v,
					exe_n				=> exe_n,
					exe_z				=> exe_z,

					exe_dest			=> exe_dest,
					exe_wb				=> exe_wb,
					exe_flag_wb			=> exe_flag_wb,

	-- Ifetch interface
					dec_pc				=> dec_pc,
					if_ir				=> if_ir,

	-- Ifetch synchro
					dec2if_empty	=> dec2if_empty,
					if_pop			=> '1',

					if2dec_empty	=> '0',
					dec_pop			=> dec_pop,

	-- Mem Write back to reg
					mem_res			=> mem_res,
					mem_dest			=> mem_dest,
					mem_wb			=> mem_wb,

	-- global interface
					reset_n			=> reset_n,
					ck		 		=> ck,
					vdd	 			=> vdd,
					vss	 			=> vss);

	dec2exe : fifo_129b 
	port map(
		din 	=> 	dec2exe_input ,	

		dout 	=> dec2exe_output ,		

		-- commands
		push 	=>	'1' ,
		pop		=> '1' ,	

		-- flags
		full 	=> dec2exe_full ,
		empty 	=> dec2exe_empty ,

		reset_n	=> reset_n ,
		ck		=> ck ,
		vdd		=> vdd ,
		vss		=> vss	
	);
	exec_i : exec
	port map (
	-- Decode interface synchro
					dec2exe_empty	=> '0',
					exe_pop			=> exe_pop,

	-- Decode interface operands
					dec_op1			=> dec2exe_output(128 downto 97),
					dec_op2			=> dec2exe_output(96 downto 65 ),
					dec_exe_dest	=> dec2exe_output(64 downto 61),
					dec_exe_wb		=> dec2exe_output(60),
					dec_flag_wb		=> dec2exe_output(59),

	-- Decode to mem interface 
					dec_mem_data	=> dec2exe_output(58 downto 27),
					dec_mem_dest	=> dec2exe_output(26 downto 23),
					dec_pre_index 	=> dec2exe_output(22) ,

					dec_mem_lw		=> dec2exe_output(21),
					dec_mem_lb		=> dec2exe_output(20),
					dec_mem_sw		=> dec2exe_output(19),
					dec_mem_sb		=> dec2exe_output(18),

	-- Shifter command
					dec_shift_lsl	=> dec2exe_output(17),
					dec_shift_lsr	=> dec2exe_output(16),
					dec_shift_asr	=> dec2exe_output(15),
					dec_shift_ror	=> dec2exe_output(14),
					dec_shift_rrx	=> dec2exe_output(13),
					dec_shift_val	=> dec2exe_output(12 downto 8),
					dec_cy			=> dec2exe_output(7),

	-- Alu operand selection
					dec_comp_op1	=> dec2exe_output(6),
					dec_comp_op2	=> dec2exe_output(5),
					dec_alu_cy 		=> dec2exe_output(4) ,

	-- Alu command
					dec_alu_cmd		=> dec_alu_cmd_signal ,

	-- Exe bypass to decod
					exe_res			=> exe_res, -- what we send back to decode

					exe_c			=> exe_c,
					exe_v			=> exe_v,
					exe_n			=> exe_n,
					exe_z			=> exe_z,

					exe_dest		=> exe_dest,
					exe_wb			=> exe_wb,
					exe_flag_wb		=> exe_flag_wb,

	-- Mem interface
					exe_mem_adr		=> exe_mem_adr,
					exe_mem_data	=> exe_mem_data,
					exe_mem_dest	=> exe_mem_dest,

					exe_mem_lw		=> exe_mem_lw,
					exe_mem_lb		=> exe_mem_lb,
					exe_mem_sw		=> exe_mem_sw,
					exe_mem_sb		=> exe_mem_sb,

					exe2mem_empty	=> exe2mem_empty,
					mem_pop			=> '1',

	-- global interface
					reset_n			=> reset_n,
					ck		 		=> ck,
					vdd	 			=> vdd,
					vss	 			=> vss);

process(ck)


	variable seed1, seed2 : integer := 999;

  	impure FUNCTION rand_slv(len : integer) return std_logic_vector is
	        variable r : real;
	        variable slv : std_logic_vector(len - 1 downto 0);
	        BEGIN
	          for i in slv'range loop
	              uniform(seed1, seed2, r);
	            IF r > 0.5 THEN
	              slv(i) := '1';
	            ELSE
	              slv(i) := '0';
	            END IF;
	          end loop;
	        return slv;
	      END FUNCTION;

	  function to_string ( a: std_logic_vector) return string is
	      variable b : string (1 to a'length) := (others => NUL);
	      variable stri : integer := 1; 
	    begin
	      for i in a'range loop
	          b(stri) := std_logic'image(a((i)))(2);  
	      stri := stri+1;
	      end loop;
	    return b;
	    end function; 
begin
report " -------------------fichier--------------------------------------- " ;
report "-----------------fifo gestion :------------------------------------" ;
report "dec2exe_output : " &to_string(dec2exe_output) ;

report "-----------------decode gestion :-----------------------------------" ;
report "if_ir : " &to_string(if_ir) ;
report "dec_op1 :" &to_string(dec_op1) ;
report "dec_op2 :" &to_string(dec_op2) ;
report "dec_exe_dest :" &to_string(dec_exe_dest) ;
report "dec_shift_lsl :" &Std_Logic'image(dec_shift_lsl)(2) ;
report "dec_shift_lsr :" &Std_Logic'image(dec_shift_lsr)(2) ;
report "dec_shift_asr :" &Std_Logic'image(dec_shift_asr)(2) ;
report "dec_shift_ror :" &Std_Logic'image(dec_shift_ror)(2) ;
report "dec_shift_rrx :" &Std_Logic'image(dec_shift_rrx)(2) ;
report "alu cmd add :" &std_logic'image(dec2exe_output(3))(2);
report "alu cmd or :" &std_logic'image(dec2exe_output(2))(2);
report "alu cmd and  :" &std_logic'image(dec2exe_output(1))(2);
report "alu cmd xor :" &std_logic'image(dec2exe_output(0))(2);
report "dec_comp_op1 : " &Std_Logic'image(dec_comp_op1)(2) ;
report "dec_comp_op2 : " &Std_Logic'image(dec_comp_op2)(2) ;
report "-----------------exe gestion :-------------------------------------" ;

report "dec_op1 entrance exec :" &to_string(dec2exe_output(128 downto 97)) ;
report "dec_op2 entrance exec :" &to_string(dec2exe_output(96 downto 65 )) ;
report "dec_alu_cmd : " &to_string(dec_alu_cmd_signal) ;
report "dec_shift_val :" &to_string(dec_shift_val) ;

end process ;
end architecture ;