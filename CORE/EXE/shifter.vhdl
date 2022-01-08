----------
--shifter
----------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY Shifter IS
	PORT(
    shift_lsl : IN  Std_Logic;-- permet de dire quel type de shift on effectue
    shift_lsr : IN  Std_Logic;
    shift_asr : IN  Std_Logic;
    shift_ror : IN  Std_Logic;
    shift_rrx : IN  Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    vdd		: in bit;
    vss		: in bit;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic);
END Shifter;

ARCHITECTURE behavior OF Shifter IS
    signal lsl1, lsl2, lsl4, lsl8, lsl16 : std_logic_vector(32 downto 0) ;
    signal lsr1, lsr2, lsr4, lsr8, lsr16 : std_logic_vector(32 downto 0) ;
    signal asr1, asr2, asr4, asr8, asr16 : std_logic_vector(32 downto 0) ;
    signal ror1, ror2, ror4, ror8, ror16 : std_logic_vector(31 downto 0) ;

BEGIN 


lsl1 <= din(31 downto 0) & '0' when shift_val(0) = '1' else cin & din;
lsl2 <= lsl1(30 downto 0) & "00" when shift_val(1) = '1' else lsl1;
lsl4 <= lsl2(28 downto 0) & x"0" when shift_val(2) = '1' else lsl2;
lsl8 <= lsl4(24 downto 0) & x"00" when shift_val(3) = '1' else lsl4;
lsl16 <= lsl8(16 downto 0) & x"0000" when shift_val(4) = '1' else lsl8;


lsr1 <= '0' & din(31 downto 0)  when shift_val(0) = '1' else din & cin;
lsr2 <= "00" & lsr1(32 downto 2)  when shift_val(1) = '1' else lsr1;
lsr4 <= x"0" & lsr2(32 downto 4)  when shift_val(2) = '1' else lsr2;
lsr8 <= x"00" & lsr4(32 downto 8)  when shift_val(3) = '1' else lsr4;
lsr16 <= x"0000" & lsr8(32 downto 16)  when shift_val(4) = '1' else lsr8;


asr1 <= '1' & din(31 downto 0)  when shift_val(0) = '1' else din & cin;
asr2 <= "11" & asr1(32 downto 2)  when shift_val(1) = '1' else asr1;
asr4 <= x"F" & asr2(32 downto 4)  when shift_val(2) = '1' else asr2;
asr8 <= x"FF" & asr4(32 downto 8)  when shift_val(3) = '1' else asr4;
asr16 <= x"FFFF" & asr8(32 downto 16)  when shift_val(4) = '1' else asr8;

--have to do ror like that or it doen't synthetise 
--(due to a bug in boom, probably some kind of recursion loop, 
--or a pathologic case for some algorithm, as memory usage climbs until the process is killed.)
ror2 <= din(0) & din(31 downto 1)           when shift_val(1 downto 0) = "01" else 
        din(1 downto 0) & din(31 downto 2)  when shift_val(1 downto 0) = "10" else 
        din(2 downto 0) & din(31 downto 3)  when shift_val(1 downto 0) = "11" else 
        din;
ror16 <=    ror2(3 downto 0)    & ror2(31 downto 4)     when shift_val(4 downto 2) = "001" else 
            ror2(7 downto 0)    & ror2(31 downto 8)     when shift_val(4 downto 2) = "010" else 
            ror2(11 downto 0)   & ror2(31 downto 12)    when shift_val(4 downto 2) = "011" else 
            ror2(15 downto 0)   & ror2(31 downto 16)    when shift_val(4 downto 2) = "100" else 
            ror2(19 downto 0)   & ror2(31 downto 20)    when shift_val(4 downto 2) = "101" else 
            ror2(23 downto 0)   & ror2(31 downto 24)    when shift_val(4 downto 2) = "110" else 
            ror2(27 downto 0)   & ror2(31 downto 28)    when shift_val(4 downto 2) = "111" else 
            cin & din(31 downto 1) when shift_val = "00000" else
            ror2;   

dout <= lsl16(31 downto 0)     when shift_lsl = '1' else
        lsr16(32 downto 1)     when shift_lsr = '1' or (shift_asr = '1' and din(0) = '0') else
        asr16(32 downto 1)     when (shift_asr = '1' and din(0) = '1') else
        ror16     when shift_ror = '1' else
        X"00000000";
cout <= lsl16(32)     when shift_lsl = '1' else
        lsr16(0)      when shift_lsr = '1' or (shift_asr = '1' and din(0) = '0') else
        asr16(0)      when (shift_asr = '1' and din(0) = '1') else
        ror16(31)     when shift_ror = '1' and shift_val /= "00000" else
        din(0)        when shift_ror = '1' and shift_val = "00000" else
        '0';
END behavior ;