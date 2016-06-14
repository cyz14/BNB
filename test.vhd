LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY test IS PORT (
	clock, enable, reset:		IN STD_LOGIC;
	key:								IN STD_LOGIC_VECTOR(3 downto 0);
	
	Q_tile_X, Q_tile_Y:			IN STD_LOGIC_VECTOR(4 downto 0);
	Q_tile_type:				OUT STD_LOGIC_VECTOR(0 to 2);
  
	explode:								OUT STD_LOGIC;
	out_player_X0, out_player_Y0:	OUT STD_LOGIC_VECTOR(8 downto 0); -- player0 position
	out_player_X1, out_player_Y1:	OUT STD_LOGIC_VECTOR(8 downto 0); -- player1 position
	out_free0, out_free1:			OUT STD_LOGIC	
);
END;

ARCHITECTURE game OF test IS

COMPONENT ram PORT(
	clock:		IN STD_LOGIC;
	--query
	Q_X, Q_Y:	IN STD_LOGIC_VECTOR(4 downto 0);
	Q_S:		OUT STD_LOGIC_VECTOR(2 downto 0);
	--query2 OWN USE
	Q2_X, Q2_Y: IN STD_LOGIC_VECTOR(4 downto 0);
	Q2_S:		OUT STD_LOGIC_VECTOR(2 downto 0);
	--read map
	rst:		IN STD_LOGIC;
	--change
	place_X:	IN STD_LOGIC_VECTOR(4 downto 0);
	place_Y:	IN STD_LOGIC_VECTOR(4 downto 0);
	place:		IN STD_LOGIC;
	explode_X:  IN STD_LOGIC_VECTOR(4 downto 0);
	explode_Y:  IN STD_LOGIC_VECTOR(4 downto 0);
	explode:	IN STD_LOGIC
);
END COMPONENT;

COMPONENT timer_1st PORT (
	place			:	IN  std_logic;
	valid_in		:	IN  std_logic;
	rst				:	IN  std_logic;
	clk24			:	IN  std_logic; 							-- 24M clock
	place_X			:	IN  std_logic_vector(4 downto 0);
	place_Y			:	IN  std_logic_vector(4 downto 0);
	out_place_X		:	OUT std_logic_vector(4 downto 0);
	out_place_Y		:	OUT std_logic_vector(4 downto 0);
	s				:	OUT std_logic
);
END COMPONENT;

	TYPE STATE_TYPE IS (IDLE, READ_KEY, GEN_DELTAS, UPDATE, DONE, COLL);
	SIGNAL state: STATE_TYPE;

	SIGNAL player_X0, player_Y0:	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_free0:			STD_LOGIC;
	SIGNAL player_X1, player_Y1:	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_free1:			STD_LOGIC;

	SIGNAL coll_X, coll_Y:   		STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL reset_game:	 			STD_LOGIC;

	SIGNAL player_dX0, player_dY0:	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL player_dX1, player_dY1:	STD_LOGIC_VECTOR(4 downto 0);

	CONSTANT delta0:				STD_LOGIC_VECTOR(4 downto 0) := "00000";
	CONSTANT minus1:				STD_LOGIC_VECTOR(4 downto 0) := "11111";
	CONSTANT plus1:					STD_LOGIC_VECTOR(4 downto 0) := "00001";
	CONSTANT zero4:					STD_LOGIC_VECTOR(3 downto 0) := "0000";

	SIGNAL q2_X, q2_Y:				STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL q2_S:   					STD_LOGIC_VECTOR(2 downto 0);

	---------------------------------------------------------------- 
	SIGNAL place_x0, place_y0:  	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL explode_x0, explode_y0:  STD_LOGIC_VECTOR(4 downto 0);

	SIGNAL place, place_0, place_1: STD_LOGIC;	-- bubble place signal
	SIGNAL sexplode:						STD_LOGIC;
 
BEGIN

	PROCESS (clock)
		VARIABLE scnt: integer :=0;
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
					player_dX0 <= delta0;
					player_dY0 <= delta0;
					player_dX1 <= delta0;
					player_dY1 <= delta0;
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
							IF player_y1 /= "01110" THEN
								player_dY1 <= plus1;
							ELSE
								player_dY1 <= delta0;
							END IF;
						WHEN "1001" => -- 1 right
							IF player_x1 /= "10010" THEN
								player_dX1 <= plus1;
							ELSE
								player_dX1 <= delta0;
							END IF;
						when "0101" =>
							place_x0<= player_X0;
							place_y0<= player_Y0;
							place<='1';
						when "1010" =>
							place_x0<= player_X1;
							place_y0<= player_Y1; 
							place<='1';
						WHEN others =>
							player_dX0 <= delta0;
							player_dY0 <= delta0;
							player_dX1 <= delta0;
							player_dY1 <= delta0;
							place <= '0';
					END CASE;
					state <= UPDATE;
				WHEN UPDATE =>
					IF reset = '0' THEN
						player_X0 <= "10011";
						player_Y0 <= "01110";
						player_X1 <= "00000";
						player_Y1 <= "00000";
						place <= '0';
					ELSE
						if player_dX1="00000" and player_dY1="00000" then
						   q2_x <= player_X0 + player_dX0;
						   q2_y <= player_Y0 + player_dY0;
						elsif player_dX0="00000" and player_dY0="00000" then
						   q2_x <= player_X1 + player_dX1;
						   q2_y <= player_Y1 + player_dY1;
						end if;
					END IF;
					state <= COLL;
				WHEN COLL =>
					scnt := scnt + 1;
					if scnt = 5000 then
						scnt := 0;
						if q2_s="000" then
							player_X0 <= player_X0 + player_dX0;
							player_Y0 <= player_Y0 + player_dY0;
							player_X1 <= player_X1 + player_dX1;
							player_Y1 <= player_Y1 + player_dY1;
						end if;
						state<= DONE;
					end if;
				WHEN DONE =>
					IF enable = '0' THEN
						state <= IDLE;
					END IF;
					place <= '0';
			END CASE;
		END IF;
	END IF;
	END PROCESS;

		bub_timer: timer_1st PORT MAP (
		place => place,
		valid_in => place,
		rst => reset,
		clk24 => clock,
		place_X => place_x0,
		place_Y	=> place_y0,
		out_place_X	=> explode_x0,
		out_place_Y	=> explode_y0,
		s => sexplode
	);
	explode <= sexplode;
	
--	PROCESS (sexplode)
--	BEGIN
--	
--	END PROCESS;
	
	map_ram: ram PORT MAP(
	  clock => clock,
	  --query
	  Q_X => Q_tile_X,
	  Q_Y => Q_tile_Y,
	  Q_S => Q_tile_type,
	  Q2_X => q2_x, 
	  Q2_Y => q2_y,
	  Q2_S => q2_s,
	  rst => reset,
	  place_X => place_x0,
	  place_Y => place_y0,
	  place   => place,
	  explode_X => explode_x0,
	  explode_Y => explode_y0,
	  explode   => sexplode
	);

 out_player_X0 <= player_X0 & zero4;
 out_player_Y0 <= player_Y0 & zero4;
 out_player_X1 <= player_X1 & zero4;
 out_player_Y1 <= player_Y1 & zero4;

END game;