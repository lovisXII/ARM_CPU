library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------PENSER A MODIFIER REG POUR QU IL  LISE ET ECRIVE EN MEME TEMPS-----------------------------------------------


entity  Reg is
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0); --port écriture data1 
		wadr1			: in Std_Logic_Vector(3 downto 0); --registre écriture data1
		wen1			: in Std_Logic; --bit enable data1, si = 1 alors on écrit

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);--port écriture data2
		wadr2			: in Std_Logic_Vector(3 downto 0);--registre écriture data2
		wen2			: in Std_Logic;--bit enable data2, si = 1 alors on écrit

	-- Write CSPR Port
		wcry			: in Std_Logic;--valeur de la retenue en écriture
		wzero			: in Std_Logic; --valeur de flag z
		wneg			: in Std_Logic;--valeur de flag n
		wovr			: in Std_Logic; --valeur de flag v
		cspr_wb		: in Std_Logic;--bit enable des flags, si = 1 alors on écrit
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); --valeur du registre lue
		radr1			: in Std_Logic_Vector(3 downto 0); -- registre lu
		reg_v1		: out Std_Logic; --bit de validité du registre lu, que l'on envoie à l'étage décode pour analyse

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0); --valeur du registre lue
		radr2			: in Std_Logic_Vector(3 downto 0);-- registre lu
		reg_v2		: out Std_Logic;--bit de validité du registre lu, que l'on envoie à l'étage décode pour analyse

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- Read Port 4 5 bits
		reg_rd4		: out Std_Logic_Vector(4 downto 0);
		radr4			: in Std_Logic_Vector(3 downto 0);
		reg_v4		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic; --valeur des flags lues
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic; --bit de validité de c,z et n
		reg_ovr		: out Std_Logic; --valeur de l'overflow
		reg_vv		: out Std_Logic;--bit de validité de l'overflow
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0); --registres invalidé par decode, donc impossible d'écrire dedans
		inval1		: in Std_Logic; --valeur du bit de validité

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic; -- port de validité de pc
		inc_pc		: in Std_Logic; -- si = '1' on incremente pc normalement, sinon on lui ajoute l'offset d'un branch
	
	-- global interface
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
	type Registres is array (15 downto 0) of std_logic_vector(31 downto 0);
	type Bits is array (15 downto 0) of std_logic;
	signal c, ovr, z, n, czn_valid, ovr_valid : std_logic;
	signal	regs : Registres;
	signal  bits_valid : Bits;
	-- on ne peut pas assigner à un même signal depuis deux process
	begin

		write_regs: process(wen1, wen2, wadr1, wadr2, cspr_wb, wcry, wovr, wzero, wneg, wdata1, wdata2, reset_n)
			variable index : integer;
			variable pc_int: integer;
			begin
				if reset_n = '1' then
					-- Write to register 
					-- Le calcul de pc est fait par l'étage exec, dans le cas d'un branchement la nouvelle adresse de pc est contenue dans wdata1
					-- le registre écrit aura donc la valeur 15 (i.e. index = 15)

					--Si le bit de validité en écriture vaut '1' alors on propage la donnée
					if wen2 = '1' then 
						index := to_integer(unsigned(wadr2));
						regs(index) <= wdata2;
						bits_valid(index) <= '1';
					end if;

					if wen1 = '1' then 
						index := to_integer(unsigned(wadr1));
						regs(index) <= wdata1;
						bits_valid(index) <= '1';
					end if;

					--Maj flags
					
					if cspr_wb = '1' then 
						c <= wcry;
						ovr <= wovr; 
						z <= wzero; 
						n <= wneg;
					end if;
					
					--PC est par défaut incrémenter à chaque cycle d'horloge
					
					if rising_edge(ck) then
						pc_int := to_integer(unsigned(regs(15)));
						if inc_pc = '0' then 
							pc_int := pc_int + 4;
						end if;
						regs(15) <= std_logic_vector(to_unsigned(pc_int, 32));
						reg_pc <= std_logic_vector(to_unsigned(pc_int, 32));
						reg_pcv <= bits_valid(15);
					end if;	
				
				else --cas où reset_n = '0'
					czn_valid <= '0';
					ovr_valid <= '0';
				end if;
		end process write_regs;


		read_regs: 	process(radr1, radr2, radr3, c, z, n, ovr, czn_valid, ovr_valid, regs, bits_valid,  reset_n)
			variable index : integer;
			begin
				if reset_n = '1' then
					-- Read registers
					index := to_integer(unsigned(radr1));
					reg_rd1 <= regs(index);
					reg_v1 <= bits_valid(index);
					
					index := to_integer(unsigned(radr2));
					reg_rd2 <= regs(index);
					reg_v2 <= bits_valid(index);
					
					index := to_integer(unsigned(radr3));
					reg_rd3 <= regs(index);
					reg_v3 <= bits_valid(index);

					index := to_integer(unsigned(radr4));
					reg_rd4 <= regs(index)(4 downto 0);
					reg_v4 <= bits_valid(index);
					--read flags
					reg_cry <= c; 
					reg_zero <= z;
					reg_neg <= n; 
					reg_ovr <= ovr; 
					reg_cznv <= czn_valid;
					reg_vv <= ovr_valid;

				end if;
		end process read_regs;

		--Invalidation des registres par DEC
		-- ex : ADD r0,r1,r2
		-- On invalide r0 à l'étage decode et à la fin de l'étage exe on écrit dans r0 et ainsi on le revalide
		invalid_regs: process(inval_adr1, inval1, inval_adr2, inval2, inval_ovr, inval_czn, reset_n)
			variable index : integer;
			begin
				if reset_n = '1' then
					if inval1 = '0' then 
						index := to_integer(unsigned(inval_adr1));
						bits_valid(index) <=	'0';			
					end if; 
					if inval2 = '0' then 
						index := to_integer(unsigned(inval_adr2));
						bits_valid(index) <=	'0';			
					end if; 

					if inval_czn = '0' then 
						czn_valid <= '0'; 
					end if; 

					if inval_ovr = '0' then 
						ovr_valid <= '0';
					end if;  
				end if;
		end process invalid_regs;


		--print_regs: process(regs)
		--function to_string ( a: std_logic_vector) return string is
	 --     variable b : string (1 to a'length) := (others => NUL);
	 --     variable stri : integer := 1; 
	 --   begin
	 --     for i in a'range loop
	 --         b(stri) := std_logic'image(a((i)))(2);  
	 --     stri := stri+1;
	 --     end loop;
	 --   return b;
	 --   end function;
		--begin 
		--	for i in 0 to 15 loop
		--		report "regs" & integer'image(i) & " : " & to_string(regs(i));
		--	end loop;

		--end process; 

end Behavior;
