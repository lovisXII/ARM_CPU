LIBRARY ieee;
use ieee.std_logic_1164.all;

ENTITY one_hot IS
	PORT(
		adr		: in  std_logic_vector(3 downto 0);
        en      : in std_logic;
		adr_oh  : out std_logic_vector(15 downto 0)
	);
END one_hot;

architecture behavior of one_hot is

begin

	process(adr, en)
        variable oh_var : std_logic_vector(15 downto 0);
		begin
            oh_var := X"0000";
            if en = '1' then 	
                if adr = "0000" then
                    oh_var(0) := '1';
                end if;
                if adr = "0001" then
                    oh_var(1) := '1';
                end if;
                if adr = "0010" then
                    oh_var(2) := '1';
                end if;
                if adr = "0011" then
                    oh_var(3) := '1';
                end if;
                if adr = "0100" then
                    oh_var(4) := '1';
                end if;
                if adr = "0101" then
                    oh_var(5) := '1';
                end if;
                if adr = "0110" then
                    oh_var(6) := '1';
                end if;
                if adr = "0111" then
                    oh_var(7) := '1';
                end if;
                if adr = "1000" then
                    oh_var(8) := '1';
                end if;
                if adr = "1001" then
                    oh_var(9) := '1';
                end if;
                if adr = "1010" then
                    oh_var(10) := '1';
                end if;
                if adr = "1011" then
                    oh_var(11) := '1';
                end if;
                if adr = "1100" then
                    oh_var(12) := '1';
                end if;
                if adr = "1101" then
                    oh_var(13) := '1';
                end if;
                if adr = "1110" then
                    oh_var(14) := '1';
                end if;
                if adr = "1111" then
                    oh_var(15) := '1';
                end if;
            end if;
            adr_oh <= oh_var;
	end process;

end behavior;
