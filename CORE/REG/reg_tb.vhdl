LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;

---------------------------------PENSER A MODIFIER REG POUR QU IL  LISE ET ECRIVE EN MEME TEMPS-----------------------------------------------
entity reg_tb is
end entity;

architecture behavior of reg_tb is
	SIGNAL	wdata1			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	wadr1			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	wen1			:  Std_Logic;

	-- Write Port 2 non prioritaire
	SIGNAL	wdata2			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	wadr2			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	wen2			:  Std_Logic;

	-- Write CSPR Port
	SIGNAL	wcry			:  Std_Logic;
	SIGNAL	wzero			:  Std_Logic;
	SIGNAL	wneg			:  Std_Logic;
	SIGNAL	wovr			:  Std_Logic;
	SIGNAL	cspr_wb			:  Std_Logic;
		
	-- Read Port 1 32 bits
	SIGNAL	reg_rd1			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr1			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v1			:  Std_Logic;

	-- Read Port 2 32 bits
	SIGNAL	reg_rd2			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr2			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v2			:  Std_Logic;

	-- Read Port 3 32 bits
	SIGNAL	reg_rd3			:  Std_Logic_Vector(31 downto 0);
	SIGNAL	radr3			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v3			:  Std_Logic;

	-- Read Port 4 5 bits
	SIGNAL	reg_rd4			:  Std_Logic_Vector(4 downto 0);
	SIGNAL	radr4			:  Std_Logic_Vector(3 downto 0);
	SIGNAL	reg_v4			:  Std_Logic;

	-- read CSPR Port
	SIGNAL	reg_cry			:  Std_Logic;
	SIGNAL	reg_zero		:  Std_Logic;
	SIGNAL	reg_neg			:  Std_Logic;
	SIGNAL	reg_cznv		:  Std_Logic;
	SIGNAL	reg_ovr			:  Std_Logic;
	SIGNAL	reg_vv			:  Std_Logic;
		
	-- Invalidate Port 
	SIGNAL	inval_adr1	:  Std_Logic_Vector(3 downto 0);
	SIGNAL	inval1		:  Std_Logic;

	SIGNAL	inval_adr2	:  Std_Logic_Vector(3 downto 0);
	SIGNAL	inval2		:  Std_Logic;

	SIGNAL	inval_czn	:  Std_Logic;
	SIGNAL	inval_ovr	:  Std_Logic;

	-- PC
	SIGNAL	reg_pc		:  Std_Logic_Vector(31 downto 0);
	SIGNAL	reg_pcv		:  Std_Logic;
	SIGNAL	inc_pc		:  Std_Logic;
	
	-- global interface
	SIGNAL	ck				:  Std_Logic;
	SIGNAL	reset_n			:  Std_Logic;
	SIGNAL	vdd				:  bit;
	SIGNAL	vss				:  bit;

	component reg is
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
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- Read Port 4 5 bits
		reg_rd4		: out Std_Logic_Vector(4 downto 0);
		radr4			: in Std_Logic_Vector(3 downto 0);
		reg_v4		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic;
		reg_ovr		: out Std_Logic;
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
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
	end component;

	begin 

	reg_stage: reg port map (
	-- Write Port 1 prioritaire
		wdata1 => wdata1,
		wadr1 => wadr1,
		wen1 => wen1,

	-- Write Port 2 non prioritaire
		wdata2 => wdata2,
		wadr2 => wadr2,
		wen2 => wen2,

	-- Write CSPR Port
		wcry => wcry,
		wzero => wzero,
		wneg => wneg,
		wovr => wovr,
		cspr_wb => cspr_wb,
		
	-- Read Port 1 32 bits
		reg_rd1 => reg_rd1,
		radr1 => radr1,
		reg_v1 => reg_v1,

	-- Read Port 2 32 bits
		reg_rd2 => reg_rd2,
		radr2 => radr2,
		reg_v2 => reg_v2,

	-- Read Port 3 32 bits
		reg_rd3 => reg_rd3,
		radr3 => radr3,
		reg_v3 => reg_v3,

	-- Read Port 4 5 bits
		reg_rd4 => reg_rd4,
		radr4 => radr4,
		reg_v4 => reg_v4,

	-- read CSPR Port
		reg_cry => reg_cry,
		reg_zero => reg_zero,
		reg_neg => reg_neg,
		reg_cznv => reg_cznv,
		reg_ovr => reg_ovr,
		reg_vv => reg_vv,
		
	-- Invalidate Port 
		inval_adr1 => inval_adr1,
		inval1 => inval1,

		inval_adr2 => inval_adr2,
		inval2 => inval2,

		inval_czn => inval_czn,
		inval_ovr => inval_ovr,

	-- PC
		reg_pc => reg_pc,
		reg_pcv => reg_pcv,
		inc_pc => inc_pc,
	
	-- global interface
		ck => ck,
		reset_n => reset_n,
		vdd => vdd,
		vss => vss
		);
	clock_process : PROCESS
	  begin 
	    ck <= '1';
	    WAIT FOR 4 ns;
	    ck <= '0';
	    WAIT FOR 4 ns;
  	end process;

  	reset: process
  		begin
  			reset_n <= '0';
  			wait for 12 ns;
  			reset_n <= '1';
  			wait;
  		end process;


  	tes_tb_process : PROCESS(ck)

	  variable seed1, seed2 : integer := 999;

	  function to_string ( a: std_logic_vector) return string is
	      variable b : string (1 to a'length) := (others => NUL);
	      variable stri : integer := 1; 
	    begin
	      for i in a'range loop
	          b(stri) := std_logic'image(a((i)))(2);  
	      stri := stri+1;
	      end loop;
	    return b;
	    end function;

	    impure FUNCTION rand_slv(len : integer) return std_logic_vector is
	        variable r : real;
	        variable slv : std_logic_vector(len - 1 downto 0);
	        BEGIN
	          for i in slv'range loop
	              uniform(seed1, seed2, r);
	            IF r > 0.5 THEN
	              slv(i) := '1';
	            ELSE
	              slv(i) := '0';
	            END IF;
	          end loop;
	        return slv;
	      END FUNCTION;
	variable read1, read2 : std_logic_vector(3 downto 0) ;
    BEGIN
    if rising_edge(ck) then

       report "__________________________________________________";
	   report "reset : " & std_logic'image(reset_n)(2);
       report "wdata1 : " & to_string(wdata1);
       report "wdata2 : " & to_string(wdata2); 
       report "wen1 : " & std_logic'image(wen1)(2);
       report "wen2 : " & std_logic'image(wen2)(2);                 
       report "wadr1 : " & to_string(wadr1);
       report "wadr2 : " & to_string(wadr2);

       report "wcry : " & std_logic'image(wcry)(2);
       report "wzero : " & std_logic'image(wzero)(2);
       report "wneg : " & std_logic'image(wneg)(2);
       report "wovr : " & std_logic'image(wovr)(2);
       report "cspr_wb : " & std_logic'image(cspr_wb)(2);

       report "radr1 : " & to_string(radr1); 
  	   report "radr2 : " & to_string(radr2); 
  	   report "radr3 : " & to_string(radr3); 
  	   report "radr4 : " & to_string(radr4);

  	   report "inval_adr1 : " & to_string(inval_adr1);
  	   report "inval_adr2 : " & to_string(inval_adr2);
  	   report "inval_czn : " & std_logic'image(inval_czn)(2);
  	   report "inval_ovr : " & std_logic'image(inval_ovr)(2);
	   report "inc_pc : " & std_logic'image(inc_pc)(2);

	   report "reg_rd1 : " & to_string(reg_rd1);
	   report "reg_rd2 : " & to_string(reg_rd2);
	   report "reg_rd3 : " & to_string(reg_rd3);
	   report "reg_rd4 : " & to_string(reg_rd4);

	   report "reg_v1 : " & std_logic'image(reg_v1)(2);
	   report "reg_v2 : " & std_logic'image(reg_v2)(2);
	   report "reg_v3 : " & std_logic'image(reg_v3)(2);
	   report "reg_v4 : " & std_logic'image(reg_v4)(2);

	   report "reg_cry : " & std_logic'image(reg_cry)(2);
	   report "reg_zero : " & std_logic'image(reg_zero)(2);
	   report "reg_neg : " & std_logic'image(reg_neg)(2);
	   report "reg_cznv : " & std_logic'image(reg_cznv)(2);
	   report "reg_ovr : " & std_logic'image(reg_ovr)(2);
	   report "reg_vv : " & std_logic'image(reg_vv)(2);

	   report "reg_pc : " & to_string(reg_pc);
	   report "reg_pcv : " & std_logic'image(reg_pcv)(2);

    	read2 := rand_slv(4) ;
		wdata1 <= rand_slv(32);
		read1 := rand_slv(4) ;
		wadr1 <= read1;
		wen1 <= rand_slv(2)(1) ;

		wdata2 <= rand_slv(32);
		wadr2 <= read2;
		wen2 <= rand_slv(2)(1) ;
		
		wcry <= rand_slv(2)(1) ;
		wzero <=rand_slv(2)(1) ;
		wneg <=rand_slv(2)(1) ;
		wovr <=rand_slv(2)(1) ;
		cspr_wb <=rand_slv(2)(1) ; --on autorise l'écriture


		radr1 <= read1 ;
		radr2 <= read2 ;
		radr3 <= rand_slv(4) ;
		radr4 <= rand_slv(4) ;

		inval_adr1 <= rand_slv(4) ;
		inval_adr2 <= rand_slv(4) ;
		inval_czn <= rand_slv(2)(1) ;
		inval_ovr <= rand_slv(2)(1) ;

		inc_pc <= '1' ;
		
		--wdata1 <= (others=>'1');
		--wadr1 <= "0000";
		--wen1 <= '0' ;

		--wdata2 <= (others=>'0');
		--wadr2 <= "0001";
		--wen2 <= '1' ;
		
		--wcry <= rand_slv(2)(1) ;
		--wzero <=rand_slv(2)(1) ;
		--wneg <=rand_slv(2)(1) ;
		--wovr <=rand_slv(2)(1) ;
		--cspr_wb <=rand_slv(2)(1) ; --on autorise l'écriture

		--radr1 <= "0000" ;
		--radr2 <= "0001" ;
		--radr3 <= rand_slv(4) ;
		--radr4 <= rand_slv(4) ;

		--inval_adr1 <= "0010" ;
		--inval_adr2 <= "0010" ;
		--inval_czn <= '0' ;
		--inval_ovr <= '0';

		--inc_pc <= '1' ;

	    




    end if;
  END PROCESS tes_tb_process ;     

end architecture behavior;