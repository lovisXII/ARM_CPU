library ieee;
use ieee.std_logic_1164.all ;


entity shift_left is
	port (cin : in std_logic_vector(31 downto 0) ;
			shift_value : in std_logic_vector(4 downto 0);
			cout : out std_logic_vector(31 downto 0);
			carry_out : out std_logic );
end entity ;


architecture behavior of shift_left is

begin
	process(cin,shift_value)
	
	variable cin_var : std_logic_vector(31 downto 0) ;

	begin
	cin_var := cin ;
	if(shift_value(0) = '1') then
		carry_out <= cin_var(31) ;
		cin_var := cin_var(30 downto 0) & '0';
	end if;
	if(shift_value(1) = '1') then
		carry_out <= cin_var(31) ;
		cin_var := cin_var(29 downto 0) & "00" ; 
	end if;
	if(shift_value(2) = '1') then
		carry_out <= cin_var(31) ;
		cin_var := cin_var(27 downto 0) & x"0" ;
	end if;
	if(shift_value(3) = '1') then
		carry_out <= cin_var(31) ;
		cin_var := cin_var(23 downto 0) & x"00" ;
	end if;
	if(shift_value(4) = '1') then
		carry_out <= cin_var(31) ;
		cin_var := cin_var(15 downto 0) & x"0000" ;
	end if;
	cout <= cin_var ;
	end process ;
end behavior ;

