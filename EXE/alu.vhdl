----------
--ALU 
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;

ENTITY ALU IS
  PORT( op1  : in  Std_Logic_Vector(31 downto 0);
         op2  : in  Std_Logic_Vector(31 downto 0);
         cin  : in  Std_Logic;
         cmd  : in  Std_Logic_Vector(1 downto 0);
         res  : out Std_Logic_Vector(31 downto 0);
         cout : out Std_Logic;
         z    : out Std_Logic;
         n    : out Std_Logic;
         v    : out Std_Logic;
         vdd  : in  bit;
         vss  : in  bit);
END ALU ;

ARCHITECTURE BEHAVIOR of ALU IS
  BEGIN
  PROCESS1 : PROCESS(op1,op2,cin)
                VARIABLE res_var : std_logic_vector(31 downto 0) ;
                VARIABLE res_add : std_logic_vector(32 downto 0) ; 
                BEGIN
                -- --Les flags beuguent, il faudra les corriger
                
                res_add := STD_LOGIC_VECTOR('0' & SIGNED(op1) + ('0' & SIGNED(op2))) ;

                -- CASE cmd IS
                --   WHEN "00" =>  res_var := res_add(31 downto 0) ;
                --                 cout <= res_add(32) ;
                --   WHEN "01" => res_var := STD_LOGIC_VECTOR(SIGNED(op1) and SIGNED(op2)) ;
                --   WHEN "10" => res_var := STD_LOGIC_VECTOR(SIGNED(op1) or SIGNED(op2)) ;
                --   WHEN "11" => res_var := STD_LOGIC_VECTOR(SIGNED(op1) xor SIGNED(op2)) ;
                --   WHEN OTHERS => res_add := X"00000000";
                -- END CASE ;

                if cmd(0) = '0' and cmd(1) = '0' then
                    res_var := res_add(31 downto 0);
                    cout <= res_add(32);
                elsif cmd(0) = '0' and cmd(1) = '1' then
                    res_var := op1 and op2;
                    cout <= cin;
                elsif cmd(0) = '1' and cmd(1) = '0' then
                    res_var := op1 or op2;
                    cout <= cin;
                elsif cmd(0) = '1' and cmd(1) = '1' then
                    res_var := op1 xor op2;
                    cout <= cin;
                end if;
                
                IF res_var = X"00000000" THEN 
                  z <= '1' ;
                ELSE
                  z <= '0' ;
                END IF ;

                IF res_add(32) = '1' THEN 
                  v <= '1' ;
                ELSE
                  v <= '0' ;
                END IF ;

                IF res_var(31) = '1' THEN 
                  n <= '1' ;
                ELSE
                  n <= '0' ;
                END IF ;

                res <= res_var; 
  END PROCESS PROCESS1 ;
  END BEHAVIOR ;


