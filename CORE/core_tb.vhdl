----------
--exec_tb
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


ENTITY core_tb IS
END ENTITY ;

ARCHITECTURE BEHAVIOR OF core_tb IS
component arm_core
  port(
      	-- Icache interface
			if_adr			: out Std_Logic_Vector(31 downto 0) ;
			if_adr_valid	: out Std_Logic;

			ic_inst			: in Std_Logic_Vector(31 downto 0) ;
			ic_stall			: in Std_Logic;

	-- Dcache interface
			mem_adr			: out Std_Logic_Vector(31 downto 0);
			mem_stw			: out Std_Logic;
			mem_stb			: out Std_Logic;
			mem_load			: out Std_Logic;

			mem_data			: out Std_Logic_Vector(31 downto 0);
			dc_data			: in Std_Logic_Vector(31 downto 0);
			dc_stall			: in Std_Logic;


	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit
  );
end component;

-- Icache interface
signal if_adr			:  Std_Logic_Vector(31 downto 0) ;
signal if_adr_valid	:  Std_Logic;

signal ic_inst			:  Std_Logic_Vector(31 downto 0) ;
signal ic_stall			:  Std_Logic;

-- Dcache interface
signal mem_adr			:  Std_Logic_Vector(31 downto 0);
signal mem_stw			:  Std_Logic;
signal mem_stb			:  Std_Logic;
signal mem_load			:  Std_Logic;

signal mem_data			:  Std_Logic_Vector(31 downto 0);
signal dc_data			:  Std_Logic_Vector(31 downto 0);
signal dc_stall			:  Std_Logic;


-- global interface
signal ck					:  Std_Logic;
signal reset_n			:  Std_Logic;
signal vdd				:  bit;
signal vss				: bit ;

function get_inst (
     if_adr         :  integer
    ) return integer is
begin
  assert false severity failure;
end get_inst;
attribute foreign of get_inst : function is "VHPIDIRECT get_inst";

BEGIN 

  arm_core_stage : arm_core port map(
      	-- Icache interface
			if_adr => if_adr,
			if_adr_valid => if_adr_valid,

			ic_inst => ic_inst,
			ic_stall => ic_stall,

	-- Dcache interface
			mem_adr => mem_adr,
			mem_stw => mem_stw,
			mem_stb => mem_stb,
			mem_load => mem_load,

			mem_data => mem_data,
			dc_data => dc_data,
			dc_stall => dc_stall,


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
   
   
    testproc: process(ck)
        variable inst: Std_Logic_Vector(31 downto 0);
   begin
       inst := std_logic_vector(to_signed(get_inst(to_integer(signed(if_adr))), 32));
       report std_logic'image(inst(0));
       ic_inst <= inst(31 downto 0);
   end process testproc;
     

END ARCHITECTURE ;