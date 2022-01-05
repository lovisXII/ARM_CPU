library ieee;
use ieee.std_logic_1164.all ;


entity shift_left is
	port (din : in std_logic_vector(31 downto 0) ;
			shift_value : in std_logic_vector(4 downto 0);
			dout : out std_logic_vector(31 downto 0);
			carry_out : out std_logic;
			vdd		: in bit;
    		vss		: in bit 
    	);
end shift_left ;


architecture behavior of shift_left is
signal s1, s2, s4, s8 : std_logic_vector(31 downto 0);
begin

    s1 <= din_var(30 downto 0) & '0' when shift_value(0) = '1' else din_var;
    s2 <= s1(29 downto 0) & "00" when shift_value(1) = '1' else s1;
    s4 <= s2(27 downto 0) & x"0" when shift_value(2) = '1' else s2;
    s8 <= s4(23 downto 0) & x"00" when shift_value(3) = '1' else s4;
    dout <= s8(15 downto 0) & x"0000" when shift_value(4) = '1' else s8;
        
	process(din,shift_value)
	
	variable din_var : std_logic_vector(31 downto 0) ;
	variable carry_var : Std_Logic ;
	begin
	din_var := din ;
	carry_var := '0' ;
	if(shift_value(0) = '1') then
		carry_var := din_var(31) ;
		din_var := din_var(30 downto 0) & '0';
	end if;
	if(shift_value(1) = '1') then
		carry_var := din_var(30) ;
		din_var := din_var(29 downto 0) & "00" ; 
	end if;
	if(shift_value(2) = '1') then
		carry_var := din_var(28) ;
		din_var := din_var(27 downto 0) & x"0" ;
	end if;
	if(shift_value(3) = '1') then
		carry_var := din_var(24) ;
		din_var := din_var(23 downto 0) & x"00" ;
	end if;
	if(shift_value(4) = '1') then
		carry_var := din_var(16) ;
		din_var := din_var(15 downto 0) & x"0000" ;
	end if;
	dout <= din_var ;
	carry_out <= carry_var ;
	end process ;
end behavior ;

