library ieee ;
use ieee.std_logic_1164.all

entity test_decode_exe is
	port(
		ck : in std_logic :
		vss : in std_logic :
		vdd : in std_logic ;
				
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


Component fifo_125b
	PORT(
		din				: in  std_logic_vector(124 downto 0);
		dout			: out std_logic_vector(124 downto 0);

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


signal dec2exe_input : std_logic_vector(124 downto 0) ;
signal dec_alu_cmd_signal : std_logic_vector(1 downto 0) ;
signal dec_op1
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


dec2exe_input 		 <= 	dec_op1 			& dec_op2 		& dec_exe_dest 	& dec_exe_wb 	& dec_flag_wb 	&
					   		dec_mem_data 		& dec_mem_dest 	& dec_pre_index & dec_mem_lw 	& dec_mem_sw 	& dec_mem_lb 	& dec_mem_sb 	&
					   		dec_shift_lsl 		& dec_shift_lsr & dec_shift_asr & dec_shift_ror & dec_shift_rrx & dec_shift_val 				&
					   		dec_cy 				& dec_comp_op1 	& dec_comp_op2 	& dec_alu_cy  	&
					   		dec_alu_add 		& dec_alu_and  	& dec_alu_or 	& dec_alu_xor ;

dec_alu_cmd_signal	  <= 	"00" when dec2exe_output(3) 	= '1' else
							"01" when dec2exe_output(2)		= '1' else
							"10" when dec2exe_output(1) 	= '1' else
							"11" when dec2exe_output(0) 	= '1' ;

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
					exe_pop			=> exe_pop,
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
					if_pop			=> if_pop,

					if2dec_empty	=> if2dec_empty,
					dec_pop			=> dec_pop,

	-- Mem Write back to reg
					mem_res			=> mem_res,
					mem_dest			=> mem_dest,
					mem_wb			=> mem_wb,

	-- global interface
					reset_n			=> reset_n,
					ck		 			=> ck,
					vdd	 			=> vdd,
					vss	 			=> vss);

	dec2exe : fifo_125b 
	port map(
		din 	=> 	dec2exe_input ,	

		dout 	=> dec2exe_output ,		

		-- commands
		push 	=>	dec2exe_push ,
		pop		=> exe_pop ,	

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
					dec2exe_empty	=> dec2exe_empty,
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
					exe_res			=> exe_res,

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
					mem_pop			=> mem_pop,

	-- global interface
					reset_n			=> reset_n,
					ck		 		=> ck,
					vdd	 			=> vdd,
					vss	 			=> vss);
