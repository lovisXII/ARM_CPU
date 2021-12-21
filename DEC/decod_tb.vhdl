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
(
	-- Exec  operands
			dec_op1 => dec_op1 Std_Logic_Vector(31 downto 0), -- first alu input
			dec_op2 => dec_op2 Std_Logic_Vector(31 downto 0), -- shifter input
			dec_exe_dest => dec_exe_dest Std_Logic_Vector(3 downto 0), -- Rd destination
			dec_exe_wb => dec_exe_wb Std_Logic, -- Rd destination write back
			dec_flag_wb => dec_flag_wb Std_Logic, -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data => dec_mem_data Std_Logic_Vector(31 downto 0), -- data to MEM
			dec_mem_dest => dec_mem_dest Std_Logic_Vector(3 downto 0), -- @ of MEM
			dec_pre_index => dec_pre_index Std_logic, -- say if we do pre index or no []!

			dec_mem_lw => dec_mem_lw Std_Logic, -- type of memory access
			dec_mem_lb => dec_mem_lb Std_Logic,
			dec_mem_sw => dec_mem_sw Std_Logic,
			dec_mem_sb => dec_mem_sb Std_Logic,

	-- Shifter command
			dec_shift_lsl => dec_shift_lsl Std_Logic, --meme signaux que dans exe
			dec_shift_lsr => dec_shift_lsr Std_Logic,
			dec_shift_asr => dec_shift_asr Std_Logic,
			dec_shift_ror => dec_shift_ror Std_Logic,
			dec_shift_rrx => dec_shift_rrx Std_Logic,
			dec_shift_val => dec_shift_val Std_Logic_Vector(4 downto 0),
			dec_cy => dec_cy Std_Logic,

	-- Alu operand selection
			dec_comp_op1 => dec_comp_op1 Std_Logic,
			dec_comp_op2 => dec_comp_op2 Std_Logic,
			dec_alu_cy => dec_alu_cy Std_Logic,

	-- Exec Synchro
			dec2exe_empty => dec2exe_empty Std_Logic, --fifo en entree dec/exe
			exe_pop => exe_pop Std_logic,

	-- Alu command
			dec_alu_add => dec_alu_add Std_Logic,
			dec_alu_and => dec_alu_and Std_Logic,
			dec_alu_or => dec_alu_or Std_Logic,
			dec_alu_xor => dec_alu_xor Std_Logic,

	-- Exe Write Back to reg
			exe_res => exe_res Std_Logic_Vector(31 downto 0),

			exe_c => exe_c Std_Logic,
			exe_v => exe_v Std_Logic,
			exe_n => exe_n Std_Logic,
			exe_z => exe_z Std_Logic,

			exe_dest => exe_dest Std_Logic_Vector(3 downto 0), -- Rd destination
			exe_wb => exe_wb Std_Logic, -- Rd destination write back
			exe_flag_wb => exe_flag_wb Std_Logic, -- CSPR modifiy

	-- Ifetch interface
			dec_pc => dec_pc Std_Logic_Vector(31 downto 0) , -- pc
			if_ir => if_ir Std_Logic_Vector(31 downto 0) , -- 32 bits to decode

	-- Ifetch synchro : fifo dec2if et if2dec
			dec2if_empty => dec2if_empty Std_Logic, -- si la fifo qui recup pc est vide
			if_pop => if_pop Std_Logic, -- pop de la fifo dec2if

			if2dec_empty => if2dec_empty Std_Logic, -- si la fifo qui envoie l'inst est vide
			dec_pop => dec_pop Std_Logic, -- 

	-- Mem Write back to reg
			mem_res => mem_res Std_Logic_Vector(31 downto 0),
			mem_dest => mem_dest Std_Logic_Vector(3 downto 0),
			mem_wb => mem_wb Std_Logic,
			
	-- global interface
			ck => ck Std_Logic,
			reset_n => reset_n Std_Logic,
			vdd => vdd bit,
			vss => vss bit
);

	clock_process : PROCESS
	  begin 
	    ck <= '1';
	    WAIT FOR 4 ns;
	    ck <= '0';
	    WAIT FOR 4 ns;
  	end process;


  	reset: process
	begin
		reset_n <= '0';
		wait for 4 ns;
		reset_n <= '1';
		wait;
	end process;

	  	tes_tb_process : PROCESS(ck)

	  variable seed1, seed2 : integer := 999;

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
	variable read1, read2 : std_logic_vector(3 downto 0) ;
    BEGIN
    if rising_edge(ck) then

       report "__________________________________________________";
	   report "reset : " & std_logic'image(reset_n)(2);
       report "wdata1 : " & to_string(wdata1);
       report "wdata2 : " & to_string(wdata2); 
       report "wen1 : " & std_logic'image(wen1)(2);
       report "wen2 : " & std_logic'image(wen2)(2);                 
       report "wadr1 : " & to_string(wadr1);
       report "wadr2 : " & to_string(wadr2);

       report "wcry : " & std_logic'image(wcry)(2);
       report "wzero : " & std_logic'image(wzero)(2);
       report "wneg : " & std_logic'image(wneg)(2);
       report "wovr : " & std_logic'image(wovr)(2);
       report "cspr_wb : " & std_logic'image(cspr_wb)(2);

       report "radr1 : " & to_string(radr1); 
  	   report "radr2 : " & to_string(radr2); 
  	   report "radr3 : " & to_string(radr3); 
  	   report "radr4 : " & to_string(radr4);

  	   report "inval_adr1 : " & to_string(inval_adr1);
  	   report "inval_adr2 : " & to_string(inval_adr2);
  	   report "inval_czn : " & std_logic'image(inval_czn)(2);
  	   report "inval_ovr : " & std_logic'image(inval_ovr)(2);
	   report "inc_pc : " & std_logic'image(inc_pc)(2);

	   report "reg_rd1 : " & to_string(reg_rd1);
	   report "reg_rd2 : " & to_string(reg_rd2);
	   report "reg_rd3 : " & to_string(reg_rd3);
	   report "reg_rd4 : " & to_string(reg_rd4);

	   report "reg_v1 : " & std_logic'image(reg_v1)(2);
	   report "reg_v2 : " & std_logic'image(reg_v2)(2);
	   report "reg_v3 : " & std_logic'image(reg_v3)(2);
	   report "reg_v4 : " & std_logic'image(reg_v4)(2);

	   report "reg_cry : " & std_logic'image(reg_cry)(2);
	   report "reg_zero : " & std_logic'image(reg_zero)(2);
	   report "reg_neg : " & std_logic'image(reg_neg)(2);
	   report "reg_cznv : " & std_logic'image(reg_cznv)(2);
	   report "reg_ovr : " & std_logic'image(reg_ovr)(2);
	   report "reg_vv : " & std_logic'image(reg_vv)(2);

	   report "reg_pc : " & to_string(reg_pc);
	   report "reg_pcv : " & std_logic'image(reg_pcv)(2);

    	-- Exec  operands
			dec_op1 => randslv(32) ;
			dec_op2 => randslv(32),
			dec_exe_dest => randslv(4),
			dec_exe_wb => randslv(1),
			dec_flag_wb => randslv(1),

	-- Decod to mem via exec
			dec_mem_data => randslv(32),
			dec_mem_dest => randslv(4),
			dec_pre_index => randslv(1),

			dec_mem_lw => randslv(1),
			dec_mem_lb => randslv(1),
			dec_mem_sw => randslv(1),
			dec_mem_sb => randslv(1),

	-- Shifter command
			dec_shift_lsl => randslv(1),
			dec_shift_lsr => randslv(1),
			dec_shift_asr => randslv(1),
			dec_shift_ror => randslv(1),
			dec_shift_rrx => randslv(1),
			dec_shift_val => randslv(5),
			dec_cy => randslv(1),

	-- Alu operand selection
			dec_comp_op1 => randslv(1),
			dec_comp_op2 => randslv(1),
			dec_alu_cy => randslv(1),

	-- Exec Synchro
			dec2exe_empty => randslv(1),
			exe_pop => randslv(1),

	-- Alu command
			dec_alu_add => randslv(1),
			dec_alu_and => randslv(1),
			dec_alu_or => randslv(1),
			dec_alu_xor => randslv(1),

	-- Exe Write Back to reg
			exe_res => randslv(32),

			exe_c => randslv(1),
			exe_v => randslv(1),
			exe_n => randslv(1),
			exe_z => randslv(1),

			exe_dest => randslv(4),
			exe_wb => randslv(1),
			exe_flag_wb => randslv(1),

	-- Ifetch interface
			dec_pc => randslv(32),
			if_ir => randslv(32),

	-- Ifetch synchro => randslv(
			dec2if_empty => randslv(1),
			if_pop => randslv(1),

			if2dec_empty => randslv(1),
			dec_pop => randslv(1),

	-- Mem Write back to reg
			mem_res => randslv(32),
			mem_dest => randslv(4),
			mem_wb => randslv(1),
			
	-- global interface
			ck => randslv(1),
			reset_n => randslv(1),
			vdd => randslv(1),
			vss => randslv(1),


    end if;
  END PROCESS tes_tb_process ;     

end architecture behavior;