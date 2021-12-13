----------
--shifter
----------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL ;
USE IEEE.MATH_REAL.ALL ;

ENTITY ror_entity IS
	PORT(
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic;
    vdd       : IN bit ;
    vss       : IN bit);
    -- global interface	
END ror_entity;

ARCHITECTURE behavior OF ror_entity IS

BEGIN
    ror_process: PROCESS(shift_val, din, cin)
    variable internal_shift : Std_Logic_Vector(31 downto 0);
    variable internal_carry : Std_Logic;
    BEGIN
        internal_shift := din;
        internal_carry := cin;
        if shift_val(0) = '1' then
            internal_carry := internal_shift(0);
            internal_shift := internal_shift(0) & internal_shift(31 downto 1);
        end if;
        if shift_val(1) = '1' then
            internal_carry := internal_shift(1);
            internal_shift := internal_shift(1 downto 0) & internal_shift(31 downto 2);
        end if;
        if shift_val(2) = '1' then
            internal_carry := internal_shift(3);
            internal_shift := internal_shift(3 downto 0) & internal_shift(31 downto 4);
        end if;
        if shift_val(3) = '1' then
            internal_carry := internal_shift(7);
            internal_shift := internal_shift(7 downto 0) & internal_shift(31 downto 8);
        end if;
        if shift_val(4) = '1' then
            internal_carry := internal_shift(15);
            internal_shift := internal_shift(15 downto 0) & internal_shift(31 downto 16);
        end if;
        if (shift_val = "00000") then 
        	internal_carry := internal_shift(0) ;
        	internal_shift := cin & internal_shift (31 downto 1) ; 
        end if;    
        cout <= internal_carry;
        dout <= internal_shift;
    END PROCESS;
END behavior ;