LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY test IS PORT (
    clock, enable, rst:   IN STD_LOGIC;
    key:                  IN STD_LOGIC_VECTOR(0 to 3);
    timer:                IN STD_LOGIC;
    timer_x, timer_y:     IN STD_LOGIC_VECTOR(0 to 3);
    out_player_X, out_player_Y:		OUT STD_LOGIC_VECTOR(0 to 3);
	 out_place_x, out_place_y:			OUT STD_LOGIC_VECTOR(0 to 3);
	 out_explode_x, out_explode_y: 	OUT STD_LOGIC_VECTOR(0 to 3);
    out_qs: out std_logic_vector(0 to 1)
);
END;

ARCHITECTURE game OF test IS
    TYPE STATE_TYPE IS (IDLE, READ_PAD, GEN_DELTAS, DONE);

    COMPONENT ram
	PORT(
			clock:			IN STD_LOGIC;
			--query
			Q_X, Q_Y:		IN STD_LOGIC_VECTOR(0 to 3);
			Q_S:				OUT STD_LOGIC_VECTOR(0 to 1);
--			Q_valid_in:		IN STD_LOGIC;
--			Q_valid_out:	OUT STD_LOGIC;
			--query2
			Q2_X, Q2_Y:		IN STD_LOGIC_VECTOR(0 to 3);
			Q2_S:				OUT STD_LOGIC_VECTOR(0 to 1);
			--read map
			rst:				IN STD_LOGIC;
			--change
			place_X:			IN STD_LOGIC_VECTOR(0 to 3);
			place_Y:			IN STD_LOGIC_VECTOR(0 to 3);
			place:			IN STD_LOGIC;
			explode_X:		IN STD_LOGIC_VECTOR(0 to 3);
			explode_Y:		IN STD_LOGIC_VECTOR(0 to 3);
			explode:		IN STD_LOGIC
	);
    END COMPONENT;

    SIGNAL state: STATE_TYPE;
    SIGNAL player_X, player_Y: STD_LOGIC_VECTOR(0 to 3);
    signal place_x, place_y, explode_x, explode_y: std_logic_vector(0 to 3);
    signal place, explode: std_logic;
    signal q_x, q_y: std_logic_vector(0 to 3);
    signal q_s,q2_s: std_logic_vector(0 to 1);
--    signal valid_out, valid_in: std_logic:='0';
BEGIN
    PROCESS (clock)
    variable s: integer :=0;
    BEGIN
    IF clock'Event AND clock = '1' THEN
        IF enable = '0' THEN
            state <= IDLE;
        ELSE
            CASE state IS
                WHEN IDLE =>
                    IF enable = '1' THEN
                        state <= READ_PAD;
                    END IF;
                WHEN READ_PAD =>
					if rst='1' then
						player_x<="0000";
						player_y<="0100";
--						p2_x<=6;
--						p2_y<=1;
					else
						case key is
						when "0101" =>
							place_x<=player_x;
							place_y<=player_y;
							place<='1';
						when others =>
							place<='0';
						end case;
						
						case key is
						when "0001" => --up
							if player_x/="0000" then
								q_x<=player_x-"0001";
								q_y<=player_y;
								--valid_in<='1';
								state<=GEN_DELTAS;
							end if;
						when "0010" => --left
							if player_y/="0000" then
								q_x<=player_x;
								q_y<=player_y-"0001";
								--valid_in<='1';
								state<=GEN_DELTAS;
							end if;
						when "0011" => --down
							if player_x/="1111" then
								q_x<=player_x+"0001";
								q_y<=player_y;
								--valid_in<='1';
								state<=GEN_DELTAS;
							end if;
						when "0100" => --right
							if player_y/="1111" then
								q_x<=player_x;
								q_y<=player_y+"0001";
								--valid_in<='1';
								state<=GEN_DELTAS;
							end if;
						when others =>
						null;
						end case;
						
						if timer='1' then
						explode_x<=timer_x;
						explode_y<=timer_y;
						explode<='1';
						end if;
					end if;
				WHEN GEN_DELTAS =>
					s:=s+1;
					if s=3 then
						s:=0;
					--valid_in<='0';
					--if valid_out='1' then
						if q_s="00" then
							player_x<=q_x;
							player_y<=q_y;
						end if;
						state <= READ_PAD;
					end if;
                    --end if;
                WHEN DONE =>
                    IF enable = '0' THEN
                        state <= IDLE;
                    END IF;
            END CASE;
        END IF;
    END IF;
    END PROCESS;
    map_ram: ram port map(
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
		
		rst=>rst,
		
		place_X => place_x,
		place_Y =>place_y,
		place => place,
		explode_X => explode_x,
		explode_Y => explode_y,
		explode => explode	
	);
	out_player_X<=player_X;
	out_player_Y<=player_Y;
	out_qs<=q_s;
	out_place_x<=place_x;
	out_place_y<=place_y;
	out_explode_x<=explode_x;
	out_explode_y<=explode_y;
END game;