LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;

entity test_decode_exe_tb is 
end entity ;

architecture behavior of test_decode_exe_tb is

component test_decode_exe 
	port(
		dec_pc 	: out 	std_logic_vector(31 downto 0);
		if_ir 	: in 	std_logic_vector(31 downto 0);
		exe_result : out 	std_logic_vector(31 downto 0);
		exe_c_result	: out 	Std_Logic ;
		exe_v_result	: out 	Std_Logic ;
		exe_n_result	: out 	Std_Logic ;
		exe_z_result 	: out 	Std_Logic ;
		reset_n : in std_logic ;
		ck 		: in 	std_logic ;
		vss 	: in 	bit ;
		vdd 	: in 	bit 
		); 
end component ;

signal dec_pc :  	std_logic_vector(31 downto 0);
signal if_ir :  	std_logic_vector(31 downto 0);
signal exe_result :  	std_logic_vector(31 downto 0);
signal exe_c_result :  	Std_Logic ;
signal exe_v_result :  	Std_Logic ;
signal exe_n_result :  	Std_Logic ;
signal exe_z_result :  	Std_Logic ;
signal reset_n : std_logic ;
signal ck :  	std_logic ;
signal vss :  	bit ;
signal vdd :  	bit ;

begin 

core1 : test_decode_exe port map(
 dec_pc => dec_pc ,
 if_ir => if_ir ,
 exe_result => exe_result ,
 exe_c_result => exe_c_result ,
 exe_v_result => exe_v_result ,
 exe_n_result => exe_n_result ,
 exe_z_result => exe_z_result ,
 reset_n => reset_n ,
 ck => ck ,
 vss => vss ,
 vdd => vdd
);

	reset : process 
	begin
		reset_n <= '0' ;
		wait for 12 ns ;
		reset_n <= '1' ;
		wait ;
	end process ; 

	clock : process
	begin
		ck <= '1' ;
		wait for 4 ns ;
		ck <= '0' ;
		wait for 4 ns ;
	end process ;

		tb : process(ck)

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
		if(rising_edge(ck)) then
		dec_pc <= X"00000000" ;
		if_ir  <= "11100010100000000001000000000001" ; -- add r0,r1,1 ;
		end if;
		report"__________________________________________________";
		report " dec_pc : " 	&to_string(dec_pc) ;
		report "if_ir : " 		&to_string(if_ir) ;
		report " exe_res : " 	&to_string(exe_result) ;
		report "exe_c : "  		&std_logic'image(exe_c_result)(2) ;
		report "exe_n : "  		&std_logic'image(exe_n_result)(2) ;
		report "exe_z : "  		&std_logic'image(exe_z_result)(2) ;
		report "exe_v : "  		&std_logic'image(exe_v_result)(2) ;
	end process ;


end architecture ;