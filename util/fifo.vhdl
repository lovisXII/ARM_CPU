LIBRARY ieee;
use ieee.std_logic_1164.all;

<<<<<<< HEAD

ENTITY fifo IS
	generic(bits : integer; slots : integer); -- slots >= 2
	PORT(
		din		: in std_logic_vector(bits-1 downto 0);
		dout		: out std_logic_vector(bits-1 downto 0);
=======
ENTITY fifo IS
	generic  (width : integer);
	PORT(
		din		: in std_logic_vector(width -1 downto 0);
		dout		: out std_logic_vector(width -1 downto 0);
>>>>>>> 0e3d4e499f39a6d7ea47210960b3160360cf2311

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
<<<<<<< HEAD
type FIFO_REGISTERS is array (slots-1 downto 0) of std_logic_vector(bits-1 downto 0); --array of std_logic_vector (tableau de tableau quoi)
-- permet de stocker les résultats de l'ALU en attendant que MEM finisse son taf
signal fifo_d	: FIFO_REGISTERS;
signal fifo_w	: std_logic_vector(slots-1 downto 0);
signal fifo_r	: std_logic_vector(slots-1 downto 0);
signal fifo_empty	: std_logic;
signal fifo_full	: std_logic;
begin

	process(ck)
		function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
			-- pragma subpgm_id 401
			variable result: STD_LOGIC;
			begin
			result := '0';
			for i in ARG'range loop
				result := result or ARG(i);
			end loop;
				return result;
			end;
		begin
		if rising_edge(ck) then
			-- Gestion des flags
			if reset_n = '0' then
				fifo_empty <= '1';
				fifo_full <= '0';
				fifo_w <= (0 => '1',
						   others => '0');
				fifo_r <= (0 => '1', 
						   others => '0');
			else
				--fifo is not empty if
				-- *cursors are not at the same register or
				-- *we just pushed (we cant push + pop when the fifo is empty) 
				-- *we did nothing and the fifo was not empty
				fifo_empty <= or_reduce(fifo_w and fifo_r) and not push and not fifo_full;
				fifo_full <= or_reduce(fifo_w and fifo_r) and not fifo_empty and (push or not pop);
				if push = '1' then
					for i in 0 to slots-2 loop
						fifo_w(i+1) <= fifo_w(i);
					end loop;
						fifo_w(0) <= fifo_w(slots-1);
				end if;
				if fifo_empty = '0' then
					if pop = '1' then
						for i in 0 to slots-2 loop
							fifo_r(i+1) <= fifo_r(i);
						end loop;
							fifo_r(0) <= fifo_r(slots-1);
=======

signal fifo_d	: std_logic_vector(width -1 downto 0);
signal fifo_v	: std_logic;

-- 	une fifo est pleine quand :
--	elle est valide et qu'on ne pop pas 
--	On considère qu'une fifo est valide quand il y a de la donnée et que l'on sait quelle est cette donnée

begin

	process(ck)
		begin
		if rising_edge(ck) then
			-- Valid bit
			if reset_n = '0' then -- reset la fifo => on la rend invalide
				fifo_v <= '0';
			else
			--quand y a de la merde dans la fifo, ie quand fifo_v = '0' ie qu'on ne compte pas utilisé ce qu'il y a dedans
				
				if fifo_v = '0' then -- si la fifo n'est aps valide et que push = 1
				
					if push = '1' then -- si on push la fifo devient valide
						fifo_v <= '1'; -- elle devient valide
					else
						fifo_v <= '0';
					end if;
				else --quand la fifo est valide ie qu'on sait et on utilise ce qu'il y a dedans
					if pop = '1' then
						if push = '1' then
							fifo_v <= '1';
						else
							fifo_v <= '0';
						end if;
					else
						fifo_v <= '1';
>>>>>>> 0e3d4e499f39a6d7ea47210960b3160360cf2311
					end if;
				end if;
			end if;

			-- data
<<<<<<< HEAD
			if pop = '1' then
				for i in 0 to slots-1 loop 
					if fifo_r(i) = '1' then
						dout <= fifo_d(i);
					end if;
				end loop;
			end if;
			if push = '1' then
				for i in 0 to slots-1 loop 
					if fifo_w(i) = '1' then
						fifo_d(i) <= din;
					end if;
				end loop;
			end if;
		end if;
	end process;
	empty <= fifo_empty;
	full <=  fifo_full;
=======
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
>>>>>>> 0e3d4e499f39a6d7ea47210960b3160360cf2311

end dataflow;
