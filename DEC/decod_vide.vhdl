library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--On ne traitera pas les transferts multiples pour le moment, a voir a la fin
-- Dans le décodage des inst de traitement de données il manque les else

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
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
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
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck				: in Std_Logic;
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
		cspr_wb			: in Std_Logic;
		
	-- Read Port 1 32 bits
		rdata1			: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		rvalid1			: out Std_Logic;

	-- Read Port 2 32 bits
		rdata2			: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		rvalid2			: out Std_Logic;

	-- Read Port 3 5 bits (for shift)
		rdata3			: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		rvalid3			: out Std_Logic;

	-- read CSPR Port
		cry				: out Std_Logic;
		zero			: out Std_Logic;
		neg				: out Std_Logic;
		ovr				: out Std_Logic;
		
		reg_cznv		: out Std_Logic;
		reg_vv			: out Std_Logic;

	-- Invalidate Port 
		inval_adr1		: in Std_Logic_Vector(3 downto 0);
		inval1			: in Std_Logic;

		inval_adr2		: in Std_Logic_Vector(3 downto 0);
		inval2			: in Std_Logic;

		inval_czn		: in Std_Logic;
		inval_ovr		: in Std_Logic;

	-- PC
		reg_pc			: out Std_Logic_Vector(31 downto 0);
		reg_pcv			: out Std_Logic;
		inc_pc			: in Std_Logic;
	
	-- global interface
		ck				: in Std_Logic;
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

signal regop_t  : Std_Logic; -- traitement de données ?
signal mult_t   : Std_Logic; --multiplication
signal swap_t   : Std_Logic; -- swap entre un registre et une @ : load+store en même temps
signal trans_t  : Std_Logic; -- transfert memoire
signal mtrans_t : Std_Logic; -- transfert multiple
signal branch_t : Std_Logic; -- branchement

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

-- regop & trans gestion of immediat bit


signal trans_t_is_immediat_type : std_logic ;

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

 signal T1_fetch 	: std_logic ;
 signal T2_fetch 	: std_logic ;
 signal T1_run 		: std_logic ;
 signal T2_run 		: std_logic ;
 signal T3_run 		: std_logic ;
 signal T4_run 		: std_logic ;
 signal T5_run 		: std_logic ;
 signal T6_run 		: std_logic ;
 signal T1_branch 	: std_logic ;
 signal T2_branch 	: std_logic ;

 -- Read Port of reg :

 signal radr1_signal : std_logic ;
 signal radr2_signal : std_logic ;
 signal radr3_signal : std_logic ;
 signal radr4_signal : std_logic ;

 signal rdata1_signal : std_logic ;
 signal rdata2_signal : std_logic ;
 signal rdata3_signal : std_logic ;
 signal rdata4_signal : std_logic ;

 signal rv1_signal : std_logic ;
 signal rv2_signal : std_logic ;
 signal rv3_signal : std_logic ;
 signal rv4_signal : std_logic ;

-- Write Port of reg :

signal wadr1_signal : std_logic ;
signal wadr2_signal : std_logic ;
signal wdata1_signal : std_logic ;
signal wdata2_signal : std_logic ;
signal wen1_signal : std_logic ;
signal wen2_signal : std_logic ;

-- Invalidation

signal inval_adr1_signal		: Std_Logic_Vector(3 downto 0);
signal inval1_signal			: Std_Logic;

signal inval_adr2_signal		: Std_Logic_Vector(3 downto 0);
signal inval2_signal			: Std_Logic;

signal inval_czn_signal			: Std_Logic;
signal inval_ovr_signal			: Std_Logic;

 --Gestion de pc :
 signal reg_pc_signal : std_logic_vector(31 downto 0) ;
 signal dec2if_push   : std_logic;
 signal inc_pc_signal : std_logic ;

-- Gestion de EXE
signal dec2exe_push : std_logic;

-- Ajout de signal gerant Up/Down sur les acces memoires :

signal dec_to_mem_up_down : std_logic ;

-- DECOD FSM

--Machine a etat :

type state_type is (FETCH,RUN,MTRANS,LINK,BRANCH) ;
signal cur_state, next_state : state_type ;
signal dec_out : std_logic_vector(3)
begin

	dec2exec : fifo	port map (	
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
	vss		: in bit)

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

						(if_ir(31 downto 28) = X"A" and (neg = '0' or zero ='1') and ovr = '0') 	or
						(if_ir(31 downto 28) = X"B" and neg = '1' and zero ='0' and ovr = '0')		or
						(if_ir(31 downto 28) = X"C" and neg ='0' and zero ='0' and ovr = '0')		or
						(if_ir(31 downto 28) = X"D" and (neg = '1' or zero ='1') and ovr = '0')		or
						--handle overflows for comparison : 
						--if result is positive or zero, the we did -X - (+Y), so -X < Y
						--if result is negative, then we did X - (-Y), so X > -Y
						(if_ir(31 downto 28) = X"A" and neg = '0' and ovr = '1') 					or
						(if_ir(31 downto 28) = X"B" and (neg = '1' or zero = '1') and ovr = '1')	or
						(if_ir(31 downto 28) = X"C" and neg ='0' and ovr = '1')						or
						(if_ir(31 downto 28) = X"D" and (neg = '1' or zero = '1') and ovr = '1')	or

						(if_ir(31 downto 28) = X"E") else '0' ;


	condv <= '1' 			when if_ir(31 downto 28) = X"E" or
				reg_cznv	and( 
								(if_ir(31 downto 28) = X"0") 	or
								(if_ir(31 downto 28) = X"0" ) 	or
								(if_ir(31 downto 28) = X"1" ) 	or 
								(if_ir(31 downto 28) = X"2" ) 	or
								(if_ir(31 downto 28) = X"3" ) 	or
								(if_ir(31 downto 28) = X"4" ) 	or
								(if_ir(31 downto 28) = X"5" ) 	or
								(if_ir(31 downto 28) = X"8" ) 	or
								(if_ir(31 downto 28) = X"9" )
								) or
				reg_vv  and (
								(if_ir(31 downto 28) = X"6" and ovr = '1')	or
								(if_ir(31 downto 28) = X"7" and ovr ='0')
							)	
				else (reg_cznv and reg_vv) ;		

--INSTRUCTION DECODING : 

 
-- DECOD INSTRUCTION TYPE

	regop_t 	<= '1' when	if_ir(27 downto 26) = 	"00"  else '0'; 
	mult_t 		<= '1' when if_ir(27 downto 26) =	"01"  else '0';
	mtrans_t 	<= '1' when if_ir(27 downto 25) = 	"100" else '0';
	branch_t 	<= '1' when if_ir(27 downto 25) =	"101" else '0';
	--mult_t <= '1' when if_ir(27 downto 22 )="000000"; problème avec regop_t car si I et le registre source valent 0 dans l'opcode d'une inst de traitement de données ca fait la meme chose

--DECODING DATA PROCESSING INSTRUCTIONS

-- decod regop opcode

	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
	add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"4" else '0';
	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
	rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
	tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
	teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
	cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
	cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
	orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
	mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
	bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
	mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';


--DECODING BRANCHEMENT INSTRUCTION :
-- Dans le cas d'un branchement, on regarde si la condition est vraie, si c'est le cas on invalide pc et on change son calcul par l'offset ;

	bl_i 	<= '1' when if_ir(24) = '1' and branch_t ='1' else '0'; -- le branchement fait un link
	b_i 	<= '1' when if_ir(24) = '0' and branch_t ='1' else '0'; -- le branchement ne fait pas de link	
	
-------------------------------------------------------------------------------

--DECODING SIMPLE TRANSFERT INSTRUCTION :

	dec_pre_index 				<= if_ir(24) 	when trans_t 	= '1' ;
	dec_mem_lw 					<= '1' 			when if_ir(20) 	= '1' and if_ir(22) = '0' and trans_t = '1' else 0 ;
	dec_mem_sw 					<= '1' 			when if_ir(20) 	= '0' and if_ir(22) = '0' and trans_t = '1' else 0 ;
	dec_mem_lb 					<= '1' 			when if_ir(20) 	= '1' and if_ir(22) = '1' and trans_t = '1' else 0 ;
	dec_mem_sb 					<= '1' 			when if_ir(20) 	= '0' and if_ir(22) = '1' and trans_t = '1' else 0 ;
	trans_t_is_immediat_type 	<= '0' 			when if_ir(25) 	= '1' and trans_t 	= '1' ; --Rappel : les ingé arm etant des bolosses, ici I = 0 => immediat type

	radr1_signal 				<= if_ir(19 downto 16) when trans_t = '1' ;
	radr2_signal 				<= if_ir(15 downto 12) when trans_t = '1' ;


	dec_to_mem_up_down 			<= if_ir(23) when trans_t = '1' ;
	--	Cas 1 : De type immédiat :

	op1 						<= "00000000000000000000" & if_ir(11 downto 0) when trans_t = '1' and trans_t_is_immediat_type = '0' ;

	-- Cas 2 : Pas de type immédiat : 

	radr3_signal 				<= if_ir(3 downto 0) when trans_t = '1' and trans_t_is_immediat_type = '1' ;
	
	dec_shift_lsl 				<= '1' when if_ir(6 downto 5) = "00" and ( trans_t = '1' and trans_t_is_immediat_type = '1') ;
	dec_shift_lsr 				<= '1' when if_ir(6 downto 5) = "01" and ( trans_t = '1' and trans_t_is_immediat_type = '1') ;
	dec_shift_asr 				<= '1' when if_ir(6 downto 5) = "10" and ( trans_t = '1' and trans_t_is_immediat_type = '1') ;
	dec_shift_ror 				<= '1' when if_ir(6 downto 5) = "11" and ( trans_t = '1' and trans_t_is_immediat_type = '1') ;
	dec_shift_rrx 				<= '1' when if_ir(6 downto 5) = "11" and (if_ir(11 downto 7) = "00001" and trans_t = '1' and trans_t_is_immediat_type = '0') ;
	
	-- Case 1.a : bit 4 = 0 :

	dec_shift_val 				<= if_ir(11 downto 7) when trans_t = '1' and trans_t_is_immediat_type = '1' and if_ir(4) = '0' ; -- setup shift_val

	-- Case 1.b : bit 4 = 1

	radr4_signal 				<= if_ir(11 downto 8) when trans_t = '1' and trans_t_is_immediat_type = '1' and if_ir(4) = '1' ; -- setup Rs



	
-------------------------------------------------------------------------------

--DECODING MULTIPLE TRANSFERT INSTRUCTION :

-------------------------------------------------------------------------------

--Machine a état :

--Gestion des transitions :

	T1_fetch <= not(dec2if_empty) ; 			-- on peut charger de nouvelles instructions
	T2_fetch <= not(if2dec_empty) ; 			-- la fifo est pleine donc on passe a run
	T1_run <= if2dec_empty or not(dec2exe_empty) or not(condv) ; -- 
	T2_run <= not(cond) ; 						-- condition annulée -> annulation instruction
	T3_run <= cond and not(bl_i or b_i or stm_i or ldm_i); 							-- condition reussi et instruction tourne
	T4_run <= bl_i and cond; 							-- branchement et link
	T5_run <= b_i and cond; 							-- branchement et pas de link
	T6_run <= (stm_i or ldm_i) and cond ; 					-- acces multiples
	--T1_branch <= if2dec_empty ; 				-- le branchement a reussi : invalidation + vidange fifo et calcul nouveau pc
	--T2_branch <= not(if2dec_empty) ; 			-- branchement echoue et run sequentiel

	Machine_etat : process(ck)
	begin
		if(rising_edge(ck)) then
			if(reset_n = '0') then
				cur_state <= FETCH ;
			else 
				cur_state <= next_state ;
			end if;
		end if;
	end process ;

	Machine_etat_transition : process(T1_fetch,T2_fetch,T1_run,T2_run,T3_run,T4_run,T5_run,T6_run,T1_branch,T2_branch,cur_state) -- qu'est ce qui definiti les transisitions ?
		begin
				case cur_state is
				when FETCH => if(T1_fetch = '1') then 
								next_state <= FETCH ;
							elsif(T2_fetch = '1') then
								next_state <=RUN ;
							end if;
				when RUN =>	if(T1_run = '1' or T2_run = '1' or T3_run = '1') then 
								next_state <= RUN ;
							elsif(T4_run = '1') then
								next_state <= LINK ;
							elsif(T5_run = '1') then
								next_state <= BRANCH ;
							elsif(T6_run = '1') then
								next_state <= MTRANS ;
							end if ;
				when MTRANS => next_state <= IFETCH ;
				when LINK => next_state <= BRANCH ;
				--sur le truc du prof T3 est notre T1
				when BRANCH => --if(T3_branch = '1') then ceci est une optimisation dans le cas où l'on a deux branchements qui se suivent, on reste dans l'etat branch
									next_state <= FETCH ;
		end case ;							
		end process ;
	--need to be done in two steps to wait for register reads
	first_action_process: process(ck)
	begin
		if rising_edge(ck) then
			case cur_state is
				when FETCH => 
					dec2if_push <= '1';
					if_pop <= '0';
					dec2exe_push <= '0';
					inc_pc_signal <= '1';
				when RUN => 
					if (T1_run = '1') then 
						if_pop <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= if2dec_empty;
					elsif (T2_run = '1') then
						if_pop <= '1';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
					elsif (T3_run = '1') then
						if (regop_t = '1') then
							-- DECODING s BIT + REGISTER :
							dec_flag_wb 	<= if_ir(20) ; 	--setup of s bit from opcode, it says if we need to wb flags
							radr1_signal 	<= if_ir(19 downto 16); 			--setup of Rn
							wadr1_signal 	<= if_ir(15 downto 12);				--setup of Rd

							--invalidation
							inval_adr1_signal <= if_ir(15 downto 12);
							inval1 <= '1';
							inval_czn_signal <= if_ir(20);
							inval_ovr_signal <= if_ir(20);
							dec_exe_wb 		<= not(tst_i or teq_i or cmp_i or cmn_i); --write back activation	
							-- DECODING op2 :

							-- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
							if (if_ir(25) = '0') then
								radr2_signal <= if_ir(3 downto 0); --setup of Rm

								-- on associe les shifts value quand on est de type regop_t, quand le bit 4 vaut 0, et quand on est de type immédiat
								
								dec_shift_lsl <= '1' when if_ir(6 downto 5) = "00" else '0' ;
								dec_shift_lsr <= '1' when if_ir(6 downto 5) = "01" else '0' ;
								dec_shift_asr <= '1' when if_ir(6 downto 5) = "10" else '0' ;
								dec_shift_ror <= '1' when if_ir(6 downto 5) = "11" else '0' ;
								dec_shift_rrx <= '1' when if_ir(6 downto 5) = "11" and (if_ir(11 downto 7) = "00001") else '0';
								
								-- Case 1.a : bit 4 = 0 :
								if (if_ir(4) = '0') then
									dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
								else when regop_t = '1' and regop_t_is_immediat_type = '0' and if_ir(4) = '1' 
								-- Case 1.b : bit 4 = 1
									radr3_signal <= if_ir(11 downto 8); -- setup Rs
								end if;

							else
							-- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
								dec_shift_lsl 	<= '0';
								dec_shift_lsr 	<= '0';
								dec_shift_asr 	<= '0';
								dec_shift_ror 	<= '1';
								dec_shift_rrx 	<= '0';

								dec_shift_val 	<= (if_ir(11 downto 8) & '0'); -- Valeur de rotation multipliée par 2
								dec_op2 		<= X"000000" & if_ir(7 downto 0); -- l'opérande 2 est un immédiat 8 bit étendu sur 32
							end if;
						-------------------------------------------------------------------------------
						end if;
						--don't push yet : wait for register reads and then push
						if_pop <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
					elsif (T4_run = '1') then
						if_pop <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= if2dec_empty;
					elsif (T5_run = '1') then
						if_pop <= '0';
						dec2exe_push <= '1';
						inc_pc_signal <= if2dec_empty;
					elsif (T6_run = '1') then
						if_pop <= '1';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
					end if;
				when LINK =>
					dec_op1			<= reg_pc_signal;
					dec_op2			<= X"FFFFFFFC"; -- add -4 to pc
					dec_exe_dest	<= X"E"; --write to r14
					dec_exe_wb		<= 1; --activate wb
					dec_flag_wb		<= 0; --don't update flags
		
					-- Alu operand selection (take both operands)
					dec_comp_op1	<= 1; 
					dec_comp_op2	<= 1;
					dec_alu_cy 		<= 0;
		
					-- Alu command (select add)
					dec_alu_add		<= 1;
					dec_alu_and		<= 0;
					dec_alu_or		<= 0;
					dec_alu_xor		<= 0;

					--push and stop inc of pc signal
					dec2exe_push <= '1';
					inc_pc_signal <= '1';

					--does not pop 
					if_pop <= '0';

				when BRANCH =>
					dec_op1			<= reg_pc_signal;
					dec_op2			<= "000000" & if_ir(23 downto 0) & "00"; -- add offset*4 to pc
					dec_exe_dest	<= X"F"; --write to r15=pc
					dec_exe_wb		<= 1; --activate wb
					dec_flag_wb		<= 0; --don't update flags
		
					-- Alu operand selection (take both operands)
					dec_comp_op1	<= 1; 
					dec_comp_op2	<= 1;
					dec_alu_cy 		<= 0;
		
					-- Alu command (select add)
					dec_alu_add		<= 1;
					dec_alu_and		<= 0;
					dec_alu_or		<= 0;
					dec_alu_xor		<= 0;

					--push and stop inc of pc signal
					dec2exe_push <= '1';
					inc_pc_signal <= '1';

					--does not pop 
					if_pop <= '0';
		end case ;
		end if;
	end process first_action_process;

	--second process to handle the data read in the register bank
	second_action_process: process(rdata1_signal, rdata2_signal, rdata3_signal, rdata4_signal)
	begin
		if (regop_t = '1') then
			-- in any case, need rs
			-- if not valid, freeze
			if (rv1_signal = '0') then
				if_pop <= '0';
				dec2exe_push <= '0';
				inc_pc_signal <= if2dec_empty;
			else
				dec_op1 <= rdata1_signal;
				-- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
				if (if_ir(25) = '0') then
					-- need rm
					-- if not valid, freeze
					if (rv2_signal = '0') then
						if_pop <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= if2dec_empty;
					else
						dec_op2 <= rdata2_signal;
						-- Case 1.a : bit 4 = 0 :
						if (if_ir(4) = '0') then
							dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
							if_pop <= '1';
							dec2exe_push <= '1';
							inc_pc_signal <= '1';
						else
						-- Case 1.b : bit 4 = 1
							-- need rm
							-- if not valid, freeze
							if (rv3_signal = '0') then
								if_pop <= '0';
								dec2exe_push <= '0';
								inc_pc_signal <= if2dec_empty;
							else
								shift_val <= rdata3_signal(4 downto 0);
								if_pop <= '1';
								dec2exe_push <= '1';
								inc_pc_signal <= '1';
							end if;
						end if;
					end if;
				else
				-- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
					-- no dep, we can continue
					if_pop <= '1';
					dec2exe_push <= '1';
					inc_pc_signal <= '1';
				end if;
			end if;
		end if;
	end process second_action_process;



-------------------------------------------------------------------------------

--Actions for state FETCH :

--		-> Dans tous les cas, envoyer une instruction dans dec2if
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

--Actions for state RUN :
--à toujours faire : envoyer valeur PC si dec2if pas pleine
--		-> T1 rien d'autre
--		-> T2 pop une nouvelle instruction de if2dec
--		-> T3 envoyer l'instruction vers EXE et pop une nouvelle instruction de if2dec
-- 		-> T4 sauvergarder PC dans r14, pas de push dans EXE ou pop de IF
-- 		-> T5 calcul de la nouvelle adresse, vider dec2if, pas de pop mais un push
--		-> T6 ...
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

--Actions for state LINK :
-- 		-> calcul de la nouvelle adresse, vider dec2if, pas de pop mais un push

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

--Actions for state BRANCH :
--		-> on vide if2dec
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

--Actions for state MTRANS :

-------------------------------------------------------------------------------
	end Behavior;

