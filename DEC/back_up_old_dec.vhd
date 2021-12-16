----need to be done in two steps to wait for register reads
--	first_action_process: process(ck)
--	begin
--		if rising_edge(ck) then
--			case cur_state is
--				when FETCH => -- on doit envoyer pc dans dec2if, ne rien pop dans if2dec, ne rien push dans dec2exe_push, pc s'incremente normalement
--					dec2if_push <= '1'; 
--					if_pop_signal <= '0';
--					dec2exe_push <= '0';
--					inc_pc_signal <= '1';
--				when RUN => 
--					if (T1_run = '1') then  -- sending new pc to dec2if if not full
--						if_pop_signal <= '0';
--						dec2exe_push <= '0';
--                        dec2if_push <= '1';
--						inc_pc_signal <= if2dec_empty;
--					elsif (T2_run = '1') then -- predicat is false, instruction must be ignore
--						if_pop_signal <= '1'; -- ifecth send instruction to decode
--						dec2exe_push <= '0'; 
--						inc_pc_signal <= '1'; 
--					elsif (T3_run = '1') then -- predicat is true, execution of the instruction
--						if (regop_t = '1') then
--							-- DECODING s BIT + REGISTER :
--							dec_flag_wb 	<= if_ir(20) ; 	--setup of s bit from opcode, it says if we need to wb flags
--							radr1_signal 	<= if_ir(19 downto 16); 			--setup of Rn
--							dec_exe_dest 	<= if_ir(15 downto 12);				--setup of Rd

--							--invalidation
--							inval_adr1_signal <= if_ir(15 downto 12);
--							inval1_signal <= '1';
--							inval_czn_signal <= if_ir(20);
--							inval_ovr_signal <= if_ir(20);
--							dec_exe_wb 		<= not(tst_i or teq_i or cmp_i or cmn_i); --write back activation, tst, teq... are instruction that doesnt write back

--							-- DECODING op2 :

--							if (if_ir(25) = '0') then -- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
--								radr2_signal <= if_ir(3 downto 0); --setup of Rm

--								-- on associe les shifts value quand on est de type regop_t, quand le bit 4 vaut 0, et quand on est de type immédiat
								
--								dec_shift_lsl <= not(if_ir(6)) and not(if_ir(5)) ;
--								dec_shift_lsr <= not(if_ir(6)) and if_ir(5) ;
--								dec_shift_asr <= if_ir(6) and not(if_ir(5)) ;
--								dec_shift_ror <= if_ir(6) and if_ir(5) ;
--								-- dec_shift_rrx handled in shifter
								
--								-- Case 1.a : bit 4 = 0 :
--								if (if_ir(4) = '0') then
--									dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
--								else
--								-- Case 1.b : bit 4 = 1
--									radr3_signal <= if_ir(11 downto 8); -- setup Rs
--								end if;

--							else -- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
--								dec_shift_lsl 	<= '0';
--								dec_shift_lsr 	<= '0';
--								dec_shift_asr 	<= '0';
--								dec_shift_ror 	<= '1';
--								dec_shift_rrx 	<= '0';

--								dec_shift_val 	<= (if_ir(11 downto 8) & '0'); -- Valeur de rotation multipliée par 2
--								dec_op2 		<= X"000000" & if_ir(7 downto 0); -- l'opérande 2 est un immédiat 8 bit étendu sur 32
--							end if;
--						elsif (trans_t = '1') then --DECODING SIMPLE TRANSFERT INSTRUCTION :
--							--TODO: handle post-index (no idea how)
--							dec_pre_index 		<= if_ir(24);
--							dec_mem_lw 			<= if_ir(20) and not(if_ir(22));
--							dec_mem_sw 			<= not(if_ir(20)) and not(if_ir(22));
--							dec_mem_lb 			<= if_ir(20) and if_ir(22) ;
--							dec_mem_sb 			<= not(if_ir(20)) and if_ir(22) ;

--							radr1_signal 		<= if_ir(19 downto 16);
--							dec_exe_dest 			<= if_ir(19 downto 16);
--							dec_mem_dest 			<= if_ir(15 downto 12);
							
--							--if write back, wb the result of the ALU to the read register 1
--							dec_exe_wb			<= if_ir(21);
--							dec_mem_up_down 	<= if_ir(23);

--							--invalidate registers
--							inval_adr1_signal <= if_ir(15 downto 12);
--							--inval if wb
--							inval1_signal <= if_ir(21);

--							inval_adr2_signal <= if_ir(19 downto 16);
--							--inval if load
--							inval2_signal <= if_ir(20);

--							inval_czn_signal <= '0';
--							inval_ovr_signal <= '0';

--							--	Cas 1 : De type immédiat :
--							if (if_ir(25) = '1') then
--								dec_op2  			<= "00000000000000000000" & if_ir(11 downto 0);
--							-- Cas 2 : Pas de type immédiat : 
--							else
--								radr3_signal 		<= if_ir(3 downto 0);
								
--								dec_shift_lsl <= not(if_ir(6)) and not(if_ir(5)) ;
--								dec_shift_lsr <= not(if_ir(6)) and if_ir(5) ;
--								dec_shift_asr <= if_ir(6) and not(if_ir(5)) ;
--								dec_shift_ror <= if_ir(6) and if_ir(5) ;
--								-- dec_shift_rrx handled in shifter
								
--								-- Case 1.a : bit 4 = 0 :
--								if (if_ir(4) = '0') then
--									dec_shift_val <= if_ir(11 downto 7) ; -- setup shift_val
--								-- Case 1.b : bit 4 = 1
--								else
--									radr4_signal  <= if_ir(11 downto 8) ; -- setup Rs
--								end if;
--							end if;
--						end if;
--						--don't push yet : wait for register reads and then push
--						if_pop_signal <= '0';
--						dec2exe_push <= '0';
--						inc_pc_signal <= '1';
--					elsif (T4_run = '1') then
--						if_pop_signal <= '0';
--						dec2exe_push <= '0';
--						inc_pc_signal <= if2dec_empty;
--					elsif (T5_run = '1') then
--						if_pop_signal <= '0';
--						dec2exe_push <= '1';
--						inc_pc_signal <= if2dec_empty;
--					elsif (T6_run = '1') then
--						if_pop_signal <= '1';
--						dec2exe_push <= '0';
--						inc_pc_signal <= '1';
--					end if;
--				when LINK =>
--					dec_op1			<= reg_pc_signal;
--					dec_op2			<= X"FFFFFFFC"; -- add -4 to pc
--					dec_exe_dest	<= X"E"; --write to r14
--					dec_exe_wb		<= '1'; --activate wb
--					dec_flag_wb		<= '0'; --don't update flags
		
--					-- Alu operand selection (take both operands)
--					dec_comp_op1	<= '1'; 
--					dec_comp_op2	<= '1';
--					dec_alu_cy 		<= '0';
		
--					-- Alu command (select add)
--					dec_alu_add		<= '1';
--					dec_alu_and		<= '0';
--					dec_alu_or		<= '0';
--					dec_alu_xor		<= '0';

--					--push and stop inc of pc signal
--					dec2exe_push <= '1';
--					inc_pc_signal <= '1';

--					--does not pop 
--					if_pop_signal <= '0';

--				when BRANCH =>
--					dec_op1			<= reg_pc_signal;
--					dec_op2			<= "000000" & if_ir(23 downto 0) & "00"; -- add offset*4 to pc
--					dec_exe_dest	<= X"F"; --write to r15=pc
--					dec_exe_wb		<= '1'; --activate wb
--					dec_flag_wb		<= '0'; --don't update flags
		
--					-- Alu operand selection (take both operands)
--					dec_comp_op1	<= '1'; 
--					dec_comp_op2	<= '1';
--					dec_alu_cy 		<= '0';
		
--					-- Alu command (select add)
--					dec_alu_add		<= '1';
--					dec_alu_and		<= '0';
--					dec_alu_or		<= '0';
--					dec_alu_xor		<= '0';

--					--push and stop inc of pc signal
--					dec2exe_push <= '1';
--					inc_pc_signal <= '1';

--					--does not pop 
--					if_pop_signal <= '0';
--			when MTRANS => 
--						if_pop_signal <= '1';
--						dec2exe_push <= '0';
--						inc_pc_signal <= '1';
--		end case ;
--		end if;
--	end process first_action_process;

--	--second process to handle the data read in the register bank
--	second_action_process: process(rdata1_signal, rdata2_signal, rdata3_signal, rdata4_signal, if_ir, rv1_signal, rv2_signal, rv3_signal, rv4_signal, op_valid)
--	variable op_valid : std_logic;
--	begin
--		if (regop_t = '1') then
--			dec_op1 <= rdata1_signal;
--			-- Case 1 : regop_t_is_immediat_type = '0' (I = 0)
--			if (if_ir(25) = '0') then
--				dec_op2 <= rdata2_signal;
--				-- Case 1.a : bit 4 = 0 :
--				if (if_ir(4) = '0') then
--					dec_shift_val <= if_ir(11 downto 7); -- setup shift_val
--					if_pop_signal <= '1';
--					dec2exe_push <= '1';
--					inc_pc_signal <= '1';
--					op_valid := rv1_signal and rv2_signal;
--				else
--				-- Case 1.b : bit 4 = 1
--					dec_shift_val <= rdata3_signal(4 downto 0);
--					if_pop_signal <= '1';
--					dec2exe_push <= '1';
--					inc_pc_signal <= '1';
--					op_valid := rv1_signal and rv2_signal and rv3_signal;
--				end if;
--			else
--			-- Case 2 : regop_t_is_immediat_type = '1' (I = 1)
--				op_valid := rv1_signal;
--			end if;
--		elsif (trans_t = '1') then
--			dec_op1 <= rdata1_signal;
--			-- Case 1 : immediate (I = 1)
--			if (if_ir(25) = '1') then
--				op_valid := rv1_signal;
--			-- Cas 2 : Pas de type immédiat : 
--			else
--				dec_op2  <= rdata3_signal;
--				-- Case 2.a : bit 4 = 0 :
--				if (if_ir(4) = '0') then
--					op_valid := rv1_signal and rv3_signal;
--				-- Case 2.b : bit 4 = 1
--				else
--					op_valid := rv1_signal and rv3_signal and rv4_signal;
--					dec_shift_val  <= rdata4_signal; -- setup Rs
--				end if;
--			end if;
--			--if load need r2
--			if (if_ir(20) = '0') then
--				op_valid := op_valid and rv2_signal;
--				dec_mem_data <= rdata2_signal;
--			end if;
--		else 
--			op_valid := '1';
--		end if;
--		if (op_valid = '0' and (trans_t = '1' or regop_t = '1')) then
--			--freeze because an operand is invalid
--			if_pop_signal <= '0';
--			dec2exe_push <= '0';
--			inc_pc_signal <= if2dec_empty;
--		elsif (op_valid = '1' and (trans_t = '1' or regop_t = '1')) then
--			if_pop_signal <= '1';
--			dec2exe_push <= '1';
--			inc_pc_signal <= '1';
--		end if;
		

--	end process second_action_process;



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