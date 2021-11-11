----------
--shifter
----------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL ;
USE IEEE.MATH_REAL.ALL ;

ENTITY Shifter IS
	PORT(
    shift_lsl : IN  Std_Logic;-- permet de dire quel type de shift on effectue
    shift_lsr : IN  Std_Logic;
    shift_asr : IN  Std_Logic;
    shift_ror : IN  Std_Logic;
    shift_rrx : IN  Std_Logic;
    shift_val : IN  Std_Logic_Vector(4 downto 0);--valeur du shift du 5 bit
    din       : IN  Std_Logic_Vector(31 downto 0); --valeur d'entrée 
    cin       : IN  Std_Logic;
    dout      : OUT Std_Logic_Vector(31 downto 0); -- valeur de sortie
    cout      : OUT Std_Logic;
    -- global interface
    vdd       : IN  bit;
    vss       : IN  bit );
END Shifter;

ARCHITECTURE behavior OF Shifter IS
BEGIN
shifter_process_1 :PROCESS(shift_lsl,shift_lsr,shift_ror,shift_rrx,shift_val,din)
    
    VARIABLE immediat_shift : integer ;

    --On va définir des fonctions effectuant chacun des shift. Le bit 32 recupèrera toujours la carry

    FUNCTION shifte_left (a : Std_Logic_Vector(31 downto 0); b : integer) RETURN Std_Logic_Vector IS
        VARIABLE valeur_retour : Std_Logic_Vector(32 downto 0) ;
        BEGIN
            valeur_retour(32) := a(31) ;
            --On met à 0 toutes les valeurs en dessous de la valeur du shift 
            initialisation_des_zeros : FOR j IN 0 TO (b-1) loop
                    valeur_retour(j) := '0' ;
            END LOOP initialisation_des_zeros ;

            parcours_de_a : FOR i IN b TO (a'length-1) loop
                    valeur_retour(i) := a(i-b) ;
            END LOOP parcours_de_a ;

    RETURN valeur_retour ;
    END FUNCTION ;

    FUNCTION shifte_right (a : Std_Logic_Vector(31 downto 0); b : integer) RETURN Std_Logic_Vector IS
        VARIABLE valeur_retour : Std_Logic_Vector(32 downto 0) ;
        BEGIN
            valeur_retour(32) := a(0) ; -- on récupère a(0) que l'on stocke dans la carry

            --On met a 0 toutes les valeurs au dessus du shift
            initialisation_des_zeros : FOR j IN 0 TO b loop
                    valeur_retour(a'length-1-j):= '0' ;
            END LOOP initialisation_des_zeros ;

            parcours_de_a : FOR i IN 0 TO (a'length-1-(b+1)) loop
                    valeur_retour(i) := a(i+b) ;
            END LOOP parcours_de_a ;

    RETURN valeur_retour ;
    END FUNCTION ;

    FUNCTION shifte_asr (a : Std_Logic_Vector(31 downto 0); b : integer) RETURN Std_Logic_Vector IS
        VARIABLE valeur_retour : Std_Logic_Vector(32 downto 0) ;
        BEGIN
            valeur_retour(32) := a(0) ; -- recupere la retenue
            valeur_retour(31) := a(31) ; --on récupère le bit de signe
            initialisation_des_zeros : FOR j   IN 0 TO b loop
                    valeur_retour(a'length-(j+1)) := '0' ;
            END LOOP ;

            parcours_de_a : FOR i IN 0 TO (a'length-1-(b+1)) loop
                    valeur_retour(i) := a(i+b) ;
            END LOOP ;
            

    RETURN valeur_retour ;
    END FUNCTION ;

    FUNCTION shifte_ror (a : Std_Logic_Vector; b : integer) RETURN Std_Logic_Vector IS
            VARIABLE valeur_retour : Std_Logic_Vector(32 downto 0) ;
        BEGIN
            valeur_retour(32) := a(0) ; -- on stocke a(0) dans la carry
            FOR i IN 0 TO (a'length-1) LOOP
                --il faut faire une disjonction des cas pour effectuer la rotation correctement
                IF i < b THEN 
                    valeur_retour(a'length-1-i) := a(i) ;
                else
                    valeur_retour(a'length-1-i) := a(a'length-1+b-i) ;
                END IF ;
            END LOOP;
    RETURN valeur_retour ;
    END FUNCTION ;

    FUNCTION shifte_rrx (a : Std_Logic_Vector; carry_in : std_logic) RETURN Std_Logic_Vector IS
            VARIABLE valeur_retour : Std_Logic_Vector(32 downto 0) ;
        BEGIN
            valeur_retour(32) := a(0) ; -- on stocke a(0) dans la carry
            valeur_retour(31) := carry_in ;
            FOR i IN 0 TO (a'length-2) LOOP
                    valeur_retour(i) := a(i+1) ;
            END LOOP;
    RETURN valeur_retour ;
    END FUNCTION ;


    BEGIN

    immediat_shift := to_integer(UNSIGNED(shift_val)) ;

    IF(shift_lsl = '1') THEN
            dout <= shifte_left(din,immediat_shift)(31 downto 0) ;
            cout <= shifte_left(din,immediat_shift)(32) ;
    ELSIF (shift_lsr = '1') THEN
            dout <= shifte_right(din,immediat_shift)(31 downto 0) ;
            cout <= shifte_right(din,immediat_shift)(32) ;
    ELSIF (shift_asr = '1') THEN
            dout <= shifte_asr(din,immediat_shift)(31 downto 0) ;
            cout <= shifte_asr(din,immediat_shift)(32) ;
    ELSIF (shift_ror = '1') THEN
            dout <= shifte_ror(din,immediat_shift)(31 downto 0) ;
            cout <= shifte_ror(din,immediat_shift)(32) ;
    ELSIF (shift_rrx = '1') THEN
            dout <= shifte_rrx(din,cin)(31 downto 0) ;
            cout <= shifte_rrx(din,cin)(32) ;
    END IF ;
END PROCESS shifter_process_1 ;
END ARCHITECTURE ;