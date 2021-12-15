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
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ; -- pc
			if_ir				: in Std_Logic_Vector(31 downto 0) ; -- 32 bits to decode

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

signal dec2if_empty_signal : std_logic;
signal dec2exe_empty_signal : std_logic;
signal if_pop_signal : std_logic;

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

 signal radr1_signal : Std_Logic_Vector(3 downto 0) ;
 signal radr2_signal : Std_Logic_Vector(3 downto 0) ;
 signal radr3_signal : Std_Logic_Vector(3 downto 0) ;
 signal radr4_signal : Std_Logic_Vector(3 downto 0) ;

 signal rdata1_signal : Std_Logic_Vector(31 downto 0) ;
 signal rdata2_signal : Std_Logic_Vector(31 downto 0) ;
 signal rdata3_signal : Std_Logic_Vector(31 downto 0) ;
 signal rdata4_signal : Std_Logic_Vector(4 downto 0) ;

 signal rv1_signal : std_logic ;
 signal rv2_signal : std_logic ;
 signal rv3_signal : std_logic ;
 signal rv4_signal : std_logic ;

 signal reg_cznv_signal : std_logic;
 signal reg_vv_signal   : std_logic;

-- Write Port of reg :

signal wdata1_signal : Std_Logic_Vector(31 downto 0) ;
signal wdata2_signal : Std_Logic_Vector(31 downto 0) ;
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
 signal reg_pcv_signal : std_logic ;
 signal dec2if_push   : std_logic;
 signal inc_pc_signal : std_logic ;

-- Gestion de EXE
signal dec2exe_push : std_logic;

-- Flags des accès mémoire

signal dec_mem_up_down : std_logic ;

-- DECOD FSM

--Machine a etat :

type state_type is (FETCH,RUN,MTRANS,LINK,BRANCH) ;
signal cur_state, next_state : state_type ;
signal dec_out : std_logic_vector(3 downto 0) ;
begin


    ----------------------------------------------------------------------------------------
                --Port map : Reg 
    ----------------------------------------------------------------------------------------    
    reg0 : reg port map(
                    -- Write Port 1 prioritaire
                    wdata1 => exe_res, --port écriture data1 
                    wadr1 => exe_dest, --registre écriture data1
                    wen1 => exe_wb, --bit enable data1, si = 1 alors on écrit
            
                -- Write Port 2 non prioritaire
                    wdata2 => mem_res,--port écriture data2
                    wadr2 => mem_dest,--registre écriture data2
                    wen2 => mem_wb,--bit enable data2, si = 1 alors on écrit
            
                -- Write CSPR Port
                    wcry => exe_c,--valeur de la retenue en écriture
                    wzero => exe_z, --valeur de flag z
                    wneg => exe_n,--valeur de flag n
                    wovr => exe_v, --valeur de flag v
                    cspr_wb => exe_flag_wb,--bit enable des flags, si = 1 alors on écrit
                    
                -- Read Port 1 32 bits
                    reg_rd1 => rdata1_signal, --valeur du registre lue
                    radr1 => radr1_signal,   -- registre lu
                    reg_v1 => rv1_signal, --bit de validité du registre lu, que l'on envoie à l'étage décode pour analyse
            
                -- Read Port 2 32 bits
                    reg_rd2 => rdata2_signal, --valeur du registre lue
                    radr2 => radr2_signal,-- registre lu
                    reg_v2 => rv2_signal,--bit de validité du registre lu, que l'on envoie à l'étage décode pour analyse
            
                -- Read Port 3 32 bits
                    reg_rd3 => rdata3_signal,
                    radr3 => radr3_signal,
                    reg_v3 => rv3_signal,
            
                -- Read Port 4 5 bits
                    reg_rd4 => rdata4_signal,
                    radr4 => radr4_signal,
                    reg_v4 => rv4_signal,
            
                -- read CSPR Port
                    reg_cry => cry, --valeur des flags lues
                    reg_zero => zero,
                    reg_neg => neg,
                    reg_cznv => reg_cznv_signal, --bit de validité de c,z et n
                    reg_ovr => ovr, --valeur de l'overflow
                    reg_vv => reg_vv_signal,--bit de validité de l'overflow
                    
                -- Invalidate Port 
                    inval_adr1 => inval_adr1_signal, --registres invalidé par decode, donc impossible d'écrire dedans
                    inval1 => inval1_signal, --valeur du bit de validité
            
                    inval_adr2 => inval_adr2_signal,
                    inval2 => inval2_signal,
            
                    inval_czn => inval_czn_signal,
                    inval_ovr => inval_ovr_signal,
            
                -- PC
                    reg_pc => reg_pc_signal,
                    reg_pcv => reg_pcv_signal, -- port de validité de pc
                    inc_pc => inc_pc_signal, -- si = '1' on incremente pc normalement, sinon on lui ajoute l'offset d'un branch
                
                -- global interface
                    ck => ck,
                    reset_n => reset_n,
                    vdd => vdd,
                    vss => vss);
    ----------------------------------------------------------------------------------------
                --Port Map : FIFO 
    ----------------------------------------------------------------------------------------

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
				(reg_cznv_signal = '1'	and ( 
								(if_ir(31 downto 28) = X"0") 	or
								(if_ir(31 downto 28) = X"0" ) 	or
								(if_ir(31 downto 28) = X"1" ) 	or 
								(if_ir(31 downto 28) = X"2" ) 	or
								(if_ir(31 downto 28) = X"3" ) 	or
								(if_ir(31 downto 28) = X"4" ) 	or
								(if_ir(31 downto 28) = X"5" ) 	or
								(if_ir(31 downto 28) = X"8" ) 	or
								(if_ir(31 downto 28) = X"9" )
								)) or
				(reg_vv_signal = '1'  and (
								(if_ir(31 downto 28) = X"6" and ovr = '1')	or
								(if_ir(31 downto 28) = X"7" and ovr ='0')
							)	)
				else (reg_cznv_signal and reg_vv_signal) ;		

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

--DECODING MULTIPLE TRANSFERT INSTRUCTION :

-------------------------------------------------------------------------------

---------------- MACHINE A ETAT------------------------------------------------

--Gestion des transitions :

	T1_fetch <= not(dec2if_empty_signal) ; 			-- on peut charger de nouvelles instructions
	T2_fetch <= not(if2dec_empty) ; 			-- la fifo est pleine donc on passe a run
	T1_run <= if2dec_empty or not(dec2exe_empty_signal) or not(condv) ; -- 
	T2_run <= not(cond) ; 						-- condition annulée -> annulation instruction
	T3_run <= cond and not(bl_i or b_i or stm_i or ldm_i); 							-- condition reussi et instruction tourne
	T4_run <= bl_i and cond; 							-- branchement et link
	T5_run <= b_i and cond; 							-- branchement et pas de link
	T6_run <= (stm_i or ldm_i) and cond ; 					-- acces multiples
	--sur le truc du prof T3 est notre T1
    --T1_branch <= if2dec_empty ; 				-- le branchement a reussi : invalidation + vidange fifo et calcul nouveau pc
	--T2_branch <= not(if2dec_empty) ; 			-- branchement echoue et run sequentiel

--optimisation dans le cas où l'on a deux branchements qui se suivent, on reste dans l'etat branch
    next_state <=   FETCH   when (cur_state = FETCH and T1_fetch = '1') 
                            or    cur_state = MTRANS
                            or    cur_state = BRANCH else
                    RUN     when (cur_state = FETCH and T2_fetch = '1')
                            or   (cur_state = FETCH and (T1_run = '1' or T2_run = '1' or T3_run = '1')) else
                    LINK    when (cur_state = RUN and T4_run = '1') else
                    BRANCH  when (cur_state = RUN and T5_run = '1')
                            or    cur_state = LINK else
                    MTRANS  when (cur_state = RUN and T6_run = '1') else
                    FETCH;

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
-----------------------------------------------------------------------------------------------------------------------------------------------------------------		
---------------------------------------------------------FIFO GESTION--------------------------------------------------------------------------------------------
dec2if_push   		<= '0' 	when cur_state = LINK or (cur_state = RUN and (T4_run or T5_run) = '1') else 
                 		not(dec2if_empty);

if_pop_signal 		<= '1'	when cur_state = FETCH  or   (cur_state = RUN and (T1_run = '1' or T2_run = '1' or T3_run = '1' or T6_run = '1')) 
                    	else '0';

dec2exe_push 		<= '1' when (cur_state = RUN and (T3_run or T4_run or T5_run) = '1') or cur_state = LINK 
                    	else '0';		
---------------------------------------------------------READING PORT--------------------------------------------------------------------------------------------

radr1_signal		<=  if_ir(19 downto 16) when (cur_state = RUN and T3_run = '1') else
                		"1111" when when (cur_state = RUN and T4_run = '1') else
                		"1111" when cur_state = LINK or (cur_state = RUN and T5_run = '1') else
                		"0000";
radr2_signal 		<= if_ir(3 downto 0) when (cur_state = RUN and T3_run = '1'and (trans_t = '1' or regop_t = '1')) else '0' ;
radr3_signal 		<= if_ir(3 downto 0) when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) else '0' ; 
radr4_signal 		<= if_ir(11 downto 8) when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(4) ='1' else '0' ;


---------------------------------------------------------WRITING PORT--------------------------------------------------------------------------------------------		
---------------------------------------------------------SHIFTER GESTION-----------------------------------------------------------------------------------------

dec_shift_lsl 		<= '1' when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(6 downto 5) = "00" else '0' ;
dec_shift_lsr 		<= '1' when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(6 downto 5) = "01" else '0' ;
dec_shift_asr 		<= '1' when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(6 downto 5) = "10" else '0' ;
dec_shift_ror 		<= '1' when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(6 downto 5) = "11"  
				 		and cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '0') or (regop_t = '1' and if_ir(25) = '1')) ;

dec_shift_rrx 		<= '1' when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(6 downto 5) = "11" and if_ir(11 downto 7) = "00001" else '0' ;

dec_shift_val 		<= 	if_ir(11 downto 7) 		when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '1') or (regop_t = '1' and if_ir(25) = '0')) and if_ir(4) = '0' else
				 		if_ir(11 downto 8) & '0' 	when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '0') or (regop_t = '1' and if_ir(25) = '1')) else
				 		rdata4_signal(4 downto 0) 	when cur_state = RUN and T3_run = '1' and ((trans_t = '1' and if_ir(25) = '0') or (regop_t = '1' and if_ir(25) = '1')) and if_ir(24) = '1'

---------------------------------------------------------INVALIDATION--------------------------------------------------------------------------------------------		

dec_flag_wb 		<=  if_ir(20) when (cur_state = RUN and T3_run = '1') else '0';



dec_exe_dest		<=  if_ir(15 downto 12) when (cur_state = RUN and T3_run = '1' and regop_t = '1') else
                		if_ir(19 downto 16) when (cur_state = RUN and T3_run = '1' and trans_t = '1') else
                		"1110" when when (cur_state = RUN and T4_run = '1') else
                		"1111" when cur_state = LINK or (cur_state = RUN and T5_run = '1') else
                		"0000";

inval_adr1_signal 	<= 	if_ir(15 downto 12) when (cur_state = RUN and T3_run = '1') else
                        "1110" when when (cur_state = RUN and T4_run = '1') else
                        "1111" when cur_state = LINK or (cur_state = RUN and T5_run = '1') else
                        "0000"; 

inval1_signal   	<=  if_ir(21) when (cur_state = RUN and T3_run = '1' and trans_t = '1') else
                    	not(tst_i or teq_i or cmp_i or cmn_i) when (cur_state = RUN and T3_run = '1' and regop_t = '1') else
                    	'1' when (cur_state = RUN and T4_run or T5_run = '1') or cur_state = LINK else '0';

inval_adr2_signal 	<= if_ir(19 downto 16);

inval2_signal 		<= '1' when (cur_state = RUN and T3_run = '1' and trans_t = '1' and ldr_i = '1') else '0';

inval_czn_signal 	<= if_ir(20) when (cur_state = RUN and T3_run = '1' and regop_t = '1') else '0';

inval_ovr_signal 	<= if_ir(20) and (sub_i or rsb_i or add_i or adc_i or sbc_i or rsc_i or cmp_i or cmn_i)
     					when (cur_state = RUN and T3_run = '1' and regop_t = '1') else '0';

dec_exe_wb 			<= inval1_signal;
dec_mem_wb 			<= inval2_signal;
--------------------------------------------------------- PC GESTION --------------------------------------------------------------------------------------------		

inc_pc_signal 		<= dec2if_push when cur_state = RUN else '0';





--need to be done in two steps to wait for register reads
	first_action_process: process(ck)
	begin
		if rising_edge(ck) then
			case cur_state is
				when FETCH => -- on doit envoyer pc dans dec2if, ne rien pop dans if2dec, ne rien push dans dec2exe_push, pc s'incremente normalement
					dec2if_push <= '1'; 
					if_pop_signal <= '0';
					dec2exe_push <= '0';
					inc_pc_signal <= '1';
				when RUN => 
					if (T1_run = '1') then  -- sending new pc to dec2if if not full
						if_pop_signal <= '0';
						dec2exe_push <= '0';
                        dec2if_push <= '1';
						inc_pc_signal <= if2dec_empty;
					elsif (T2_run = '1') then -- predicat is false, instruction must be ignore
						if_pop_signal <= '1'; -- ifecth send instruction to decode
						dec2exe_push <= '0'; 
						inc_pc_signal <= '1'; 
					elsif (T3_run = '1') then -- predicat is true, execution of the instruction
						if (regop_t = '1') then
							-- DECODING s BIT + REGISTER :
							dec_flag_wb 	<= if_ir(20) ; 	--setup of s bit from opcode, it says if we need to wb flags
							radr1_signal 	<= if_ir(19 downto 16); 			--setup of Rn
							dec_exe_dest 	<= if_ir(15 downto 12);				--setup of Rd

							--invalidation
							inval_adr1_signal <= if_ir(15 downto 12);
							inval1_signal <= '1';
							inval_czn_signal <= if_ir(20);
							inval_ovr_signal <= if_ir(20);
							dec_exe_wb 		<= not(tst_i or teq_i or cmp_i or cmn_i); --write back activation, tst, teq... are instruction that doesnt write back

							-- DECODING op2 :

							if (if_ir(25) = '0') then -- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
								radr2_signal <= if_ir(3 downto 0); --setup of Rm

								-- on associe les shifts value quand on est de type regop_t, quand le bit 4 vaut 0, et quand on est de type immédiat
								
								dec_shift_lsl <= not(if_ir(6)) and not(if_ir(5)) ;
								dec_shift_lsr <= not(if_ir(6)) and if_ir(5) ;
								dec_shift_asr <= if_ir(6) and not(if_ir(5)) ;
								dec_shift_ror <= if_ir(6) and if_ir(5) ;
								-- dec_shift_rrx handled in shifter
								
								-- Case 1.a : bit 4 = 0 :
								if (if_ir(4) = '0') then
									dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
								else
								-- Case 1.b : bit 4 = 1
									radr3_signal <= if_ir(11 downto 8); -- setup Rs
								end if;

							else -- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
								dec_shift_lsl 	<= '0';
								dec_shift_lsr 	<= '0';
								dec_shift_asr 	<= '0';
								dec_shift_ror 	<= '1';
								dec_shift_rrx 	<= '0';

								dec_shift_val 	<= (if_ir(11 downto 8) & '0'); -- Valeur de rotation multipliée par 2
								dec_op2 		<= X"000000" & if_ir(7 downto 0); -- l'opérande 2 est un immédiat 8 bit étendu sur 32
							end if;
						elsif (trans_t = '1') then --DECODING SIMPLE TRANSFERT INSTRUCTION :
							--TODO: handle post-index (no idea how)
							dec_pre_index 		<= if_ir(24);
							dec_mem_lw 			<= if_ir(20) and not(if_ir(22));
							dec_mem_sw 			<= not(if_ir(20)) and not(if_ir(22));
							dec_mem_lb 			<= if_ir(20) and if_ir(22) ;
							dec_mem_sb 			<= not(if_ir(20)) and if_ir(22) ;

							radr1_signal 		<= if_ir(19 downto 16);
							dec_exe_dest 			<= if_ir(19 downto 16);
							dec_mem_dest 			<= if_ir(15 downto 12);
							
							--if write back, wb the result of the ALU to the read register 1
							dec_exe_wb			<= if_ir(21);
							dec_mem_up_down 	<= if_ir(23);

							--invalidate registers
							inval_adr1_signal <= if_ir(15 downto 12);
							--inval if wb
							inval1_signal <= if_ir(21);

							inval_adr2_signal <= if_ir(19 downto 16);
							--inval if load
							inval2_signal <= if_ir(20);

							inval_czn_signal <= '0';
							inval_ovr_signal <= '0';

							--	Cas 1 : De type immédiat :
							if (if_ir(25) = '1') then
								dec_op2  			<= "00000000000000000000" & if_ir(11 downto 0);
							-- Cas 2 : Pas de type immédiat : 
							else
								radr3_signal 		<= if_ir(3 downto 0);
								
								dec_shift_lsl <= not(if_ir(6)) and not(if_ir(5)) ;
								dec_shift_lsr <= not(if_ir(6)) and if_ir(5) ;
								dec_shift_asr <= if_ir(6) and not(if_ir(5)) ;
								dec_shift_ror <= if_ir(6) and if_ir(5) ;
								-- dec_shift_rrx handled in shifter
								
								-- Case 1.a : bit 4 = 0 :
								if (if_ir(4) = '0') then
									dec_shift_val <= if_ir(11 downto 7) ; -- setup shift_val
								-- Case 1.b : bit 4 = 1
								else
									radr4_signal  <= if_ir(11 downto 8) ; -- setup Rs
								end if;
							end if;
						end if;
						--don't push yet : wait for register reads and then push
						if_pop_signal <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
					elsif (T4_run = '1') then
						if_pop_signal <= '0';
						dec2exe_push <= '0';
						inc_pc_signal <= if2dec_empty;
					elsif (T5_run = '1') then
						if_pop_signal <= '0';
						dec2exe_push <= '1';
						inc_pc_signal <= if2dec_empty;
					elsif (T6_run = '1') then
						if_pop_signal <= '1';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
					end if;
				when LINK =>
					dec_op1			<= reg_pc_signal;
					dec_op2			<= X"FFFFFFFC"; -- add -4 to pc
					dec_exe_dest	<= X"E"; --write to r14
					dec_exe_wb		<= '1'; --activate wb
					dec_flag_wb		<= '0'; --don't update flags
		
					-- Alu operand selection (take both operands)
					dec_comp_op1	<= '1'; 
					dec_comp_op2	<= '1';
					dec_alu_cy 		<= '0';
		
					-- Alu command (select add)
					dec_alu_add		<= '1';
					dec_alu_and		<= '0';
					dec_alu_or		<= '0';
					dec_alu_xor		<= '0';

					--push and stop inc of pc signal
					dec2exe_push <= '1';
					inc_pc_signal <= '1';

					--does not pop 
					if_pop_signal <= '0';

				when BRANCH =>
					dec_op1			<= reg_pc_signal;
					dec_op2			<= "000000" & if_ir(23 downto 0) & "00"; -- add offset*4 to pc
					dec_exe_dest	<= X"F"; --write to r15=pc
					dec_exe_wb		<= '1'; --activate wb
					dec_flag_wb		<= '0'; --don't update flags
		
					-- Alu operand selection (take both operands)
					dec_comp_op1	<= '1'; 
					dec_comp_op2	<= '1';
					dec_alu_cy 		<= '0';
		
					-- Alu command (select add)
					dec_alu_add		<= '1';
					dec_alu_and		<= '0';
					dec_alu_or		<= '0';
					dec_alu_xor		<= '0';

					--push and stop inc of pc signal
					dec2exe_push <= '1';
					inc_pc_signal <= '1';

					--does not pop 
					if_pop_signal <= '0';
			when MTRANS => 
						if_pop_signal <= '1';
						dec2exe_push <= '0';
						inc_pc_signal <= '1';
		end case ;
		end if;
	end process first_action_process;

	--second process to handle the data read in the register bank
	second_action_process: process(rdata1_signal, rdata2_signal, rdata3_signal, rdata4_signal, if_ir, rv1_signal, rv2_signal, rv3_signal, rv4_signal, op_valid)
	variable op_valid : std_logic;
	begin
		if (regop_t = '1') then
			dec_op1 <= rdata1_signal;
			-- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
			if (if_ir(25) = '0') then
				dec_op2 <= rdata2_signal;
				-- Case 1.a : bit 4 = 0 :
				if (if_ir(4) = '0') then
					dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
					if_pop_signal <= '1';
					dec2exe_push <= '1';
					inc_pc_signal <= '1';
					op_valid := rv1_signal and rv2_signal;
				else
				-- Case 1.b : bit 4 = 1
					dec_shift_val <= rdata3_signal(4 downto 0);
					if_pop_signal <= '1';
					dec2exe_push <= '1';
					inc_pc_signal <= '1';
					op_valid := rv1_signal and rv2_signal and rv3_signal;
				end if;
			else
			-- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
				op_valid := rv1_signal;
			end if;
		elsif (trans_t = '1') then
			dec_op1 <= rdata1_signal;
			-- Case 1 : immediate (I = 1)
			if (if_ir(25) = '1') then
				op_valid := rv1_signal;
			-- Cas 2 : Pas de type immédiat : 
			else
				dec_op2  <= rdata3_signal;
				-- Case 2.a : bit 4 = 0 :
				if (if_ir(4) = '0') then
					op_valid := rv1_signal and rv3_signal;
				-- Case 2.b : bit 4 = 1
				else
					op_valid := rv1_signal and rv3_signal and rv4_signal;
					dec_shift_val  <= rdata4_signal; -- setup Rs
				end if;
			end if;
			--if load need r2
			if (if_ir(20) = '0') then
				op_valid := op_valid and rv2_signal;
				dec_mem_data <= rdata2_signal;
			end if;
		else 
			op_valid := '1';
		end if;
		if (op_valid = '0' and (trans_t = '1' or regop_t = '1')) then
			--freeze because an operand is invalid
			if_pop_signal <= '0';
			dec2exe_push <= '0';
			inc_pc_signal <= if2dec_empty;
		elsif (op_valid = '1' and (trans_t = '1' or regop_t = '1')) then
			if_pop_signal <= '1';
			dec2exe_push <= '1';
			inc_pc_signal <= '1';
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

