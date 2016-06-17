LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
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
	 SIGNAL place_tile0:         map_tile;
	 SIGNAL place_tile1:         map_tile;

    CONSTANT wid:            integer:=32;
    CONSTANT stone: map_tile := "100";

    SIGNAL Q_addr:             STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q1_addr:            STD_LOGIC_VECTOR(9 downto 0);
    SIGNAL Q2_addr:            STD_LOGIC_VECTOR(9 downto 0);

	 TYPE PLACE_STATE IS (PLACE_WAIT, PLACE_START, PLACE_END, PLACE_DONE);
	 TYPE ESTATE IS (EWAIT, ECUR_START, ECUR_END, EUP_START, EUP_END, ERIGHT_START, ERIGHT_END, EDOWN_START, EDOWN_END, ELEFT_START, ELEFT_END);
	 
	 SIGNAL state_place_0:      PLACE_STATE := PLACE_WAIT;	 
	 SIGNAL place_addr_0:       STD_LOGIC_VECTOR(9 downto 0);
	 SIGNAL place_start_0:      STD_LOGIC;
	 SIGNAL place_valid_0:      STD_LOGIC;
	 
	 SIGNAL state_place_1:      PLACE_STATE := PLACE_WAIT;
    SIGNAL place_addr_1:       STD_LOGIC_VECTOR(9 downto 0);
	 SIGNAL place_start_1:      STD_LOGIC;
	 SIGNAL place_valid_1:      STD_LOGIC;

	 SIGNAL explo_state0:     ESTATE;
    SIGNAL explo_addr_0:       STD_LOGIC_VECTOR(9 downto 0);
	 SIGNAL det_start_0:        STD_LOGIC;
    SIGNAL det_valid_0:        STD_LOGIC;
	 SIGNAL det_result_0:       STD_LOGIC;
	 
	 SIGNAL explo_state1:     ESTATE;
	 SIGNAL explo_addr_1:       STD_LOGIC_VECTOR(9 downto 0);
	 SIGNAL det_start_1:        STD_LOGIC;
	 SIGNAL det_valid_1:        STD_LOGIC;
	 SIGNAL det_result_1:       STD_LOGIC;
	 
    SIGNAL add0, add1:       STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
	 SIGNAL sum0, sum1:       STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
    shared VARIABLE ram:     ram_type;
	 
	 SIGNAL valid_0:    					 STD_LOGIC;
	 SIGNAL valid_1:    					 STD_LOGIC;
	 SHARED VARIABLE explode_num0:    integer:=0;
	 SHARED VARIABLE detect_num0:     integer:=0;
	 SHARED VARIABLE explode_num1:    integer:=0;
	 SHARED VARIABLE detect_num1:     integer:=0;
	 SHARED VARIABLE place_num0:      integer:=0;
	 SHARED VARIABLE place_num1:      integer:=0;
	 SHARED VARIABLE place_num:       integer:=0;
BEGIN
	 PROCESS(explode_X0, explode_Y0, explode_X1, explode_Y1)
	 BEGIN
		 explo_addr_0 <= explode_Y0 & explode_X0;
		 explo_addr_1 <= explode_Y1 & explode_X1;

		 explode_num0 := conv_integer(explo_addr_0);
		 explode_num1 := conv_integer(explo_addr_1);
	 END PROCESS;
	 
    PROCESS (Q_X, Q_Y, Q1_X, Q1_Y, Q2_X, Q2_Y)
        VARIABLE i2: integer;
        VARIABLE i1: integer;
        VARIABLE i0: integer;
    BEGIN
        Q_addr  <= Q_Y  & Q_X;
        Q1_addr <= Q1_Y & Q1_X;
        Q2_addr <= Q2_Y & Q2_X;
        i0 := conv_integer(unsigned(Q_addr));
        i1 := conv_integer(unsigned(Q1_addr));
        i2 := conv_integer(unsigned(Q2_addr));
        Q_S  <= ram(i0);
        Q1_S <= ram(i1);
        Q2_S <= ram(i2);
    END PROCESS;

    PROCESS(clock, rst, place_X0, place_Y0, place_X1, place_Y1)
    BEGIN
        place_addr_0 <= place_Y0 & place_X0;
        place_addr_1 <= place_Y1 & place_X1;
		  
        place_num0 := conv_integer(place_addr_0);
        place_num1 := conv_integer(place_addr_1);
		  
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
		      IF place_0 = '1' THEN
					CASE state_place_0 IS
						WHEN PLACE_WAIT =>
							state_place_0 <= PLACE_START;
						WHEN PLACE_START =>
							 place_start_0 <= '1';
							 place_valid_0 <= '0';
							state_place_0 <= PLACE_END;
						WHEN PLACE_END =>
							place_start_0 <= '0';
							place_valid_0 <= '1';
							state_place_0 <= PLACE_DONE;
						WHEN PLACE_DONE =>
							IF place_valid_0 = '1' THEN
								place_valid_0 <= '0';
								state_place_0 <= PLACE_WAIT;
							END IF;
					END CASE;
					IF place_start_0 = '1' THEN
						place_tile0 <= ram(place_num0);
					ELSIF place_valid_0 = '1' THEN
					   IF place_tile0 = "000" THEN
							ram(place_num0) := "010";
						END IF;
					END IF;
				END IF; -- place_0 = '1'
				
				IF place_1 = '1' THEN
					CASE state_place_1 IS
						WHEN PLACE_WAIT =>
							state_place_1 <= PLACE_START;
						WHEN PLACE_START =>
							place_start_1 <= '1';
							place_valid_1 <= '0';
							state_place_1 <= PLACE_END;
						WHEN PLACE_END =>
							place_start_1 <= '0';
							place_valid_1 <= '1';
							state_place_1 <= PLACE_DONE;
						WHEN PLACE_DONE =>
							IF place_valid_1 = '1' THEN
								place_valid_1 <= '0';
								state_place_1 <= PLACE_WAIT;
							END IF;
					END CASE;
					
					IF place_start_1 = '1' THEN
						place_tile1 <= ram(place_num1);
					ELSIF place_valid_1 = '1' THEN
						IF place_tile1 = "000" THEN
							ram(place_num1) := "010";
						END IF;
					END IF;
				END IF;

            IF explode_0 = '1' THEN
                CASE explo_state0 IS
                    WHEN EWAIT => 
                        explo_state0 <= ECUR_START;
                    WHEN ECUR_START =>
								det_start_0 <= '1';
								add0 <= CONV_STD_LOGIC_VECTOR(0, 10);
                        explo_state0 <= ECUR_END;
                    WHEN ECUR_END =>
								det_start_0 <= '0';
                        IF det_valid_0 = '1' THEN
								    explo_state0 <= EUP_START;
                        END IF;
                    WHEN EUP_START =>
                        IF explo_addr_0 >= 32 THEN
                            det_start_0 <= '1';
                            add0 <= CONV_STD_LOGIC_VECTOR(-32, 10);
                            explo_state0 <= EUP_END;
                        ELSE
                            explo_state0 <= ERIGHT_START;
                        END IF;
                    WHEN EUP_END =>
                        det_start_0 <= '0';
                        IF det_valid_0 = '1' THEN
								    explo_state0 <= ERIGHT_START;
								END IF;
                    WHEN ERIGHT_START =>
								det_start_0 <= '1';
                        add0 <= CONV_STD_LOGIC_VECTOR(1, 10);
                        explo_state0 <= ERIGHT_END;
                    WHEN ERIGHT_END =>
								det_start_0 <= '0';
								if det_valid_0 <= '1' then
									explo_state0 <= EDOWN_START;
								END IF;
                    WHEN EDOWN_START =>
								det_start_0 <= '1';
                        add0 <= CONV_STD_LOGIC_VECTOR(wid, 10);
                        explo_state0 <= EDOWN_END;
                    WHEN EDOWN_END =>
								det_start_0 <= '0';
								if det_valid_0 = '1' then
									explo_state0 <= ELEFT_START;
								end if;
                    WHEN ELEFT_START =>
								det_start_0 <= '1';
                        if explode_num0 > 0 then
                            add0 <= CONV_STD_LOGIC_VECTOR(-1, 10);
                            explo_state0 <= ELEFT_END;
                        else
                            explo_state0 <= EWAIT;
                        end if;
                    WHEN ELEFT_END =>
								det_start_0 <= '0';
								if det_valid_0 = '1' then
									explo_state0 <= EWAIT;
								end if;
                    WHEN others =>
                        explo_state0 <= EWAIT;
                END CASE;
					 if det_valid_0 = '1' AND tile0 /= stone then
						  ram(detect_num0) := "000";
					 END IF; 
            END IF;
				
            IF explode_1 = '1' THEN
                CASE explo_state1 IS
                    WHEN EWAIT => 
                        explo_state1 <= ECUR_START;
                    WHEN ECUR_START =>
                        det_start_1 <= '1';
                        add1 <= CONV_STD_LOGIC_VECTOR(0, 10);
                        explo_state1 <= ECUR_END;
                    WHEN ECUR_END =>
								det_start_1 <= '0';
                        IF det_valid_1 = '1' THEN
                            explo_state1 <= EUP_START;
                        END IF;
                    WHEN EUP_START =>
                        IF explo_addr_1 >= 32 THEN
                            det_start_1 <= '1';
                            add1 <= CONV_STD_LOGIC_VECTOR(-32, 10);
                            explo_state1 <= EUP_END;
                        ELSE
                            explo_state1 <= ERIGHT_START;
                        END IF;
                    WHEN EUP_END =>
								det_start_1 <= '0';
                        IF det_valid_1 = '1' then
									explo_state1 <= ERIGHT_START;
                        END IF;
                    WHEN ERIGHT_START =>
								det_start_1 <= '1';
                        add1 <= CONV_STD_LOGIC_VECTOR(1, 10);
                        explo_state1 <= ERIGHT_END;
                    WHEN ERIGHT_END =>
								det_start_1 <= '0';
                        if det_valid_1 = '1' then
                            explo_state1 <= EDOWN_START;
                        end if;
                    WHEN EDOWN_START =>
                        det_start_1 <= '1';
                        add1 <= CONV_STD_LOGIC_VECTOR(32, 10);
                        explo_state1 <= EDOWN_END;
                    WHEN EDOWN_END =>
								det_start_1 <= '0';
                        if det_valid_1 = '1' then
									explo_state1 <= ELEFT_START;
                        end if;
                    WHEN ELEFT_START =>
                        if explo_addr_1 > 0 then
									 det_start_1 <= '1';
                            add1 <= CONV_STD_LOGIC_VECTOR(-1, 10);
                            explo_state1 <= ELEFT_END;
                        else
                            explo_state1 <= EWAIT;
                        end if;
                    WHEN ELEFT_END =>
								det_start_1 <= '0';
                        if det_valid_1 = '1' then
                            explo_state1 <= EWAIT;
                        end if;
                    WHEN others =>
                        explo_state1 <= EWAIT;
                END CASE;
					 if det_valid_1 = '1' AND tile1 /= stone then
						  ram(detect_num1) := "000";
					 END IF; 
            END IF;
        END IF;
    END PROCESS;

    PROCESS(clock, det_start_0, explo_addr_0, add0)
    BEGIN
	     IF rising_edge(clock) THEN
			  IF det_start_0 = '1' THEN
					valid_0 <= '0';
					det_result_0 <= '0';
			  ELSE
					sum0 <= explo_addr_0 + add0;
					detect_num0 := CONV_INTEGER(sum0);
					tile0 <= ram(detect_num0);
					valid_0 <= '1';
			  END IF;
			  
			  IF valid_0 = '1' AND tile0 = stone THEN
					det_result_0 <= '1';
			  ELSE 
					det_result_0 <= '0';
			  END IF;
        END IF;
    END PROCESS;
	 det_valid_0 <= valid_0;
	 
	 PROCESS(clock, det_start_1, explo_addr_1, add1)
    BEGIN
	     IF rising_edge(clock) THEN
			  IF det_start_1 = '1' THEN
					valid_1 <= '0';
					det_result_1 <= '0';
			  ELSE
					sum1 <= explo_addr_1 + add1;
					detect_num1 := CONV_INTEGER(sum1);
					tile1 <= ram(detect_num1);
					valid_1 <= '1';
			  END IF;
			  
			  IF valid_1 = '1' AND tile1 = stone THEN
					det_result_1 <= '1';
			  ELSE 
					det_result_1 <= '0';
			  END IF;
        END IF;
    END PROCESS;
	 det_valid_1 <= valid_1;
	 
END map_ram;