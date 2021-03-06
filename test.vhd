LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY test IS PORT (
    clock, reset:                    IN STD_LOGIC;
    enable:                          IN STD_LOGIC;                     -- logic_enable
    key0, key1:                      IN STD_LOGIC_VECTOR(3 downto 0);  -- control commands of player0 and player1
    Q_tile_X, Q_tile_Y:              IN STD_LOGIC_VECTOR(4 downto 0);  -- query of draw_map
    Q_tile_type:                     OUT STD_LOGIC_VECTOR(0 to 2);     -- return value of query from draw_map
    out_player_X0, out_player_Y0:    OUT STD_LOGIC_VECTOR(8 downto 0); -- player0 position to VGA
    out_player_X1, out_player_Y1:    OUT STD_LOGIC_VECTOR(8 downto 0); -- player1 position to VGA
    out_free0, out_free1:            OUT STD_LOGIC                     -- if players are free to move, if not, lose the game
);
END;

ARCHITECTURE game OF test IS

COMPONENT ram PORT(
    clock:                          IN  STD_LOGIC;
    rst:                            IN  STD_LOGIC;
    Q_X, Q_Y:                       IN  STD_LOGIC_VECTOR(4 downto 0);    -- query
    Q_S:                            OUT STD_LOGIC_VECTOR(2 downto 0);
    Q1_X, Q1_Y:                     IN  STD_LOGIC_VECTOR(4 downto 0);    -- query of test to do collision test of player0
    Q1_S:                           OUT STD_LOGIC_VECTOR(2 downto 0);
    Q2_X, Q2_Y:                     IN  STD_LOGIC_VECTOR(4 downto 0);    -- query of test to do collision test of player1
    Q2_S:                           OUT STD_LOGIC_VECTOR(2 downto 0);
    place_X0, place_Y0:             IN  STD_LOGIC_VECTOR(4 downto 0);    -- bubble_0 place coordinates
    place_0:                        IN  STD_LOGIC;                       -- tells if player0 place a bubble
    place_X1, place_Y1:             IN  STD_LOGIC_VECTOR(4 downto 0);    -- bubble_1 place coordinates
    place_1:                        IN  STD_LOGIC;                       -- tells if player1 place a bubble    
    explode_X0, explode_Y0:         IN  STD_LOGIC_VECTOR(4 downto 0);    -- explosion_0 coordinates
    explode_0:                      IN  STD_LOGIC;                       -- tells if explo_0 occurs
    explode_X1, explode_Y1:         IN  STD_LOGIC_VECTOR(4 downto 0);    -- explosion_1 coordinates
    explode_1:                      IN  STD_LOGIC                        -- tells if explo_1 occurs
);
END COMPONENT;

COMPONENT timer_1st PORT (                                 -- record bubble time to start explosion event
    valid_in:           IN  std_logic;
    rst:                IN  std_logic;
    clk24:              IN  std_logic;
    place_X:            IN  std_logic_vector(4 downto 0);  -- place bubble at the position 
    place_Y:            IN  std_logic_vector(4 downto 0);
    out_place_X:        OUT std_logic_vector(4 downto 0);  -- tells game_logic the bubble at this position
    out_place_Y:        OUT std_logic_vector(4 downto 0);
    is_working:         OUT std_logic;  -- used to restrict bubble number to be ONLY ONE, or will be too much to record
    s:                  OUT std_logic   -- signal to start explosion event
);
END COMPONENT;

CONSTANT R_BOARD: STD_LOGIC_VECTOR(4 downto 0) := CONV_STD_LOGIC_VECTOR(19, 5); -- rightside board of map
CONSTANT D_BOARD: STD_LOGIC_VECTOR(4 downto 0) := CONV_STD_LOGIC_VECTOR(14, 5); -- downside  board of map

CONSTANT minus1:  STD_LOGIC_VECTOR(4 downto 0) := "11111";                      -- minus 1 from coordinate
CONSTANT plus1:   STD_LOGIC_VECTOR(4 downto 0) := "00001";                      -- plus 1
CONSTANT zero4:   STD_LOGIC_VECTOR(3 downto 0) := "0000";
CONSTANT zero5:   STD_LOGIC_VECTOR(4 downto 0) := "00000";

    TYPE STATE_TYPE IS (IDLE, READ_KEY, GEN_DELTAS, COLL_START, UPDATE, DONE );
    SIGNAL state: STATE_TYPE;

    SIGNAL player_X0:               STD_LOGIC_VECTOR(4 downto 0) := "00000";
    SIGNAL player_Y0:               STD_LOGIC_VECTOR(4 downto 0) := "00000";
    SIGNAL player_free0:            STD_LOGIC; -- todo gameover check
    SIGNAL player_X1:               STD_LOGIC_VECTOR(4 downto 0) := "10011";
    SIGNAL player_Y1:               STD_LOGIC_VECTOR(4 downto 0) := "01110";
    SIGNAL player_free1:            STD_LOGIC; -- todo gameover check
    
    SIGNAL player_dX0, player_dY0:  STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL player_dX1, player_dY1:  STD_LOGIC_VECTOR(4 downto 0);

    SIGNAL q1_x, q1_y:              STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL q1_s:                    STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL q2_x, q2_y:              STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL q2_s:                    STD_LOGIC_VECTOR(2 downto 0);

    SIGNAL place_x0, place_y0:      STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL place_x1, place_y1:      STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL place_0, place_1:        STD_LOGIC; -- bubble place signal
    SIGNAL is_working0:             STD_LOGIC;
    SIGNAL is_working1:             STD_LOGIC;

    SIGNAL explode_x0, explode_y0:  STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL explode_x1, explode_y1:  STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL sexplode0, sexplode1:    STD_LOGIC;
 
BEGIN

    PROCESS (clock, reset, enable)
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
                    player_dX0 <= zero5;
                    player_dY0 <= zero5;
                    player_dX1 <= zero5;
                    player_dY1 <= zero5;
                    state <= GEN_DELTAS;
                WHEN GEN_DELTAS =>
                    CASE key0 IS
                        WHEN "0010" =>       -- 0 move left
                            IF player_x0 /= "00000" THEN
                                player_dX0 <= minus1;
                            ELSE
                                player_dX0 <= zero5;
                            END IF;
                        WHEN "0001" =>       -- 0 move up
                            IF player_y0 /= "00000" THEN
                                player_dY0 <= minus1;
                            ELSE
                                player_dY0 <= zero5;
                            END IF;
                        WHEN "0100" =>       -- 0 move right
                            IF player_x0 /= R_BOARD THEN
                                player_dX0 <= plus1;
                            ELSE
                                player_dX0 <= zero5;
                            END IF;
                        WHEN "0011" =>       -- 0 move down
                            IF player_y0 < D_BOARD THEN
                                player_dY0 <= plus1;
                            ELSE
                                player_dY0 <= zero5;
                            END IF;
                        when "0101" =>       -- 0 place bubble
                            place_x0 <= player_X0;
                            place_y0 <= player_Y0;
                            IF is_working0 = '0' THEN
                                place_0 <= '1';
                            ELSE 
                                place_0 <= '0';
                            END IF;
                        when others =>
                            null;
                    END CASE;
                    
                    CASE key1 IS
                        WHEN "0110" =>       -- 1 move up
                            IF player_y1 /= "00000" THEN
                                player_dY1 <= minus1;
                            ELSE
                                player_dY1 <= zero5;
                            END IF;
                        WHEN "0111" =>       -- 1 move left
                            IF player_x1 /= "00000" THEN
                                player_dX1 <= minus1;
                            ELSE
                                player_dX1 <= zero5;
                            END IF;
                        WHEN "1000" =>       -- 1 move down
                            IF player_y1 /= D_BOARD THEN
                                player_dY1 <= plus1;
                            ELSE
                                player_dY1 <= zero5;
                            END IF;
                        WHEN "1001" =>       -- 1 move right
                            IF player_x1 /= R_BOARD THEN
                                player_dX1 <= plus1;
                            ELSE
                                player_dX1 <= zero5;
                            END IF;
                        when "1010" =>       -- 1 place bubble
                            place_x1 <= player_X1;
                            place_y1 <= player_Y1; 
                            IF is_working1 = '0' THEN
                                place_1 <= '1';
                            ELSE 
                                place_1 <= '0';
                            END IF;
                        when others =>
                            null;
                    END CASE;
                    state <= COLL_START;
                WHEN COLL_START =>           -- start to query map
                    q1_x <= player_X0 + player_dX0;
                    q1_y <= player_Y0 + player_dY0;
                    q2_x <= player_X1 + player_dX1;
                    q2_y <= player_Y1 + player_dY1;
                    state <= UPDATE;
                WHEN UPDATE =>
                    IF reset = '0' THEN
                        player_X0 <= "00000";
                        player_Y0 <= "00000";
                        player_X1 <= "10011";
                        player_Y1 <= "01110";
                        place_0 <= '0';
                        place_1 <= '0';
                        scnt := 0;
                        state <= IDLE;
                    ELSE
                        scnt := scnt + 1;
                        IF scnt = 5000 THEN  -- control move speed
                            scnt := 0;
                            IF q1_s = "000" THEN   -- update position of player_0
                                player_X0 <= q1_x; 
                                player_Y0 <= q1_y;
                            END IF;
                            IF q2_s = "000" THEN   -- update position of player_1
                                player_X1 <= q2_x;
                                player_Y1 <= q2_y;
                            END IF;
                            state <= DONE;
                        end if;
                    END IF;
                WHEN DONE =>
                    IF enable = '0' THEN
                        state <= IDLE;
                    END IF;
                    place_0 <= '0';
                    place_1 <= '0';
            END CASE;
        END IF;
    END IF;
    END PROCESS;

    bub_timer_0: timer_1st PORT MAP (
        valid_in => place_0,
        rst => reset,
        clk24 => clock,
        place_X => place_x0,
        place_Y => place_y0,
        out_place_X => explode_x0,
        out_place_Y => explode_y0,
        is_working => is_working0,
        s => sexplode0
    );
    
    bub_timer_1: timer_1st PORT MAP (
        valid_in => place_1,
        rst => reset,
        clk24 => clock,
        place_X => place_x1,
        place_Y => place_y1,
        out_place_X => explode_x1,
        out_place_Y => explode_y1,
        is_working => is_working1,
        s => sexplode1
    );

    map_ram: ram PORT MAP(
        clock => clock,
        rst => reset,
        Q_X => Q_tile_X,
        Q_Y => Q_tile_Y,
        Q_S => Q_tile_type,
        Q1_X => q1_x,
        Q1_Y => q1_y,
        Q1_S => q1_s,
        Q2_X => q2_x, 
        Q2_Y => q2_y,
        Q2_S => q2_s,
        place_X0 => place_x0,
        place_Y0 => place_y0,
        place_0  => place_0,
        place_X1 => place_x1,
        place_Y1 => place_y1,
        place_1  => place_1,
        explode_X0 => explode_x0,
        explode_Y0 => explode_y0,
        explode_0  => sexplode0,
        explode_X1 => explode_x1,
        explode_Y1 => explode_y1,
        explode_1  => sexplode1

    );

    out_player_X0 <= player_X0 & zero4;
    out_player_Y0 <= player_Y0 & zero4;
    out_player_X1 <= player_X1 & zero4;
    out_player_Y1 <= player_Y1 & zero4;

END game;