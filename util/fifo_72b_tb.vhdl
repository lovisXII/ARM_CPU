LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;

entity fifo_72_tb is
end entity ;

architecture behavior of fifo_72b_tb is
		constant longueur : integer := 32; 
		signal din :  std_logic_vector(longueur-1 downto 0) ;
		signal push :  std_logic ;
		signal reset_n :  std_logic ;
		signal pop :  std_logic ;
		signal ck :  std_logic ;
		signal full :  std_logic ;
		signal empty :  std_logic ;
		signal dout :  std_logic_vector(longueur-1 downto 0);

	component fifo_72b
		generic  (width : integer); 
		port 
		(din : in std_logic_vector(width-1 downto 0) ;
		push : in std_logic ;
		reset_n : in std_logic ;
		pop : in std_logic ;
		ck : in std_logic ;
		full : out std_logic ;
		empty : out std_logic ;
		dout : out std_logic_vector(width-1 downto 0) );
	end component ;
begin
	
	fifo1 : fifo_72b port map(din =>din, push => push, reset_n=>reset_n, pop => pop, ck => ck, full => full, empty => empty, dout => dout) ;

	reset : process
		begin	
			reset_n <= '0' ;
			wait for 12 ns;
			reset_n <= '1' ;
			wait;
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
			din <= rand_slv(longueur) ;
			push <= rand_slv(2)(1) ;
			pop <= rand_slv(2)(1) ;
		end if;
		report"__________________________________________________";
		report " din : " &to_string(din) ;
		report "dout : " &to_string(dout) ;
		report " push : " &std_logic'image(push)(2) ;
		report "pop : "  &std_logic'image(pop)(2) ;
		report "reset_n : "  &std_logic'image(reset_n)(2) ;
	end process ;


end architecture ;