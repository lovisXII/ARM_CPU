----------
--exec_tb
----------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.numeric_std.ALL ;
use ieee.math_real.all;


ENTITY exec_tb IS
END ENTITY ;

ARCHITECTURE BEHAVIOR OF exec_tb IS
component EXEC
  port(
  -- Decode interface synchro
      dec2exe_empty : in Std_logic;
      exe_pop     : out Std_logic;

  -- Decode interface operands
      dec_op1     : in Std_Logic_Vector(31 downto 0); -- first alu input
      dec_op2     : in Std_Logic_Vector(31 downto 0); -- shifter input
      dec_exe_dest  : in Std_Logic_Vector(3 downto 0); -- Rd destination
      dec_exe_wb    : in Std_Logic; -- Rd destination write back
      dec_flag_wb   : in Std_Logic; -- CSPR modifiy

  -- Decode to mem interface 
      dec_mem_data  : in Std_Logic_Vector(31 downto 0); -- data to MEM W
      dec_mem_dest  : in Std_Logic_Vector(3 downto 0); -- Destination MEM R
      dec_pre_index   : in Std_logic; -- selectionne le résultat de l'ALU 

      dec_mem_lw    : in Std_Logic;
      dec_mem_lb    : in Std_Logic;
      dec_mem_sw    : in Std_Logic;
      dec_mem_sb    : in Std_Logic;

  -- Shifter command
      dec_shift_lsl : in Std_Logic;
      dec_shift_lsr : in Std_Logic;
      dec_shift_asr : in Std_Logic;
      dec_shift_ror : in Std_Logic;
      dec_shift_rrx : in Std_Logic;
      dec_shift_val : in Std_Logic_Vector(4 downto 0);
      dec_cy      : in Std_Logic;

  -- Alu operand selection
      dec_comp_op1  : in Std_Logic;
      dec_comp_op2  : in Std_Logic;
      dec_alu_cy    : in Std_Logic;

  -- Alu command
      dec_alu_cmd   : in Std_Logic_Vector(1 downto 0);

  -- Exe bypass to decod
      exe_res     : out Std_Logic_Vector(31 downto 0);

      exe_c       : out Std_Logic;
      exe_v       : out Std_Logic;
      exe_n       : out Std_Logic;
      exe_z       : out Std_Logic;

      exe_dest      : out Std_Logic_Vector(3 downto 0); -- Rd destination
      exe_wb      : out Std_Logic; -- Rd destination write back
      exe_flag_wb   : out Std_Logic; -- CSPR modifiy

  -- Mem interface
      exe_mem_adr   : out Std_Logic_Vector(31 downto 0); -- Alu res register
      exe_mem_data  : out Std_Logic_Vector(31 downto 0);
      exe_mem_dest  : out Std_Logic_Vector(3 downto 0);

      exe_mem_lw    : out Std_Logic;
      exe_mem_lb    : out Std_Logic;
      exe_mem_sw    : out Std_Logic;
      exe_mem_sb    : out Std_Logic;

      exe2mem_empty : out Std_logic;
      mem_pop     : in Std_logic;

  -- global interface
      ck          : in Std_logic;
      reset_n     : in Std_logic;
      vdd		: in bit;
      vss		: in bit);
end component;

     signal      dec2exe_empty :  Std_logic;
     signal      exe_pop     :  Std_logic;

     signal      dec_op1     :  Std_Logic_Vector(31 downto 0); -- first alu input
     signal      dec_op2     :  Std_Logic_Vector(31 downto 0); -- shifter input
     signal      dec_exe_dest  :  Std_Logic_Vector(3 downto 0); -- Rd destination
     signal      dec_exe_wb    :  Std_Logic; -- Rd destination write back
     signal      dec_flag_wb   :  Std_Logic; -- CSPR modifiy

     signal      dec_mem_data  :  Std_Logic_Vector(31 downto 0); -- data to MEM W
     signal      dec_mem_dest  :  Std_Logic_Vector(3 downto 0); -- Destination MEM R
     signal      dec_pre_index   :  Std_logic; -- selectionne le résultat de l'ALU 

     signal      dec_mem_lw    :  Std_Logic;
     signal      dec_mem_lb    :  Std_Logic;
     signal      dec_mem_sw    :  Std_Logic;
     signal      dec_mem_sb    :  Std_Logic;

     signal      dec_shift_lsl :  Std_Logic;
     signal      dec_shift_lsr :  Std_Logic;
     signal      dec_shift_asr :  Std_Logic;
     signal      dec_shift_ror :  Std_Logic;
     signal      dec_shift_rrx :  Std_Logic;
     signal      dec_shift_val :  Std_Logic_Vector(4 downto 0);
     signal      dec_cy      :  Std_Logic;

     signal      dec_comp_op1  :  Std_Logic;
     signal      dec_comp_op2  :  Std_Logic;
     signal      dec_alu_cy    :  Std_Logic;

     signal      dec_alu_cmd   :  Std_Logic_Vector(1 downto 0);

     signal      exe_res     :  Std_Logic_Vector(31 downto 0);

     signal      exe_c       :  Std_Logic;
     signal      exe_v       :  Std_Logic;
     signal      exe_n       :  Std_Logic;
     signal      exe_z       :  Std_Logic;

     signal      exe_dest      :  Std_Logic_Vector(3 downto 0); -- Rd destination
     signal      exe_wb      :  Std_Logic; -- Rd destination write back
     signal      exe_flag_wb   :  Std_Logic; -- CSPR modifiy

     signal      exe_mem_adr   :  Std_Logic_Vector(31 downto 0); -- Alu res register
     signal      exe_mem_data  :  Std_Logic_Vector(31 downto 0);
     signal      exe_mem_dest  :  Std_Logic_Vector(3 downto 0);

     signal      exe_mem_lw    :  Std_Logic;
     signal      exe_mem_lb    :  Std_Logic;
     signal      exe_mem_sw    :  Std_Logic;
     signal      exe_mem_sb    :  Std_Logic;

     signal      exe2mem_empty :  Std_logic;
     signal      mem_pop     :  Std_logic;
     signal      ck          :  Std_logic;
     signal      reset_n     :  Std_logic;
     signal      vdd		: bit;
     signal      vss		: bit;

  BEGIN 

  exe_stage : EXEC port map(
     dec2exe_empty => dec2exe_empty,
     exe_pop => exe_pop,

     dec_op1 => dec_op1,
     dec_op2 => dec_op2,
     dec_exe_dest => dec_exe_dest,
     dec_exe_wb => dec_exe_wb,
     dec_flag_wb => dec_flag_wb,

     dec_mem_data => dec_mem_data,
     dec_mem_dest => dec_mem_dest,
     dec_pre_index => dec_pre_index,

     dec_mem_lw => dec_mem_lw,
     dec_mem_lb => dec_mem_lb,
     dec_mem_sw => dec_mem_sw,
     dec_mem_sb => dec_mem_sb,

     dec_shift_lsl => dec_shift_lsl,
     dec_shift_lsr => dec_shift_lsr,
     dec_shift_asr => dec_shift_asr,
     dec_shift_ror => dec_shift_ror,
     dec_shift_rrx => dec_shift_rrx,
     dec_shift_val => dec_shift_val,
     dec_cy => dec_cy,

     dec_comp_op1 => dec_comp_op1,
     dec_comp_op2 => dec_comp_op2,
     dec_alu_cy => dec_alu_cy,

     dec_alu_cmd => dec_alu_cmd,

     exe_res => exe_res,

     exe_c => exe_c,
     exe_v => exe_v,
     exe_n => exe_n,
     exe_z => exe_z,

     exe_dest => exe_dest,
     exe_wb => exe_wb,
     exe_flag_wb => exe_flag_wb,

     exe_mem_adr => exe_mem_adr,
     exe_mem_data => exe_mem_data,
     exe_mem_dest => exe_mem_dest,

     exe_mem_lw => exe_mem_lw,
     exe_mem_lb => exe_mem_lb,
     exe_mem_sw => exe_mem_sw,
     exe_mem_sb => exe_mem_sb,

     exe2mem_empty => exe2mem_empty,
     mem_pop => mem_pop,
     ck => ck,
     reset_n => reset_n,
     vdd => vdd,
     vss => vss
    );

dec2exe_empty <= '0';
dec_exe_dest <= (others => '0');
dec_exe_wb <= '0';
dec_flag_wb <= '0';

dec_mem_data <= (others => '0');
dec_mem_dest <= (others => '0');

dec_mem_lw <= '0';
dec_mem_lb <= '0';
dec_mem_sw <= '0';
dec_mem_sb <= '0';

mem_pop <= '1';
reset_n <= '0';


  clock_process : PROCESS
  begin 
    ck <= '1';
    WAIT FOR 4 ns;
    ck <= '0';
    WAIT FOR 4 ns;
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

    BEGIN
    if rising_edge(ck) then
       dec_op1 <= rand_slv(32);
       dec_op2 <= rand_slv(32);

       dec_pre_index <= '0';

       dec_shift_lsl <= '1';
       dec_shift_lsr <= '0';
       dec_shift_asr <= '0';
       dec_shift_ror <= '0';
       dec_shift_rrx <= '0';
       dec_shift_val <= rand_slv(5);
       dec_cy <= rand_slv(1)(0);

       dec_comp_op1 <= '1';
       dec_comp_op2 <= '0';
       dec_alu_cy <= rand_slv(1)(0);

       dec_alu_cmd <= rand_slv(2);

       report "__________________________________________________";

       report "op1 : " & to_string(dec_op1);
       report "op2 : " & to_string(dec_op2);
       report "cmd : " & to_string(dec_alu_cmd);    
       report "alu_cy : " & std_logic'image(dec_alu_cy)(2);
       report "shift_cy : " & std_logic'image(dec_cy)(2);                 
       report "shift_val : " & to_string(dec_shift_val);
       report "lsl : " & std_logic'image(dec_shift_lsl)(2);
       report "lsr : " & std_logic'image(dec_shift_lsr)(2);
       report "asr : " & std_logic'image(dec_shift_asr)(2);
       report "ror : " & std_logic'image(dec_shift_ror)(2);
       report "rrx : " & std_logic'image(dec_shift_rrx)(2);

       report "résultat : " & to_string(exe_res);
       report "flag c : " & std_logic'image(exe_c)(2);
       report "flag v : " & std_logic'image(exe_v)(2);
       report "flag n : " & std_logic'image(exe_n)(2);
       report "flag z : " & std_logic'image(exe_z)(2);
    end if;
  END PROCESS tes_tb_process ;     
     

    END ARCHITECTURE ;