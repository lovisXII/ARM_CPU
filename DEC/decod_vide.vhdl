library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--On ne traitera pas les transferts multiples pour le moment, a voir a la fin


entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0); -- @ of MEM
			dec_pre_index 	: out Std_logic; -- say if we do pre index or no []!

			dec_mem_lw		: out Std_Logic; -- type of memory access
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic; --meme signaux que dans exe
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic; --fifo en entree dec/exe
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_add		: out Std_Logic;
			dec_alu_and		: out Std_Logic;
			dec_alu_or		: out Std_Logic;
			dec_alu_xor		: out Std_Logic;

	-- Exe Write Back to reg
			exe_res				: in Std_Logic_Vector(31 downto 0);

			exe_c				: in Std_Logic;
			exe_v				: in Std_Logic;
			exe_n				: in Std_Logic;
			exe_z				: in Std_Logic;

			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir				: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro : fifo dec2if et if2dec
			dec2if_empty	: out Std_Logic; -- si la fifo qui recup pc est vide
			if_pop			: in Std_Logic; -- pop de la fifo dec2if

			if2dec_empty	: in Std_Logic; -- si la fifo qui envoie l'inst est vide
			dec_pop			: out Std_Logic; -- 

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest			: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component Reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		rdata1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		rvalid1		: out Std_Logic;

	-- Read Port 2 32 bits
		rdata2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		rvalid2		: out Std_Logic;

	-- Read Port 3 5 bits (for shift)
		rdata3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		rvalid3		: out Std_Logic;

	-- read CSPR Port
		cry			: out Std_Logic;
		zero			: out Std_Logic;
		neg			: out Std_Logic;
		ovr			: out Std_Logic;
		
		reg_cznv		: out Std_Logic;
		reg_vv		: out Std_Logic;

	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck					: in Std_Logic;
		reset_n			: in Std_Logic;
		vdd				: in bit;
		vss				: in bit);
end component;

component fifo -- on ne peut pas utiliser de fifo generic car c'est pas synthétisable
	generic(WIDTH: positive);
	port(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout		: out std_logic_vector(WIDTH-1 downto 0);

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
end component;

signal cond	: Std_Logic ; -- predicat vrai ou pas
signal condv	: Std_Logic; -- condition valide ou non
signal operv : Std_Logic;

signal regop_t  : Std_Logic;
signal mult_t   : Std_Logic;
signal swap_t   : Std_Logic; -- swap entre un registre et une @ : load+store en même temps
signal trans_t  : Std_Logic;
signal mtrans_t : Std_Logic;
signal branch_t : Std_Logic;

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- Multiple transferts

-- RF read ports

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

-- Setup transition :

signal T1_fetch,T2_fetch,T1_run,T2_run,T3_run,T4_run,T5_run,T6_run,T1_branch,T2_branch : std_logic ;


-- DECOD FSM

--Machine a etat :

type state_type is (FETCH,RUN,MTRANS,LINK,BRANCH) ;
signal cur_state, next_state : state_type ;

begin

	dec2exec : fifo	port map (	din() => pre_index, -- fifo à mapper

-- Execution condition
--ATTENTION GESTION DE L'OVERFLOW EN CAS DE COMPARAISON
	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') 				or
						(if_ir(31 downto 28) = X"1" and zero ='0') 					or 
						(if_ir(31 downto 28) = X"2" and cry = '1') 					or
						(if_ir(31 downto 28) = X"3" and cry = '0')					or
						(if_ir(31 downto 28) = X"4" and neg = '1')					or
						(if_ir(31 downto 28) = X"5" and neg = '0')					or
						(if_ir(31 downto 28) = X"6" and ovr = '1')					or
						(if_ir(31 downto 28) = X"7" and ovr ='0')					or
						(if_ir(31 downto 28) = X"8" and (cry ='1' and zero = '0')) 	or
						(if_ir(31 downto 28) = X"9" and (cry = '0' or zero ='1')) 	or
						(if_ir(31 downto 28) = X"A" and (neg = '0' or zero ='1')) 	or
						(if_ir(31 downto 28) = X"B" and neg = '1' and zero ='0' )	or
						(if_ir(31 downto 28) = X"C" and neg ='0' and zero ='0')		or
						(if_ir(31 downto 28) = X"D" and (neg = '1' or zero ='1'))	or
						(if_ir(31 downto 28) = X"E") else '0' ;


	condv <= '1'		when if_ir(31 downto 28) = X"E" else
				reg_cznv	when (if_ir(31 downto 28) = X"0" or

				reg_czn and reg_vv;
--Decodage des instructions : 
-- Instructions calcul
-- Instructions branchement
-- Instructions Mémoire
-- Instructions Mémoire multiples
 
-- decod instruction type

	regop_t <= '1' when	if_ir(27 downto 26) = 

-- decod regop opcode

	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';


--Machine a état :

--Gestion des transitions :

	T1_fetch <= not(dec2if_empty) ; 			-- on peut charger de nouvelles instructions
	T2_fetch <= not(if2dec_empty) ; 			-- la fifo est pleine donc on passe a run
	T1_run <= if2dec_empty or not(dec2exe_empty) or not(condv) ; -- 
	T2_run <= not(cond) ; 						-- condition annulée -> annulation instruction
	T3_run <= cond ; 							-- condition reussi et instruction tourne
	T4_run <= bl_i ; 							-- branchement et link
	T5_run <= b_i ; 							-- branchement et pas de link
	T6_run <= stm_i or ldm_i ; 					-- acces multiples
	T1_branch <= if2dec_empty ; 				-- le branchement a reussi : invalidation + vidange fifo et calcul nouveau pc
	T2_branch <= not(if2dec_empty) ; 			-- branchement echoue et run sequentiel

	Machine_etat : process(ck)
	begin
		if(rising_edge(ck)) then
			if(reset_n = '0') then
				cur_state <= FETCH ;
			else 
				cur_state <= next_state ;
		end if;
	end process ;

	Machine_etat_transition : process(T1_fetch,T2_fetch,T1_run,T2_run,T3_run,T4_run,T5_run,T6_run,T1_branch,T2_branch,cur_state) -- qu'est ce qui definiti les transisitions ?
		begin
				case cur_state is
				when FETCH => if(T1_fetch = '1') then 
								next_state <= FETCH ;
							elsif(T2_fetch = '1') then
								next_state <=RUN ;
				when RUN =>	if(T1_run = '1' or T2_run = '1' or T3_run = '1') then 
								next_state <= RUN ;
							elsif(T4_run = '1') then
								next_state <= LINK ;
							elsif(T5_run = '1') then
								next_state <= BRANCH ;
							elsif(T6_run = '1') then
								next_state <= MTRANS ;

				when MTRANS => next_state <= IFETCH ;
				when LINK => next_state <= BRANCH ;
				--sur le truc du prof T3 est notre T1
				when BRANCH => --if(T3_branch = '1') then ceci est une optimisation dans le cas où l'on a deux branchements qui se suivent, on reste dans l'etat branch
								--	next_state <= BRANCH ;
								if(T2 ='1') then -- dans le cas ou le branchement échoue on va a run pour executer les inst séquentiellement
									next_state <= RUN ;
								elsif (T1 = '1') then  
									next_state <= FETCH ;
									
		end process ;
	end Behavior;

