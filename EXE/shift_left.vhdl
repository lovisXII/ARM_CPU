library ieee;
use ieee.std_logic_1164.all ;


entity shift_left is
	port (din : in std_logic_vector(31 downto 0) ;
			shift_value : in std_logic_vector(4 downto 0);
			dout : out std_logic_vector(31 downto 0);
			carry_out : out std_logic;
			vdd       : IN bit;
    		vss       : IN bit 
    	);
end entity ;


architecture behavior of shift_left is

begin
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

