----------
--MUX21 
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;

ENTITY MUX21 IS
  generic (n : integer);
  PORT( op1: in std_logic_vector(n-1 downto 0);
        op2: in std_logic_vector(n-1 downto 0);
        cmd: in std_logic;
        res: out std_logic_vector(n-1 downto 0)
    );
END ENTITY ;

ARCHITECTURE BEHAVIOR of MUX21 IS
  BEGIN
  PROCESS1 : PROCESS(op1,op2,cmd)
  begin
      if cmd = '0' then 
        res <= op1;
      else 
        res <= op2;
      end if;        
  END PROCESS PROCESS1 ;
  END ARCHITECTURE ;