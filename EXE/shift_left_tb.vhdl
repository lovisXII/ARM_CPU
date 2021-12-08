library ieee;
use ieee.std_logic_1164.all ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


entity shift_left_tb is
end entity ;

architecture test_bench of shift_left_tb is
	signal cin,cout : std_logic_vector(31 downto 0) ;
	signal shift_value : std_logic_vector(4 downto 0) ;
	signal carry_out : std_logic ;

	component shift_left is
			port (cin : in std_logic_vector(31 downto 0) ;
			shift_value : in std_logic_vector(4 downto 0);
			cout : out std_logic_vector(31 downto 0);
			carry_out : out std_logic );
	end component ;

begin

	shift_left0 : shift_left port map(cin=>cin, shift_value=>shift_value,carry_out=>carry_out,cout=>cout) ;

	test_bench : process 

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

      begin 

      cin <= rand_slv(32) ;
      shift_value <= rand_slv(5) ;
      report " cin : " &to_string(cin) ;
      report " shift_value : " &to_string(shift_value) ;
      report "cout : " &to_string(cout) ;
      report "carry : " &std_logic'image(carry_out)(2) ;
      wait for 4 ns ;
      end process ;
      end architecture ;
