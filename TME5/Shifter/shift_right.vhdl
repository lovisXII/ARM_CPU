----------
--shifter
----------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL ;
USE IEEE.MATH_REAL.ALL ;

ENTITY Shift_right IS
	PORT(
    arithmetic: IN Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic;
    -- global interface
    vdd       : IN  bit;
    vss       : IN  bit );
END Shift_right;

ARCHITECTURE behavior OF Shift_right IS

BEGIN
    shift_right_process: PROCESS(arithmetic, shift_val, din, cin)
    variable internal_shift : Std_Logic_Vector(31 downto 0);
    variable internal_carry : Std_Logic;
    variable start_bit : std_logic;
    variable start_2 : std_logic_vector(1 downto 0);
    variable start_4 : std_logic_vector(3 downto 0);
    variable start_8 : std_logic_vector(7 downto 0);
    variable start_16 : std_logic_vector(15 downto 0);
    BEGIN
        start_bit := arithmetic and din(31);
        start_2 := (others => start_bit);
        start_4 := (others => start_bit);
        start_8 := (others => start_bit);
        start_16 := (others => start_bit);
        internal_shift := din;
        internal_carry := cin;
        if shift_val(0) = '1' then
            internal_carry := internal_shift(0);
            internal_shift := start_bit & internal_shift(31 downto 1);
        end if;
        if shift_val(1) = '1' then
            internal_carry := internal_shift(1);
            internal_shift := start_2 & internal_shift(31 downto 2);
        end if;
        if shift_val(2) = '1' then
            internal_carry := internal_shift(3);
            internal_shift := start_4 & internal_shift(31 downto 4);
        end if;
        if shift_val(3) = '1' then
            internal_carry := internal_shift(7);
            internal_shift := start_8 & internal_shift(31 downto 8);
        end if;
        if shift_val(4) = '1' then
            internal_carry := internal_shift(15);
            internal_shift := start_16 & internal_shift(31 downto 16);
        end if;
        cout <= internal_carry;
        dout <= internal_shift;
    END PROCESS;
END ARCHITECTURE ;