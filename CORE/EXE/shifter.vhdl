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
    signal out_shift_left, out_shift_right, out_shift_ror : std_logic_vector(31 downto 0) ;
    signal carry_out_left, carry_out_right, carry_out_ror : std_logic ;


    component shift_left
    port (
    din :               in std_logic_vector(31 downto 0) ;
    shift_value :       in std_logic_vector(4 downto 0);
    dout :              out std_logic_vector(31 downto 0);
    carry_out :         out std_logic ;
    vdd		: in bit;
    vss		: in bit 
    );
    
    end component ;

    component shift_right 
    PORT(
    arithmetic: IN Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    vdd		: in bit ;
    vss		: in bit ;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic
    );    
    end component ;

    component ror_entity
    PORT(
    shift_val : IN  Std_Logic_Vector(4 downto 0) ;
    din       : IN  Std_Logic_Vector(31 downto 0);  
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); 
    cout      : OUT Std_Logic ;
    vdd		: in bit;
    vss		: in bit );
    end component ;

BEGIN

    shift_left0 : shift_left port map
    (
     din => din , 
     shift_value => shift_val, 
     dout => out_shift_left, 
     carry_out => carry_out_left,
     vdd => vdd, 
     vss => vss
     );    

    shift_right0 : shift_right port map
    (
     arithmetic => shift_asr ,
     din => din , 
     cin => cin ,
     shift_val => shift_val, 
     dout => out_shift_right, 
     cout => carry_out_right,
     vdd => vdd, 
     vss => vss
     );    

    shift_ror0 : ror_entity port map
    (
     din => din , 
     cin => cin ,
     shift_val => shift_val, 
     dout => out_shift_ror, 
     cout => carry_out_ror,
     vdd => vdd, 
     vss => vss
     );   




shifter_process_1 :PROCESS(out_shift_ror,out_shift_left,out_shift_right, shift_lsl,shift_lsr,shift_ror, shift_asr)
    begin
    IF(shift_lsl = '1') THEN
            dout <= out_shift_left ;
            cout <= carry_out_left ;
    ELSIF (shift_lsr = '1' or shift_asr = '1') THEN
            dout <= out_shift_right ;
            cout <= carry_out_right ;
    ELSIF (shift_ror = '1') THEN
            dout <= out_shift_ror ;
            cout <= carry_out_ror ;
    ELSE
            dout <= din;
            cout <= cin;
    END IF ;
END PROCESS shifter_process_1 ;
END behavior ;