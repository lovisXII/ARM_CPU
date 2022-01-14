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
            ic_stall		: in Std_Logic;

    -- Dcache interface
            mem_adr			: out Std_Logic_Vector(31 downto 0);
            mem_stw			: out Std_Logic;
            mem_stb			: out Std_Logic;
            mem_load		: out Std_Logic;

            mem_data		: out Std_Logic_Vector(31 downto 0);
            dc_data			: in Std_Logic_Vector(31 downto 0);
            dc_stall		: in Std_Logic;


    -- global interface
            ck				: in Std_Logic;
            reset_n			: in Std_Logic;
            vdd				: in bit;
            vss				: in bit
);
end component;

-- Icache interface
signal if_adr			:  Std_Logic_Vector(31 downto 0) ;
signal if_adr_valid	    :  Std_Logic;

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
    adr         :  integer
    ) return integer is
begin
assert false severity failure;
end get_inst;
attribute foreign of get_inst : function is "VHPIDIRECT get_inst";


function get_mem (
    adr         :  integer
    ) return integer is
begin
assert false severity failure;
end get_mem;
attribute foreign of get_mem : function is "VHPIDIRECT get_mem";


function write_mem (
    adr         :  integer;
    data         :  integer
    ) return integer is
begin
assert false severity failure;
end write_mem;
attribute foreign of write_mem : function is "VHPIDIRECT write_mem";

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

  function to_string ( a: std_logic) return string is -- permet d'utiliser la fonction to_string pour les std_logic 
      variable b : string (1 to 1) := (others => NUL);
    begin
      b(1) := std_logic'image(a)(2);  
    return b;
  end function;

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

        reset_process : PROCESS
        begin 
            reset_n <= '0';
            WAIT FOR 12 ns;
            reset_n <= '1';
            WAIT;
        end process;

    ic_stall <= '0';
    dc_stall <= '0';
    memwriteproc: process(ck)
        variable inst: Std_Logic_Vector(31 downto 0); -- instruction send to the cpu
        variable counter: integer;
        variable read: integer;
        variable adr: Std_Logic_Vector(31 downto 0);

    begin
        if rising_edge(ck) then
        report "reading instr : " & to_string(if_adr);
        if (mem_load = '0' and reset_n = '1') then
            read := write_mem(to_integer(signed(mem_adr)), to_integer(signed(mem_data)));
        end if;
    end if;
    end process memwriteproc;

   readinstrproc: process(if_adr)
   begin
        ic_inst <= std_logic_vector(to_signed(get_inst(to_integer(signed(if_adr))), 32));
   end process readinstrproc;

   readmemproc: process(mem_adr)
   begin
        dc_data <= std_logic_vector(to_signed(get_mem(to_integer(signed(mem_adr))), 32));
   end process readmemproc;
    

END ARCHITECTURE ;