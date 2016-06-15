LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
--USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ram IS PORT(
    clock:              IN  STD_LOGIC;
    rst:                IN  STD_LOGIC;
    Q_X, Q_Y:           IN  STD_LOGIC_VECTOR(4 downto 0);
    Q_S:                OUT STD_LOGIC_VECTOR(2 downto 0);
    Q1_X, Q1_Y:         IN  STD_LOGIC_VECTOR(4 downto 0);
    Q1_S:               OUT STD_LOGIC_VECTOR(2 downto 0);
    Q2_X, Q2_Y:         IN  STD_LOGIC_VECTOR(4 downto 0);
    Q2_S:               OUT STD_LOGIC_VECTOR(2 downto 0);
    place_X:            IN  STD_LOGIC_VECTOR(4 downto 0);
    place_Y:            IN  STD_LOGIC_VECTOR(4 downto 0);
    place:              IN  STD_LOGIC;
    explode_X:          IN  STD_LOGIC_VECTOR(4 downto 0);
    explode_Y:          IN  STD_LOGIC_VECTOR(4 downto 0);
    explode:            IN  STD_LOGIC
);
END;

ARCHITECTURE map_ram OF ram IS
    SUBTYPE map_tile IS STD_LOGIC_VECTOR(0 to 2);
    TYPE ram_type IS ARRAY(0 to 639) OF map_tile;
    SIGNAL tile:               map_tile;
    
    SIGNAL Q_addr:             STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q1_addr:             STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q2_addr:            STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL place_addr:         STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL explo_addr:         STD_LOGIC_VECTOR(9 downto 0);
    
    TYPE ESTATE IS (EWAIT, ECUR_START, ECUR_END, EUP_START, EUP_END, ERIGHT_START, ERIGHT_END, EDOWN_START, EDOWN_END, ELEFT_START, ELEFT_END);
    SIGNAL explo_state:     ESTATE;
    shared VARIABLE ram:    ram_type;
BEGIN
    
    PROCESS (Q_X, Q_Y, Q1_X, Q1_Y, Q2_X, Q2_Y)
        VARIABLE i2: integer;
        VARIABLE i1: integer;
        VARIABLE i0: integer;
    BEGIN
        Q_addr  <= Q_Y  & Q_X;
        Q1_addr <= Q1_Y & Q1_X;
        Q2_addr <= Q2_Y & Q2_X;
        i0 := to_integer(unsigned(Q_addr));
        i1 := to_integer(unsigned(Q1_addr));
        i2 := to_integer(unsigned(Q2_addr));
        
        
        Q_S  <= ram(i0);
        Q1_S <= ram(i1);
        Q2_S <= ram(i2);
    END PROCESS;

    PROCESS(clock, rst, place_X, place_Y, explode_X, explode_Y)
        VARIABLE place_num:      integer:=0;
        VARIABLE explode_num:    integer:=0;
        VARIABLE detect_num:     integer:=0;
        
        CONSTANT wid:            integer:=32;
        CONSTANT size:           integer:=640;
        
        VARIABLE s:              integer:=0;
    BEGIN
        place_num := conv_integer(place_Y & place_X);
        explode_num := conv_integer(explode_Y & explode_X);

        IF rst='0' THEN
            explo_state <= EWAIT;
            ram:=(
                "000","000","000","100","000","000","000","001","001","000","000","000","000","000","001","000","100","000","000","001","000","000","000","000","001","000","000","000","001","000","101","001",
                "000","000","100","000","000","000","101","001","000","000","000","000","101","110","000","000","000","000","001","100","000","101","000","000","000","000","000","111","001","110","000","000",
                "000","000","000","000","000","111","101","000","000","000","110","100","000","000","000","000","000","000","000","000","000","101","000","000","000","001","110","001","000","000","000","100",
                "001","000","001","100","001","100","000","100","101","101","000","111","000","110","000","000","100","110","110","100","100","001","001","001","000","001","000","101","101","000","100","000",
                "000","000","000","000","000","000","100","000","100","111","000","001","001","100","000","110","000","100","000","000","111","000","000","000","101","101","111","000","000","100","000","000",
                "001","000","000","101","100","110","000","001","000","000","000","000","001","001","000","000","000","000","000","100","000","000","000","000","110","000","100","100","000","000","000","100",
                "000","000","000","000","101","000","100","000","000","110","000","000","000","000","000","101","101","000","000","110","000","000","000","000","000","001","000","000","000","000","001","000",
                "111","100","100","000","111","001","001","101","000","000","110","000","000","000","000","000","000","100","000","000","000","000","100","000","100","000","000","000","111","000","000","111",
                "001","000","000","000","000","101","000","000","000","000","001","000","000","000","000","101","001","000","000","000","111","001","001","101","111","000","000","001","000","000","000","000",
                "111","000","110","100","000","110","000","000","000","000","000","111","000","000","000","000","000","001","000","100","001","000","001","001","000","111","100","101","100","001","000","000",
                "000","101","110","100","100","000","000","000","000","000","000","101","000","000","000","001","100","000","000","000","000","000","000","000","001","100","000","000","000","000","000","000",
                "000","100","000","000","100","000","000","100","100","000","000","000","000","000","101","000","000","000","100","000","000","111","001","000","000","000","001","000","111","001","000","000",
                "000","000","000","000","100","001","000","000","000","000","000","000","000","100","101","000","000","000","000","001","110","000","000","100","101","100","000","000","000","000","000","110",
                "111","000","000","100","000","101","110","101","110","000","100","000","101","000","111","000","110","000","000","111","101","001","000","110","000","000","000","000","000","000","000","001",
                "000","000","111","110","001","000","100","000","000","000","000","000","000","000","000","100","000","000","000","000","110","000","000","100","111","110","000","000","100","000","000","000",
                "000","100","000","101","110","000","100","000","000","000","001","000","111","000","000","000","000","000","000","100","000","000","001","000","110","000","000","100","111","000","000","100",
                "000","000","000","000","100","000","001","000","000","000","000","100","001","000","000","000","100","000","000","001","000","000","000","000","001","000","001","101","000","000","000","111",
                "001","111","000","100","000","000","000","000","001","001","000","100","111","111","000","000","000","101","000","000","000","000","000","000","000","001","000","000","000","000","000","000",
                "100","100","000","001","101","000","000","001","000","000","110","000","100","000","000","000","000","001","101","110","000","000","000","000","100","000","000","100","001","000","000","001",
                "001","000","000","000","000","100","000","111","000","110","000","000","000","000","000","111","100","101","001","000","000","110","000","000","100","000","000","000","000","000","000","000"
);
        ELSIF clock'Event AND clock = '1' THEN
            IF place='1' and ram(place_num)="000" THEN
                    ram(place_num):="010"; 
            ELSIF explode = '1' THEN
                CASE explo_state IS
                    WHEN EWAIT => 
                        explo_state <= ECUR_START;
                    WHEN ECUR_START =>
                        detect_num := explode_num;
                        tile <= ram(explode_num);
                        explo_state <= ECUR_END;
                    WHEN ECUR_END =>
                        IF tile = "010" THEN
                            ram(detect_num) := "000";
                            explo_state <= EUP_START;
                        ELSE
                            explo_state <= EWAIT;
                        END IF;
                    WHEN EUP_START =>
                        IF explode_num >= wid THEN
                            detect_num := explode_num - wid;
                            tile <= ram(detect_num);
                            explo_state <= EUP_END;
                        ELSE
                            explo_state <= ERIGHT_START;
                        END IF;
                    WHEN EUP_END =>
                        IF tile /= "100" then
                            ram(detect_num) := "000"; 
                        END IF;
                        explo_state <= ERIGHT_START;
                    WHEN ERIGHT_START =>
                        detect_num := explode_num + 1;
                        tile <= ram(detect_num);
                        explo_state <= ERIGHT_END;
                    WHEN ERIGHT_END =>
                        if tile /= "100" then
                            ram(detect_num) := "000";
                        end if;
                        explo_state <= EDOWN_START;
                    WHEN EDOWN_START =>
                        detect_num := explode_num + wid;
                        tile <= ram(detect_num);
                        explo_state <= EDOWN_END;
                    WHEN EDOWN_END =>
                        if tile /= "100" then
                            ram(detect_num) := "000";
                        end if;
                        explo_state <= ELEFT_START;
                    WHEN ELEFT_START =>
                        if explode_num > 0 then
                            detect_num := explode_num - 1;
                            tile <= ram(detect_num);
                            explo_state <= ELEFT_END;
                        else
                            explo_state <= EWAIT;
                        end if;
                    WHEN ELEFT_END =>
                        if tile /= "100" then
                            ram(detect_num) := "000";
                        end if;
                        explo_state <= EWAIT;
                    WHEN others =>
                        explo_state <= EWAIT;
                END CASE;
            end if;
        end if;
    END PROCESS;
END map_ram;