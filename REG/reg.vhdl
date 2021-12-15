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
	signal c, ovr, z, n, czn_valid, ovr_valid : std_logic;
	signal	regs : Registres;
	signal  bits_valid : std_logic_vector(15 downto 0);

    signal wadr1_oh : std_logic_vector(15 downto 0);
    signal wadr2_oh : std_logic_vector(15 downto 0);
    signal inval_adr1_oh : std_logic_vector(15 downto 0);
    signal inval_adr2_oh : std_logic_vector(15 downto 0);

    component one_hot
    port(
        adr: in std_logic_vector(3 downto 0);
        en:  in std_logic;
        adr_oh: out std_logic_vector(15 downto 0)
    );
    end component;
	-- on ne peut pas assigner à un même signal depuis deux process
	begin
        wadr1_oh_map: one_hot port map (
            adr => wadr1,
            en => wen1,
            adr_oh => wadr1_oh);
        wadr2_oh_map: one_hot port map (
            adr => wadr2,
            en => wen2,
            adr_oh => wadr2_oh);
        inval_wadr1_oh_map: one_hot port map (
            adr => inval_adr1,
            en => inval1,
            adr_oh => inval_adr1_oh);
        inval_wadr2_oh_map: one_hot port map (
            adr => inval_adr2,
            en => inval2,
            adr_oh => inval_adr2_oh);

		write_regs: process(ck, reset_n)

            

			variable index : integer;
			variable pc_int: integer;
            variable regs_var: Registres;
            variable valid_var: std_logic_vector(15 downto 0);
            variable czn_valid_var, ovr_valid_var: std_logic;

			begin
                if rising_edge(ck) then
                    if reset_n = '0' then
                        regs(0) <= X"00000000";
                        regs(1) <= X"00000000";
                        regs(2) <= X"00000000";
                        regs(3) <= X"00000000";
                        regs(4) <= X"00000000";
                        regs(5) <= X"00000000";
                        regs(6) <= X"00000000";
                        regs(7) <= X"00000000";
                        regs(8) <= X"00000000";
                        regs(9) <= X"00000000";
                        regs(10) <= X"00000000";
                        regs(11) <= X"00000000";
                        regs(12) <= X"00000000";
                        regs(13) <= X"00000000";
                        regs(14) <= X"00000000";
                        regs(15) <= X"00000000";
                        czn_valid <= '0';
                        ovr_valid <= '0';
                        bits_valid <= X"0000";
                    else
                        -- Write to register 
                    -- Le calcul de pc est fait par l'étage exec, dans le cas d'un branchement la nouvelle adresse de pc est contenue dans wdata1
                    -- le registre écrit aura donc la valeur 15 (i.e. index = 15)

                    --Si le bit de validité en écriture vaut '1' alors on propage la donnée

                    regs_var := regs;
                    valid_var := bits_valid;

                    if wadr1_oh(0) = '1' then
                        regs_var(0) := wdata1;
                        valid_var(0) := '1';
                    elsif wadr2_oh(0) = '1' then
                        regs_var(0) := wdata2;
                        valid_var(0) := '1';
                    end if;
                    if wadr1_oh(1) = '1' then
                        regs_var(1) := wdata1;
                        valid_var(1) := '1';
                    elsif wadr2_oh(1) = '1' then
                        regs_var(1) := wdata2;
                        valid_var(1) := '1';
                    end if;
                    if wadr1_oh(2) = '1' then
                        regs_var(2) := wdata1;
                        valid_var(2) := '1';
                    elsif wadr2_oh(2) = '1' then
                        regs_var(2) := wdata2;
                        valid_var(2) := '1';
                    end if;
                    if wadr1_oh(3) = '1' then
                        regs_var(3) := wdata1;
                        valid_var(3) := '1';
                    elsif wadr2_oh(3) = '1' then
                        regs_var(3) := wdata2;
                        valid_var(3) := '1';
                    end if;
                    if wadr1_oh(4) = '1' then
                        regs_var(4) := wdata1;
                        valid_var(4) := '1';
                    elsif wadr2_oh(4) = '1' then
                        regs_var(4) := wdata2;
                        valid_var(4) := '1';
                    end if;
                    if wadr1_oh(5) = '1' then
                        regs_var(5) := wdata1;
                        valid_var(5) := '1';
                    elsif wadr2_oh(5) = '1' then
                        regs_var(5) := wdata2;
                        valid_var(5) := '1';
                    end if;
                    if wadr1_oh(6) = '1' then
                        regs_var(6) := wdata1;
                        valid_var(6) := '1';
                    elsif wadr2_oh(6) = '1' then
                        regs_var(6) := wdata2;
                        valid_var(6) := '1';
                    end if;
                    if wadr1_oh(7) = '1' then
                        regs_var(7) := wdata1;
                        valid_var(7) := '1';
                    elsif wadr2_oh(7) = '1' then
                        regs_var(7) := wdata2;
                        valid_var(7) := '1';
                    end if;
                    if wadr1_oh(8) = '1' then
                        regs_var(8) := wdata1;
                        valid_var(8) := '1';
                    elsif wadr2_oh(8) = '1' then
                        regs_var(8) := wdata2;
                        valid_var(8) := '1';
                    end if;
                    if wadr1_oh(9) = '1' then
                        regs_var(9) := wdata1;
                        valid_var(9) := '1';
                    elsif wadr2_oh(9) = '1' then
                        regs_var(9) := wdata2;
                        valid_var(9) := '1';
                    end if;
                    if wadr1_oh(10) = '1' then
                        regs_var(10) := wdata1;
                        valid_var(10) := '1';
                    elsif wadr2_oh(10) = '1' then
                        regs_var(10) := wdata2;
                        valid_var(10) := '1';
                    end if;
                    if wadr1_oh(11) = '1' then
                        regs_var(11) := wdata1;
                        valid_var(11) := '1';
                    elsif wadr2_oh(11) = '1' then
                        regs_var(11) := wdata2;
                        valid_var(11) := '1';
                    end if;
                    if wadr1_oh(12) = '1' then
                        regs_var(12) := wdata1;
                        valid_var(12) := '1';
                    elsif wadr2_oh(12) = '1' then
                        regs_var(12) := wdata2;
                        valid_var(12) := '1';
                    end if;
                    if wadr1_oh(13) = '1' then
                        regs_var(13) := wdata1;
                        valid_var(13) := '1';
                    elsif wadr2_oh(13) = '1' then
                        regs_var(13) := wdata2;
                        valid_var(13) := '1';
                    end if;
                    if wadr1_oh(14) = '1' then
                        regs_var(14) := wdata1;
                        valid_var(14) := '1';
                    elsif wadr2_oh(14) = '1' then
                        regs_var(14) := wdata2;
                        valid_var(14) := '1';
                    end if;
                    if wadr1_oh(15) = '1' then
                        regs_var(15) := wdata1;
                        valid_var(15) := '1';
                    elsif wadr2_oh(15) = '1' then
                        regs_var(15) := wdata2;
                        valid_var(15) := '1';
                    end if;

                    if inval_adr1_oh(0) = '1' or inval_adr2_oh(0) = '1' then
                        valid_var(0) := '0';
                    end if;
                    if inval_adr1_oh(1) = '1' or inval_adr2_oh(1) = '1' then
                        valid_var(1) := '0';
                    end if;
                    if inval_adr1_oh(2) = '1' or inval_adr2_oh(2) = '1' then
                        valid_var(2) := '0';
                    end if;
                    if inval_adr1_oh(3) = '1' or inval_adr2_oh(3) = '1' then
                        valid_var(3) := '0';
                    end if;
                    if inval_adr1_oh(4) = '1' or inval_adr2_oh(4) = '1' then
                        valid_var(4) := '0';
                    end if;
                    if inval_adr1_oh(5) = '1' or inval_adr2_oh(5) = '1' then
                        valid_var(5) := '0';
                    end if;
                    if inval_adr1_oh(6) = '1' or inval_adr2_oh(6) = '1' then
                        valid_var(6) := '0';
                    end if;
                    if inval_adr1_oh(7) = '1' or inval_adr2_oh(7) = '1' then
                        valid_var(7) := '0';
                    end if;
                    if inval_adr1_oh(8) = '1' or inval_adr2_oh(8) = '1' then
                        valid_var(8) := '0';
                    end if;
                    if inval_adr1_oh(9) = '1' or inval_adr2_oh(9) = '1' then
                        valid_var(9) := '0';
                    end if;
                    if inval_adr1_oh(10) = '1' or inval_adr2_oh(10) = '1' then
                        valid_var(10) := '0';
                    end if;
                    if inval_adr1_oh(11) = '1' or inval_adr2_oh(11) = '1' then
                        valid_var(11) := '0';
                    end if;
                    if inval_adr1_oh(12) = '1' or inval_adr2_oh(12) = '1' then
                        valid_var(12) := '0';
                    end if;
                    if inval_adr1_oh(13) = '1' or inval_adr2_oh(13) = '1' then
                        valid_var(13) := '0';
                    end if;
                    if inval_adr1_oh(14) = '1' or inval_adr2_oh(14) = '1' then
                        valid_var(14) := '0';
                    end if;
                    if inval_adr1_oh(15) = '1' or inval_adr2_oh(15) = '1' then
                        valid_var(15) := '0';
                    end if;
                        

                    --Maj flags
                    czn_valid_var := czn_valid;
                    ovr_valid_var := ovr_valid;
                    if cspr_wb = '1' then 
                        c <= wcry;
                        ovr <= wovr; 
                        z <= wzero; 
                        n <= wneg;
                        czn_valid_var := '1';
                        ovr_valid_var := '1';
                    end if; 
                    
                    if inval_czn = '1' then
                        czn_valid_var := '0';
                    end if;
                    if inval_ovr = '1' then
                        ovr_valid_var := '0';
                    end if;

                    czn_valid <= czn_valid_var;
                    ovr_valid <= ovr_valid_var;
                    -- --PC est par défaut incrémenté à chaque cycle d'horloge
                    

                    reg_pc <= regs_var(15);
                    reg_pcv <= valid_var(15);
                    regs <= regs_var;
                    bits_valid <= valid_var;
                    czn_valid <= czn_valid_var;
                    ovr_valid <= ovr_valid_var;
                    if inc_pc = '0' then 
                        pc_int := to_integer(unsigned(regs(15)));
                        pc_int := pc_int + 4;
                        regs(15) <= std_logic_vector(to_unsigned(pc_int, 32));
                    end if;
                    end if;
                end if;
		end process write_regs;

		read_regs: 	process(radr1, radr2, radr3, radr4, c, z, n, ovr, czn_valid, ovr_valid, regs, bits_valid)
			variable index : integer;
            variable reg_rd4_full : std_logic_vector(31 downto 0);
			begin
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
                reg_rd4_full := regs(index);
                reg_rd4 <= reg_rd4_full(4 downto 0);
                reg_v4 <= bits_valid(index);
                --read flags
                reg_cry <= c; 
                reg_zero <= z;
                reg_neg <= n; 
                reg_ovr <= ovr; 
                reg_cznv <= czn_valid;
                reg_vv <= ovr_valid;
		end process read_regs;

		--Invalidation des registres par DEC
		-- ex : ADD r0,r1,r2
		-- On invalide r0 à l'étage decode et à la fin de l'étage exe on écrit dans r0 et ainsi on le revalide


	-- 	print_regs: process(regs)
	-- 	function to_string ( a: std_logic_vector) return string is
	--      variable b : string (1 to a'length) := (others => NUL);
	--      variable stri : integer := 1; 
	--    begin
	--      for i in a'range loop
	--          b(stri) := std_logic'image(a((i)))(2);  
	--      stri := stri+1;
	--      end loop;
	--    return b;
	--    end function;
	-- 	begin 
	-- 		for i in 0 to 15 loop
	-- 			report "regs" & integer'image(i) & " : " & to_string(regs(i));
	-- 		end loop;
    --             report "wadr1" & " : " & to_string(wadr1_oh);
    --             report "wadr2" & " : " & to_string(wadr2_oh);

	-- 	end process; 

end Behavior;
