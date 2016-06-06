LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY test IS PORT (
    clock, enable, reset: IN STD_LOGIC;
    key:                  IN STD_LOGIC_VECTOR(3 downto 0);
    timer:                IN STD_LOGIC;
    timer_x, timer_y:     IN STD_LOGIC_VECTOR(4 downto 0);
	 
	 Q_tile_X, Q_tile_Y:	  				IN STD_LOGIC_VECTOR(4 downto 0);
	 -- Q_tile_type:							OUT STD_LOGIC_VECTOR(0 to 1);
	 
    out_player_X0, out_player_Y0:		OUT STD_LOGIC_VECTOR(8 downto 0); -- player0 position
	 out_player_X1, out_player_Y1:		OUT STD_LOGIC_VECTOR(8 downto 0); -- player1 position
	 out_free0, out_free1:					OUT STD_LOGIC;
	 
	 out_place_x0, out_place_y0:			OUT STD_LOGIC_VECTOR(8 downto 0); 	 -- bubble 0 position
	 out_explode_x0, out_explode_y0: 	OUT STD_LOGIC_VECTOR(8 downto 0);    -- explode center position
    out_qs: 								OUT std_logic_vector(1 downto 0)
);
END;

ARCHITECTURE game OF test IS

	COMPONENT ram
	PORT(
			clock:			IN STD_LOGIC;
			--query
			Q_X, Q_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
			Q_S:				OUT STD_LOGIC_VECTOR(1 downto 0);
	--		Q_valid_in:		IN STD_LOGIC;
	--		Q_valid_out:	BUFFER STD_LOGIC;
			--query2
			Q2_X, Q2_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
			Q2_S:				OUT STD_LOGIC_VECTOR(1 downto 0);
			--read map
			rst:				IN STD_LOGIC;
			--change
			place_X:			IN STD_LOGIC_VECTOR(4 downto 0);
			place_Y:			IN STD_LOGIC_VECTOR(4 downto 0);
			place:			IN STD_LOGIC;
			explode_X:		IN STD_LOGIC_VECTOR(4 downto 0);
			explode_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
			explode:			IN STD_LOGIC
			--
	);
    END COMPONENT;

	TYPE STATE_TYPE IS (IDLE, READ_KEY, GEN_DELTAS, UPDATE, DONE);
	SIGNAL state: STATE_TYPE;
	
	SIGNAL player_X0, player_Y0: 	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_free0:				STD_LOGIC;
	SIGNAL player_X1, player_Y1: 	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_free1:				STD_LOGIC;
	
	SIGNAL coll_X, coll_Y:			STD_LOGIC_VECTOR(4 downto 0);
	
	SIGNAL place_x0, place_y0:		STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL explode_x0, explode_y0:  STD_LOGIC_VECTOR(4 downto 0);
	
	SIGNAL place, explode: 			STD_LOGIC;
	
	SIGNAL reset_game: 				STD_LOGIC;

--    signal valid_out, valid_in: std_logic:='0';
	
	SIGNAL player_dX0, player_dY0:	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_dX1, player_dY1:	STD_LOGIC_VECTOR(4 downto 0);
	
	CONSTANT delta0: 		STD_LOGIC_VECTOR(4 downto 0) := "00000";
	CONSTANT minus1:		STD_LOGIC_VECTOR(4 downto 0) := "11111";
	CONSTANT plus1:		STD_LOGIC_VECTOR(4 downto 0) := "00001";
	CONSTANT zero4:		STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	SIGNAL q_x, q_y:		STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL q_s:				STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL q2_X, q2_Y:	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL q2_S:			STD_LOGIC_VECTOR(1 downto 0);
BEGIN
    PROCESS (clock)
		VARIABLE s: integer :=0;
    BEGIN
    IF clock'Event AND clock = '1' THEN
        IF enable = '0' THEN
            state <= IDLE;
        ELSE
            CASE state IS
                WHEN IDLE =>
                IF enable = '1' THEN
                    state <= READ_KEY;
                END IF;
                WHEN READ_KEY =>
                    reset_game <= not reset;
                    state <= GEN_DELTAS;
                WHEN GEN_DELTAS =>
                    CASE key IS
                        WHEN "0010" => -- 0 left
                            IF player_x0/="00000" THEN
                                player_dX0 <= minus1;
                            ELSE
                                player_dX0 <= delta0;
                            END IF;
                        WHEN "0001" => -- 0 up
                            IF player_y0 /= "00000" THEN
                                player_dY0 <= minus1;
                            ELSE
                                player_dY0 <= delta0;
                            END IF;
                        WHEN "0100" => -- 0 right
                            IF player_x0 /= "10011" THEN
                                player_dX0 <= plus1;
                            ELSE
                                player_dX0 <= delta0;
                            END IF;
                        WHEN "0011" => -- 0 down
                            IF player_y0 /= "01111" THEN
                                player_dY0 <= plus1;
                            ELSE
                                player_dY0 <= delta0;
                            END IF;
								WHEN "0101" => -- 0 place a bubble
									null;
								WHEN "0110" => -- 1 up
								    IF player_y1 /= "00000" THEN
                                player_dY1 <= minus1;
                            ELSE
                                player_dY1 <= delta0;
                            END IF;
								WHEN "0111" => -- 1 left
								    IF player_x1/="00000" THEN
                                player_dX1 <= minus1;
                            ELSE
                                player_dX1 <= delta0;
                            END IF;
								WHEN "1000" => -- 1 down
								    IF player_y1 /= "01111" THEN
                                player_dY1 <= plus1;
                            ELSE
                                player_dY1 <= delta0;
                            END IF;
								WHEN "1001" => -- 1 right
								    IF player_x1 /= "10011" THEN
                                player_dX1 <= plus1;
                            ELSE
                                player_dX1 <= delta0;
                            END IF;
								WHEN "1010" => -- 1 place a bubble
								    null;
								WHEN others =>
							       player_dX0 <= delta0;
									 player_dY0 <= delta0;
									 player_dX1 <= delta0;
									 player_dY1 <= delta0;
                    END CASE;
                    state <= UPDATE;
                WHEN UPDATE =>
                    IF reset_game = '1' AND reset = '0' THEN
                        player_X0 <= "00000";
                        player_Y0 <= "00000";
								player_X1 <= "00000";
                        player_Y1 <= "00000";
                    ELSE
                        player_X0 <= player_X0 + player_dX0;
                        player_Y0 <= player_Y0 + player_dY0;
								player_X1 <= player_X1 + player_dX1;
								player_Y1 <= player_Y1 + player_dY1;
                    END IF;
                    state <= DONE;
                WHEN DONE =>
                    IF enable = '0' THEN
                        state <= IDLE;
                    END IF;
				END CASE;
        END IF;
    END IF;
    END PROCESS;
 
	map_ram: ram PORT MAP(
		clock => clock,
		--query
		Q_X => q_x, 
		Q_Y => q_y,
		Q_S => q_s,
--		Q_valid_in =>valid_in,
--		Q_valid_out =>valid_out,
		Q2_X => q_x, 
		Q2_Y => q_y,
		Q2_S => q2_s,
		rst=>reset,
		place_X => place_x0,
		place_Y => place_y0,
		place   => place,
		explode_X => explode_x0,
		explode_Y => explode_y0,
		explode   => explode	
	);

	out_player_X0 <= player_X0 & zero4;
	out_player_Y0 <= player_Y0 & zero4;
	out_player_X1 <= player_X1 & zero4;
	out_player_Y1 <= player_Y1 & zero4;
	
	out_qs <= q_s;
	out_place_x0 <= place_x0 & zero4;
	out_place_y0 <= place_y0 & zero4;
	
	out_explode_x0 <= explode_x0 & zero4;
	out_explode_y0 <= explode_y0 & zero4;
END game;