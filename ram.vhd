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
    place_X0:           IN  STD_LOGIC_VECTOR(4 downto 0);
    place_Y0:           IN  STD_LOGIC_VECTOR(4 downto 0);
    place_0:            IN  STD_LOGIC;
	 place_X1:           IN  STD_LOGIC_VECTOR(4 downto 0);
    place_Y1:           IN  STD_LOGIC_VECTOR(4 downto 0);
    place_1:            IN  STD_LOGIC;
	 explode_X0:         IN  STD_LOGIC_VECTOR(4 downto 0);
    explode_Y0:         IN  STD_LOGIC_VECTOR(4 downto 0);
    explode_0:          IN  STD_LOGIC;
    explode_X1:         IN  STD_LOGIC_VECTOR(4 downto 0);
    explode_Y1:         IN  STD_LOGIC_VECTOR(4 downto 0);
    explode_1:          IN  STD_LOGIC
);
END;

ARCHITECTURE map_ram OF ram IS
    SUBTYPE map_tile IS STD_LOGIC_VECTOR(2 downto 0);
    TYPE ram_type IS ARRAY(0 to 479) OF map_tile;
    SIGNAL tile0:               map_tile;
	 SIGNAL tile1:               map_tile;
	 
	 CONSTANT wid:            integer:=32;
	 CONSTANT stone: map_tile := "100";
    
    SIGNAL Q_addr:             STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q1_addr:            STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q2_addr:            STD_LOGIC_VECTOR(9 downto 0);
	 
    SIGNAL place_addr0:        STD_LOGIC_VECTOR(9 downto 0);
	 SIGNAL place_addr1:        STD_LOGIC_VECTOR(9 downto 0);
    
	 SIGNAL explo_addr_0:       STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL explo_addr_1:       STD_LOGIC_VECTOR(9 downto 0);
	 
    TYPE ESTATE IS (EWAIT, ECUR_START, ECUR_END, EUP_START, EUP_END, ERIGHT_START, ERIGHT_END, EDOWN_START, EDOWN_END, ELEFT_START, ELEFT_END);
    SIGNAL explo_state0, explo_state1:     ESTATE;
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

    PROCESS(clock, rst, place_X0, place_Y0, place_X1, place_Y1)
        VARIABLE place_num0:      integer:=0;
		  VARIABLE place_num1:      integer:=0;
		  VARIABLE explode_num0:    integer:=0;
		  VARIABLE detect_num0:     integer:=0;
		  VARIABLE explode_num1:    integer:=0;
		  VARIABLE detect_num1:     integer:=0;
    BEGIN
        place_num0 := conv_integer(place_Y0 & place_X0);
		  place_num1 := conv_integer(place_Y1 & place_X1);
		  explode_num0 := conv_integer(explode_Y0 & explode_X0);
        explode_num1 := conv_integer(explode_Y1 & explode_X1);
		  
        IF rst='0' THEN
		      explo_state0 <= EWAIT;
				explo_state1 <= EWAIT;
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
                "000","000","111","110","001","000","100","000","000","000","000","000","000","000","000","100","000","000","000","000","110","000","000","100","111","110","000","000","100","000","000","000"
);
        ELSIF clock'Event AND clock = '1' THEN
            IF place_0 = '1' and ram(place_num0)="000" THEN
                ram(place_num0):="010"; 
            END IF;
				
				IF place_1 = '1' and ram(place_num1) = "000" THEN
				    ram(place_num1):="010"; 
				END IF;
				
				IF explode_0 = '1' THEN
					 CASE explo_state0 IS
						  WHEN EWAIT => 
								explo_state0 <= ECUR_START;
						  WHEN ECUR_START =>
								detect_num0 := explode_num0;
								tile0 <= ram(explode_num0);
								explo_state0 <= ECUR_END;
						  WHEN ECUR_END =>
								IF tile0 = "010" THEN
									 ram(detect_num0) := "011";
								ELSIF tile0 = "011" THEN
									 ram(detect_num0) := "000";
								END IF;
								explo_state0 <= EUP_START;
						  WHEN EUP_START =>
								IF explode_num0 >= wid THEN
									 detect_num0 := explode_num0 - wid;
									 tile0 <= ram(detect_num0);
									 explo_state0 <= EUP_END;
								ELSE
									 explo_state0 <= ERIGHT_START;
								END IF;
						  WHEN EUP_END =>
								IF tile0 /= stone then
									 ram(detect_num0) := "000"; 
								END IF;
								explo_state0 <= ERIGHT_START;
						  WHEN ERIGHT_START =>
								detect_num0 := explode_num0 + 1;
								tile0 <= ram(detect_num0);
								explo_state0 <= ERIGHT_END;
						  WHEN ERIGHT_END =>
								if tile0 /= stone then
									 ram(detect_num0) := "000";
								end if;
								explo_state0 <= EDOWN_START;
						  WHEN EDOWN_START =>
								detect_num0 := explode_num0 + wid;
								tile0 <= ram(detect_num0);
								explo_state0 <= EDOWN_END;
						  WHEN EDOWN_END =>
								if tile0 /= stone then
									 ram(detect_num0) := "000";
								end if;
								explo_state0 <= ELEFT_START;
						  WHEN ELEFT_START =>
								if explode_num0 > 0 then
									 detect_num0 := explode_num0 - 1;
									 tile0 <= ram(detect_num0);
									 explo_state0 <= ELEFT_END;
								else
									 explo_state0 <= EWAIT;
								end if;
						  WHEN ELEFT_END =>
								if tile0 /= stone then
									 ram(detect_num0) := "000";
								end if;
								explo_state0 <= EWAIT;
						  WHEN others =>
								explo_state0 <= EWAIT;
					 END CASE;
			   END IF;
				
		      IF explode_1 = '1' THEN
					 CASE explo_state1 IS
						  WHEN EWAIT => 
								explo_state1 <= ECUR_START;
						  WHEN ECUR_START =>
								detect_num1 := explode_num1;
								tile1 <= ram(explode_num1);
								explo_state1 <= ECUR_END;
						  WHEN ECUR_END =>
								IF tile1 = "010" THEN
									 ram(detect_num1) := "000";
									 explo_state1 <= EUP_START;
								ELSE
									 explo_state1 <= EWAIT;
								END IF;
						  WHEN EUP_START =>
								IF explode_num1 >= wid THEN
									 detect_num1 := explode_num1 - wid;
									 tile1 <= ram(detect_num1);
									 explo_state1 <= EUP_END;
								ELSE
									 explo_state1 <= ERIGHT_START;
								END IF;
						  WHEN EUP_END =>
								IF tile1 /= stone then
									 ram(detect_num1) := "000"; 
								END IF;
								explo_state1 <= ERIGHT_START;
						  WHEN ERIGHT_START =>
								detect_num1 := explode_num1 + 1;
								tile1 <= ram(detect_num1);
								explo_state1 <= ERIGHT_END;
						  WHEN ERIGHT_END =>
								if tile1 /= stone then
									 ram(detect_num1) := "000";
								end if;
								explo_state1 <= EDOWN_START;
						  WHEN EDOWN_START =>
								detect_num1 := explode_num1 + wid;
								tile1 <= ram(detect_num1);
								explo_state1 <= EDOWN_END;
						  WHEN EDOWN_END =>
								if tile1 /= stone then
									 ram(detect_num1) := "000";
								end if;
								explo_state1 <= ELEFT_START;
						  WHEN ELEFT_START =>
								if explode_num1 > 0 then
									 detect_num1 := explode_num1 - 1;
									 tile1 <= ram(detect_num1);
									 explo_state1 <= ELEFT_END;
								else
									 explo_state1 <= EWAIT;
								end if;
						  WHEN ELEFT_END =>
								if tile1 /= stone then
									 ram(detect_num1) := "000";
								end if;
								explo_state1 <= EWAIT;
						  WHEN others =>
								explo_state1 <= EWAIT;
					 END CASE;
			   END IF;
		  END IF;
    END PROCESS;
END map_ram;