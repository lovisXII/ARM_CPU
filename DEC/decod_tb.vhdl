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

decod0 : decod port map (   
	-- Exec  operands
			dec_op1 => dec_op1,
			dec_op2 => dec_op2,
			dec_exe_dest => dec_exe_dest,
			dec_exe_wb => dec_exe_wb,
			dec_flag_wb => dec_flag_wb,

	-- Decod to mem via exec
			dec_mem_data => dec_mem_data,
			dec_mem_dest => dec_mem_dest,
			dec_pre_index => dec_pre_index,

			dec_mem_lw => dec_mem_lw,
			dec_mem_lb => dec_mem_lb,
			dec_mem_sw => dec_mem_sw,
			dec_mem_sb => dec_mem_sb,

	-- Shifter command
			dec_shift_lsl => dec_shift_lsl,
			dec_shift_lsr => dec_shift_lsr,
			dec_shift_asr => dec_shift_asr,
			dec_shift_ror => dec_shift_ror,
			dec_shift_rrx => dec_shift_rrx,
			dec_shift_val => dec_shift_val,
			dec_cy => dec_cy,

	-- Alu operand selection
			dec_comp_op1 => dec_comp_op1,
			dec_comp_op2 => dec_comp_op2,
			dec_alu_cy => dec_alu_cy,

	-- Exec Synchro
			dec2exe_empty => dec2exe_empty,
			exe_pop => exe_pop,

	-- Alu command
			dec_alu_add => dec_alu_add,
			dec_alu_and => dec_alu_and,
			dec_alu_or => dec_alu_or,
			dec_alu_xor => dec_alu_xor,

	-- Exe Write Back to reg
			exe_res => exe_res,

			exe_c => exe_c,
			exe_v => exe_v,
			exe_n => exe_n,
			exe_z => exe_z,

			exe_dest => exe_dest,
			exe_wb => exe_wb,
			exe_flag_wb => exe_flag_wb,

	-- Ifetch interface
			dec_pc => dec_pc,
			if_ir => if_ir,

	-- Ifetch synchro : fifo dec2if et if2dec
			dec2if_empty => dec2if_empty,
			if_pop => if_pop,

			if2dec_empty => if2dec_empty,
			dec_pop => dec_pop,

	-- Mem Write back to reg
			mem_res => mem_res,
			mem_dest => mem_dest,
			mem_wb => mem_wb,
			
	-- global interface
			ck => ck,
			reset_n => reset_n,
			vdd => vdd,
			vss => vss
);

clock_process : PROCESS
  begin 
    ck <= '1';
    WAIT FOR 4 ns;
    ck <= '0';
    WAIT FOR 4 ns;
  end process;

  tb_process : PROCESS(ck)
  variable counter : integer := 0;
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

    function to_string ( a: std_logic) return CHARACTER is
      begin
        return std_logic'image(a)(2);
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


    BEGIN
    if rising_edge(ck) then
       if (counter = 0) then
            reset_n <= '0';
        elsif (counter = 1) then
            reset_n <= '0';
        elsif (counter = 2) then
            reset_n <= '0';
        elsif (counter = 3) then
        reset_n <= '1';
        -- add r0, r0, 127
        if_ir   <= "11100010100100000000000001111111";

        exe_pop <= '0';
        exe_res	<= X"00000000";

        exe_c	<= '0';
        exe_v	<= '0';
        exe_n	<= '0';
        exe_z	<= '0';

        exe_dest    <= X"0";
        exe_wb	    <= '0';
        exe_flag_wb	<= '0';
        if_pop	<= '1';

        if2dec_empty    <= '0';

        mem_res	<= X"00000000";
        mem_dest	<= X"0";
        mem_wb		<= '0';
        report "============================================================================";
        report "============================================================================";
        report "============================================================================";
		report "------------------ Exec  operands----------------------";
        report "dec_op1 : " & to_string(dec_op1); 
        report "dec_op2 : " & to_string(dec_op2); 
        report "dec_exe_dest : " & to_string(dec_exe_dest); 
        report "dec_exe_wb : " & to_string(dec_exe_wb); 
        report "dec_flag_wb : " & to_string(dec_flag_wb); 

		report "------------------ Decod to mem via exec----------------------";
        report "dec_mem_data : " & to_string(dec_mem_data); 
        report "dec_mem_dest : " & to_string(dec_mem_dest); 
        report "dec_pre_index : " & to_string(dec_pre_index); 

        report "dec_mem_lw : " & to_string(dec_mem_lw); 
        report "dec_mem_lb : " & to_string(dec_mem_lb); 
        report "dec_mem_sw : " & to_string(dec_mem_sw); 
        report "dec_mem_sb : " & to_string(dec_mem_sb); 

		report "------------------ Shifter command----------------------";
        report "dec_shift_lsl : " & to_string(dec_shift_lsl); 
        report "dec_shift_lsr : " & to_string(dec_shift_lsr); 
        report "dec_shift_asr : " & to_string(dec_shift_asr); 
        report "dec_shift_ror : " & to_string(dec_shift_ror); 
        report "dec_shift_rrx : " & to_string(dec_shift_rrx); 
        report "dec_shift_val : " & to_string(dec_shift_val); 
        report "dec_cy : " & to_string(dec_cy); 

		report "------------------ Alu operand selection----------------------";
        report "dec_comp_op1 : " & to_string(dec_comp_op1); 
        report "dec_comp_op2 : " & to_string(dec_comp_op2); 
        report "dec_alu_cy : " & to_string(dec_alu_cy); 

		report "------------------ Exec Synchro----------------------";
        report "dec2exe_empty : " & to_string(dec2exe_empty); 

		report "------------------ Alu command----------------------";
        report "dec_alu_add : " & to_string(dec_alu_add); 
        report "dec_alu_and : " & to_string(dec_alu_and); 
        report "dec_alu_or : " & to_string(dec_alu_or); 
        report "dec_alu_xor : " & to_string(dec_alu_xor); 

		report "------------------ Ifetch interface----------------------";
        report "dec_pc : " & to_string(dec_pc); 

		report "------------------ Ifetch synchro : fifo dec2if et if2dec----------------------";
        report "dec2if_empty : " & to_string(dec2if_empty); 

        report "dec_pop : " & to_string(dec_pop); 
       elsif (counter = 5) then
       elsif (counter = 6) then
       elsif (counter = 7) then
            counter := 2;
       end if;
       counter := counter + 1;
    end if;
  END PROCESS tb_process ;


end behavior;