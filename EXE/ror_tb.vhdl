----------
--shifter_tb
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


ENTITY ror_tb IS
END ENTITY ;

ARCHITECTURE BEHAVIOR OF ror_tb IS
  
  SIGNAL cin,cout : std_logic ;
  SIGNAL din,dout : std_logic_vector(31 downto 0) ;
  SIGNAL shift_val : std_logic_vector(4 downto 0) ;

  COMPONENT ror_entity IS
    PORT(
    shift_val : IN Std_Logic_Vector(4 downto 0);
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic);
  END COMPONENT ;

  BEGIN 

  ror_0 : ror_entity port map(shift_val => shift_val, din => din, cin => cin, dout => dout, cout => cout) ;
  
  tes_tb_process : PROCESS

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

    BEGIN

    --TEST LSL

    din <= rand_slv(32) ;
    shift_val <= rand_slv(5) ;

    report "shift_val : " &to_string(shift_val) ;

    report "din : " &to_string(din) ;
    report "cin :" & std_logic'image(cin)(2) ; 

        
    report "dout : " &to_string(dout) ;
    report "cout :" & std_logic'image(cout)(2) ;
    
    wait for 4 ns ;

    report "__________________________________________________________________________";
    
    END PROCESS tes_tb_process ;     
     

    END ARCHITECTURE ;