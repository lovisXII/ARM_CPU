LIBRARY ieee;
use ieee.std_logic_1164.all;



ENTITY fifo IS
	generic(bits : integer; slots : integer);
	PORT(
		din		: in std_logic_vector(bits-1 downto 0);
		dout		: out std_logic_vector(bits-1 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
END fifo;

architecture dataflow of fifo is
type FIFO is array (slots-1 downto 0) of std_logic_vector(bits-1 downto 0); --array of std_logic_vector (tableau de tableau quoi)
-- permet de stocker les résultats de l'ALU en attendant que MEM finisse son taf
signal fifo_d	: FIFO;
signal fifo_v	: std_logic;

begin

	process(ck)
		begin
		if rising_edge(ck) then
			-- Valid bit 
			if reset_n = '0' then
				fifo_v <= '0';
			else
				if fifo_v = '0' then
					if push = '1' then
						fifo_v <= '1';
					else
						fifo_v <= '0';
					end if;
				else
					if pop = '1' then
						if push = '1' then
							fifo_v <= '1';
						else
							fifo_v <= '0';
						end if;
					else
						fifo_v <= '1';
					end if;
				end if;
			end if;

			-- data
			if fifo_v = '0' then
				if push = '1' then
					fifo_d <= din;
				end if;
			elsif push='1' and pop='1' then
					fifo_d <= din;
			end if;
		end if;
	end process;

	full <= '1' when fifo_v = '1' and pop = '0' else '0';
	empty <= not fifo_v;
	dout <= fifo_d;

end dataflow;
