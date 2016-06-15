LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY BNB IS PORT (
    clock_100:          IN  STD_LOGIC;
    clock_24:           IN  STD_LOGIC;
    reset:              IN  STD_LOGIC;
    r, g, b:            OUT STD_LOGIC_VECTOR(2 downto 0);
    hs, vs:             OUT STD_LOGIC;
    move0, move1:       OUT STD_LOGIC_VECTOR(6 downto 0);
    key_data_in:        IN  STD_LOGIC;
    explode_out:        OUT STD_LOGIC;
    key_clock:          IN  STD_LOGIC --;timer_in:  in std_logic
);
END BNB;

ARCHITECTURE BNB OF BNB IS

    COMPONENT test PORT (
        clock, reset:                    IN STD_LOGIC;
        enable:                          IN STD_LOGIC;
        key0, key1:                      IN STD_LOGIC_VECTOR(3 downto 0);
        Q_tile_X, Q_tile_Y:              IN STD_LOGIC_VECTOR(4 downto 0);
        Q_tile_type:                     OUT STD_LOGIC_VECTOR(0 to 2);
        explode:                         OUT STD_LOGIC;
        out_player_X0, out_player_Y0:    OUT STD_LOGIC_VECTOR(8 downto 0); -- player0 position
        out_player_X1, out_player_Y1:    OUT STD_LOGIC_VECTOR(8 downto 0); -- player1 position
        out_free0, out_free1:            OUT STD_LOGIC
    );
    END COMPONENT;
    
    COMPONENT video_sync PORT (
        clock:                              IN  STD_LOGIC;    -- should be 25M Hz
        video_on, Horiz_Sync, Vert_Sync:    OUT STD_LOGIC;
        H_count_out, V_count_out:           OUT STD_LOGIC_VECTOR(9 downto 0)
    );
    END COMPONENT;
    
    COMPONENT draw_map PORT (
        world_X, world_Y:           IN  STD_LOGIC_VECTOR(8 downto 0);
        tile_num:                   IN  STD_LOGIC_VECTOR(2 downto 0);
        red, green, blue:           OUT STD_LOGIC
    );
    END COMPONENT;
    
    COMPONENT draw_sprite PORT (
        clock:                      IN  STD_LOGIC;
        world_X, world_Y:           IN  STD_LOGIC_VECTOR(8 downto 0);
        sprite_X0, sprite_Y0:       IN  STD_LOGIC_VECTOR(8 downto 0);
        sprite_X1, sprite_Y1:       IN  STD_LOGIC_VECTOR(8 downto 0);
        free0, free1:               IN  STD_LOGIC;
        red, green, blue:           OUT STD_LOGIC_VECTOR(2 downto 0);
        active0:                    OUT STD_LOGIC;
        active1:                    OUT STD_LOGIC
    );
    END COMPONENT;
    
    COMPONENT map_rom PORT (
        clock:                      IN  STD_LOGIC;
        tile_X:                     IN  STD_LOGIC_VECTOR(4 downto 0);
        tile_Y:                     IN  STD_LOGIC_VECTOR(4 downto 0);
        data:                       OUT STD_LOGIC_VECTOR(2 downto 0)
    );
    END COMPONENT;
    
    COMPONENT keyboard PORT (
        datain, clkin:          IN  std_logic ;      -- PS2 clk and data
        fclk, rst:              IN  std_logic ;  -- filter clock
        scancode:               OUT std_logic_vector(7 downto 0) -- scan code signal output
    ) ;
    END COMPONENT;

    COMPONENT keyboard_id PORT (
        clk:        IN  std_logic;
        rst:        IN  std_logic;
        code:       IN  std_logic_vector(7 downto 0);
        key_id0:    OUT std_logic_vector(3 downto 0);
        key_id1:    OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT;

    COMPONENT seg7 PORT (
        code:                   IN  std_logic_vector(3 downto 0);
        seg_out :               OUT std_logic_vector(6 downto 0)
    );
    END COMPONENT;

    COMPONENT dao_rom PORT (
        address:                IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        clock:                  IN  STD_LOGIC := '1';
        q:                      OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT dizni_rom PORT (    
        address:        IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        clock:          IN  STD_LOGIC := '1';
        q:              OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
    );
    END COMPONENT;
    
    CONSTANT zero2:         STD_LOGIC_VECTOR(1 downto 0) := "00";
    CONSTANT zero3:         STD_LOGIC_VECTOR(2 downto 0) := "000";
    CONSTANT TOTAL_TIME:    STD_LOGIC_VECTOR(7 downto 0) := CONV_STD_LOGIC_VECTOR(120, 8);
    CONSTANT background_r:  STD_LOGIC_VECTOR(2 downto 0) := zero3;
    CONSTANT background_g:  STD_LOGIC_VECTOR(2 downto 0) := zero3;
    CONSTANT background_b:  STD_LOGIC_VECTOR(2 downto 0) := zero3;
    constant player0_r:     STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant player0_g:     STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant player0_b:     STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant player1_r:     STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant player1_g:     STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant player1_b:     STD_LOGIC_VECTOR(2 downto 0) := "001";
    
    SIGNAL player_r:                        STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL player_g:                        STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL player_b:                        STD_LOGIC_VECTOR(2 downto 0);
    
    SIGNAL clock_50:                        STD_LOGIC;
    SIGNAL clock_25:                        STD_LOGIC;
    
    SIGNAL video_on:                        STD_LOGIC;
    SIGNAL t_hsync, t_vsync:                STD_LOGIC;
    SIGNAL H_count, V_count:                STD_LOGIC_VECTOR(9 downto 0);
    
    SIGNAL key_reset:                       STD_LOGIC;
    SIGNAL scancode:                        STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL key0, key1:                             STD_LOGIC_VECTOR(3 downto 0);
    
    SIGNAL bub_data:                        STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL explo_data:                      STD_LOGIC_VECTOR(2 downto 0);
    
    SIGNAL map_r, map_g, map_b:             STD_LOGIC;
    SIGNAL bub_r, bub_g, bub_b:             STD_LOGIC;
    SIGNAL exp_r, exp_g, exp_b:             STD_LOGIC;
    -- world positon for current pixel
    SIGNAL world_X, world_Y:                STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL tile_X, tile_Y:                  STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL player_X0, player_Y0:            STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL player_X1, player_Y1:            STD_LOGIC_VECTOR(8 downto 0);
    SIGNAL free0, free1:                    STD_LOGIC := '1';
    SIGNAL play_out0:                       STD_LOGIC;
    SIGNAL play_out1:                       STD_LOGIC;
    
    SIGNAL explode_X, explode_Y:            STD_LOGIC_VECTOR(8 downto 0);
    
    SIGNAL map_read_X, map_read_Y:          STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL map_state:                       STD_LOGIC_VECTOR(2 downto 0);
    
    SIGNAL logic_enable:                    STD_LOGIC;
    
    SIGNAL address_32:                      STD_LOGIC_VECTOR(9 downto 0);
    
    SIGNAL q_dao:                           STD_LOGIC_vector(0 downto 0);
    SIGNAL q_dizni:                         STD_LOGIC_vector(0 downto 0);
BEGIN

    PROCESS -- 100M to 50M
    BEGIN
        WAIT UNTIL clock_100'Event AND clock_100 = '1';    
        clock_50 <= NOT clock_50;
    END PROCESS;
    PROCESS --  50M to 25M
    BEGIN
        WAIT UNTIL clock_50'Event AND clock_50 = '1';    
        clock_25 <= NOT clock_25;
    END PROCESS;
    sync: Video_Sync PORT MAP (
        clock => clock_25,
        horiz_sync => t_hsync,
        vert_sync => t_vsync,
        video_on => video_on,
        H_count_out => H_count,
        V_count_out => V_count
    );
    hs <= t_hsync;
    vs <= t_vsync;
    world_X <= H_count(9 downto 1);
    world_Y <= V_count(9 downto 1);
    tile_X <= H_count(9 downto 5);
    tile_Y <= V_count(9 downto 5);
    dmap: draw_map PORT MAP (
        world_X  => world_X,
        world_Y  => world_Y,
        tile_num => map_state,
        red   => map_r,
        green => map_g,
        blue  => map_b
    );
    player: draw_sprite PORT MAP (
        clock => clock_25,
        world_X => world_X,
        world_Y => world_Y,
        sprite_X0 => player_X0,
        sprite_Y0 => player_Y0,
        sprite_X1 => player_X1,
        sprite_Y1 => player_Y1,
        free0 => free0,
        free1 => free1,
        red   => player_r,
        green => player_g,
        blue  => player_b,
        active0 => play_out0,
        active1 => play_out1
    );
    
    key_reset <= not reset;
    keyboard_scancode: keyboard PORT MAP (
        datain => key_data_in,
        clkin => key_clock,
        fclk => clock_100,
        rst => key_reset,
        scancode => scancode
    );
    key_id: keyboard_id PORT MAP (
        clk  => clock_100,
        code => scancode,
        rst  => key_reset,
        key_id0 => key0,
        key_id1 => key1
    );
    seg0: seg7 PORT MAP (
        code => key0,
        seg_out => move0
    );
	 seg1: seg7 PORT MAP (
	     code => key1,
		  seg_out => move1
	 );
    test_logic: test PORT MAP(
        clock  => clock_25,
        reset  => reset,
        enable => logic_enable,
        key0 => key0,
        key1 => key1,
        explode => explode_out,
        Q_tile_X => map_read_X,
        Q_tile_Y => map_read_Y,
        Q_tile_type => map_state,
        out_player_X0 => player_X0,
        out_player_Y0 => player_Y0,
        out_player_X1 => player_X1,
        out_player_Y1 => player_Y1,
        out_free0 => free0,
        out_free1 => free1
    );
    
    address_32 <= V_count(4 downto 0) & H_count(4 downto 0);
    dao: dao_rom PORT MAP (
        address => address_32,
        clock => clock_25,
        q => q_dao
    );
    dizni: dizni_rom PORT MAP (
        address => address_32,
        clock => clock_25,
        q => q_dizni
    );
--    bub_r <= bub_data(2);
--    bub_g <= bub_data(1);
--    bub_b <= bub_data(0);
    logic_enable <= not t_vsync;
    map_read_X <= tile_X WHEN video_on = '1';
    map_read_Y <= tile_Y WHEN video_on = '1';
    
    PROCESS(clock_25)
    BEGIN
        IF rising_edge(clock_25) THEN
            IF video_on = '0' THEN
                r <= background_r;
                g <= background_g;
                b <= background_b;
            ELSE
                IF play_out0 = '1' THEN
                    IF q_dao = "1" THEN
                        r <= player0_r;
                        g <= player0_g;
                        b <= player0_b;
                    ELSE
                        r <= "111";
                        g <= "111";
                        b <= "111";
                    END IF;
                ELSIF play_out1 = '1' THEN
                    IF q_dizni = "1" THEN
                        r <= player1_r;
                        g <= player1_g;
                        b <= player1_b;
                    ELSE
                        r <= "111";
                        g <= "111";
                        b <= "111";
                    END IF;
                ELSE
--                    IF map_state = "010" THEN
--                        r <= bub_r & zero2;
--                        g <= bub_g & zero2;
--                        b <= bub_b & zero2;
--                    ELSE
                        r <= map_r & "00";
                        g <= map_g & "00";
                        b <= map_b & "00";
--                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END BNB;