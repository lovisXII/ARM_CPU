----------
--ALU TB
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


ENTITY ALU_tb IS
END ENTITY ;

ARCHITECTURE BEHAVIOR OF ALU_tb IS
  
  SIGNAL  op1, op2, res : std_logic_vector(31 downto 0) ;
  SIGNAL cin, cout, n, v, z : STD_LOGIC ;
  SIGNAL cmd : std_logic_vector(1 downto 0) ;
  SIGNAL vdd, vss : bit ;

  COMPONENT ALU IS
    PORT( op1  : in  Std_Logic_Vector(31 downto 0);
           op2  : in  Std_Logic_Vector(31 downto 0);
           cin  : in  Std_Logic;
           cmd  : in  Std_Logic_Vector(1 downto 0);
           res  : inout Std_Logic_Vector(31 downto 0);
           cout : out Std_Logic;
           z    : out Std_Logic;
           n    : out Std_Logic;
           v    : out Std_Logic;
           vdd  : in  bit;
           vss  : in  bit);
  END COMPONENT ;

  BEGIN 

  ALU_0 : ALU port map(op1 => op1, op2 => op2, cin => cin, cmd => cmd, res => res, cout => cout, z => z, n => n, v => v, vdd => vdd, vss => vss) ;
  
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
    cin <= '0' ;
    cmd <= "00"; 
    op1 <= rand_slv(32) ;
    op2 <= rand_slv(32) ;
    report "cmd :" &to_string(cmd) ; 
    report "cin : " & std_logic'image(cin)(2);
    report "op1 : " &to_string(op1) ;
    report "op2 : " &to_string(op2) ;
    report "res : " &to_string(res) ;
    report "cout : " & std_logic'image(cout)(2);
    report "z : " & std_logic'image(z)(2);
    report "n : " & std_logic'image(n)(2);
    report "v : " & std_logic'image(v)(2);
    wait for 4 ns ;

    cmd <= "01"; 
    op1 <= rand_slv(32) ;
    op2 <= rand_slv(32) ;
    report "cmd :" &to_string(cmd) ;
    report "cin : " & std_logic'image(cin)(2);
    report "op1 : " &to_string(op1) ;
    report "op2 : " &to_string(op2) ;
    report "res : " &to_string(res) ;
    report "cout : " & std_logic'image(cout)(2);
    report "z : " & std_logic'image(z)(2);
    report "n : " & std_logic'image(n)(2);
    report "v : " & std_logic'image(v)(2);
    wait for 4 ns ;
    cmd <= "10"; 
    op1 <= rand_slv(32) ;
    op2 <= rand_slv(32) ;
    report "cmd :" &to_string(cmd) ;
    report "cin : " & std_logic'image(cin)(2);
    report "op1 : " &to_string(op1) ;
    report "op2 : " &to_string(op2) ;
    report "res : " &to_string(res) ;
    report "cout : " & std_logic'image(cout)(2);
    report "z : " & std_logic'image(z)(2);
    report "n : " & std_logic'image(n)(2);
    report "v : " & std_logic'image(v)(2);
    wait for 4 ns ;
    cmd <= "11"; 
    op1 <= rand_slv(32) ;
    op2 <= rand_slv(32) ;
    report "cmd :" &to_string(cmd) ;
    report "cin : " & std_logic'image(cin)(2);
    report "op1 : " &to_string(op1) ;
    report "op2 : " &to_string(op2) ;
    report "res : " &to_string(res) ;
    report "cout : " & std_logic'image(cout)(2);
    report "z : " & std_logic'image(z)(2);
    report "n : " & std_logic'image(n)(2);
    report "v : " & std_logic'image(v)(2);
    wait for 4 ns ;
    END PROCESS tes_tb_process ;     
     

    END ARCHITECTURE ;