----------
--shifter_tb
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


ENTITY shifter_tb IS
END ENTITY ;

ARCHITECTURE BEHAVIOR OF shifter_tb IS
  
  SIGNAL shift_lsl,shift_lsr,shift_asr,shift_ror,shift_rrx,cin,cout : std_logic ;
  SIGNAL din,dout : std_logic_vector(31 downto 0) ;
  SIGNAL shift_val : std_logic_vector(4 downto 0) ;
  SIGNAL vdd, vss : bit ;

  COMPONENT shifter IS
    PORT(
    shift_lsl : IN  Std_Logic;-- permet de dire quel type de shift on effectue
    shift_lsr : IN  Std_Logic;
    shift_asr : IN  Std_Logic;
    shift_ror : IN  Std_Logic;
    shift_rrx : IN  Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic;
    -- global interface
    vdd		: in bit;
    vss		: in bit );
  END COMPONENT ;

  BEGIN 

  shifter_0 : shifter port map(shift_lsl => shift_lsl,shift_lsr => shift_lsr, shift_asr => shift_asr, shift_ror => shift_ror, shift_rrx => shift_rrx, shift_val => shift_val, din => din, cin => cin, dout => dout, cout => cout, vdd => vdd, vss => vss) ;
  
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

    shift_lsl <= '1' ;
    shift_lsr <= '0' ;
    shift_asr <= '0' ;
    shift_ror <= '0' ;
    shift_rrx <= '0' ;
    din <= rand_slv(32) ;
    shift_val <= rand_slv(5) ;
    report "shift_lsl :" & std_logic'image(shift_lsl)(2) ;
    report "shift_lsr :" & std_logic'image(shift_lsr)(2) ;
    report "shift_asr :" & std_logic'image(shift_asr)(2) ;
    report "shift_ror :" & std_logic'image(shift_ror)(2) ;
    report "shift_rrx :" & std_logic'image(shift_rrx)(2) ;

    report "shift_val : " &to_string(shift_val) ;

    report "din : " &to_string(din) ;
    report "cin :" & std_logic'image(cin)(2) ; 

    report "dout : " &to_string(dout) ;
    report "cout :" & std_logic'image(cout)(2) ;
    report"____________________________________________________________" ;
    wait for 4 ns ;

    --TEST LSR

    shift_lsl <= '0' ;
    shift_lsr <= '1' ;
    shift_asr <= '0' ;
    shift_ror <= '0' ;
    shift_rrx <= '0' ;

    din <= rand_slv(32) ;
    shift_val <= rand_slv(5) ;
    report "shift_lsl :" & std_logic'image(shift_lsl)(2) ;
    report "shift_lsr :" & std_logic'image(shift_lsr)(2) ;
    report "shift_asr :" & std_logic'image(shift_asr)(2) ;
    report "shift_ror :" & std_logic'image(shift_ror)(2) ;
    report "shift_rrx :" & std_logic'image(shift_rrx)(2) ;

    report "shift_val : " &to_string(shift_val) ;

    report "din : " &to_string(din) ;
    report "cin :" & std_logic'image(cin)(2) ; 

    report "dout : " &to_string(dout) ;
    report "cout :" & std_logic'image(cout)(2) ;
    report"____________________________________________________________" ;
    wait for 4 ns ;

    --TEST ASR

    shift_lsl <= '0' ;
    shift_lsr <= '0' ;
    shift_asr <= '1' ;
    shift_ror <= '0' ;
    shift_rrx <= '0' ;
    din <= rand_slv(32) ;
    shift_val <= rand_slv(5) ;
    report "shift_lsl :" & std_logic'image(shift_lsl)(2) ;
    report "shift_lsr :" & std_logic'image(shift_lsr)(2) ;
    report "shift_asr :" & std_logic'image(shift_asr)(2) ;
    report "shift_ror :" & std_logic'image(shift_ror)(2) ;
    report "shift_rrx :" & std_logic'image(shift_rrx)(2) ;

    report "shift_val : " &to_string(shift_val) ;

    report "din : " &to_string(din) ;
    report "cin :" & std_logic'image(cin)(2) ; 

    report "dout : " &to_string(dout) ;
    report "cout :" & std_logic'image(cout)(2) ;
        report"____________________________________________________________" ;
    wait for 4 ns ;

    --TEST ROR

    shift_lsl <= '0' ;
    shift_lsr <= '0' ;
    shift_asr <= '0' ;
    shift_ror <= '1' ;
    shift_rrx <= '0' ;
    cin <= '1' ;
    din <= rand_slv(32) ;
    shift_val <= rand_slv(5) ;
    report "shift_lsl :" & std_logic'image(shift_lsl)(2) ;
    report "shift_lsr :" & std_logic'image(shift_lsr)(2) ;
    report "shift_asr :" & std_logic'image(shift_asr)(2) ;
    report "shift_ror :" & std_logic'image(shift_ror)(2) ;
    report "shift_rrx :" & std_logic'image(shift_rrx)(2) ;

    report "shift_val : " &to_string(shift_val) ;

    report "din : " &to_string(din) ;
    report "cin :" & std_logic'image(cin)(2) ; 

    report "dout : " &to_string(dout) ;
    report "cout :" & std_logic'image(cout)(2) ;
        report"____________________________________________________________" ;
    wait for 4 ns ;

    
    END PROCESS tes_tb_process ;     
     

    END ARCHITECTURE ;

    