LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY BNB IS PORT (
	clock_100:			IN STD_LOGIC;
	reset:				IN STD_LOGIC;
	r, g, b:				OUT STD_LOGIC_VECTOR(2 downto 0);
	hs, vs:				OUT STD_LOGIC
);
END BNB;

ARCHITECTURE bhv of BNB is
	
	COMPONENT video_sync PORT (
		clock:									IN STD_LOGIC;	-- should be 25M Hz
		video_on, Horiz_Sync, Vert_Sync:	OUT STD_LOGIC;
		H_count_out, V_count_out:			OUT STD_LOGIC_VECTOR(9 downto 0)
	);
	END COMPONENT;
	
	COMPONENT draw_map PORT (
		world_X, world_Y:       IN		STD_LOGIC_VECTOR(8 downto 0);
		tile_num:               IN		STD_LOGIC_VECTOR(2 downto 0);
		red, green, blue:       OUT	STD_LOGIC
	);
	END COMPONENT;

	COMPONENT draw_sprite PORT (
		clock:						IN		STD_LOGIC;
		world_X, world_Y:   		IN		STD_LOGIC_VECTOR(8 downto 0);
		sprite_X, sprite_Y: 		IN		STD_LOGIC_VECTOR(8 downto 0);
		red, green, blue:			OUT	STD_LOGIC_VECTOR(2 downto 0);
		active:             		OUT	STD_LOGIC
	);
	END COMPONENT;
	
	COMPONENT map_rom PORT (
		clock:			IN		STD_LOGIC;
		tile_X:			IN		STD_LOGIC_VECTOR(4 downto 0);
		tile_Y:			IN 	STD_LOGIC_VECTOR(4 downto 0);
		data:				OUT 	STD_LOGIC_VECTOR(2 downto 0)
	);
	END COMPONENT;
	
	COMPONENT game PORT (
		clock, enable:              IN	STD_LOGIC;
		pad_state:                  IN 	STD_LOGIC_VECTOR(7 downto 0);
		map_data:                   IN	STD_LOGIC_VECTOR(2 downto 0);
		map_read_X, map_read_Y:     OUT	STD_LOGIC_VECTOR(4 downto 0);
		out_player_X, out_player_Y: OUT	STD_LOGIC_VECTOR(8 downto 0)
	);
	END COMPONENT;


	CONSTANT background_r: 					STD_LOGIC_VECTOR(2 downto 0) := "000";
	CONSTANT background_g: 					STD_LOGIC_VECTOR(2 downto 0) := "000";
	CONSTANT background_b: 					STD_LOGIC_VECTOR(2 downto 0) := "000";
	
	--CONSTANT player_r:						  STD_LOGIC_VECTOR(2 downto 0):= "101";
	--CONSTANT player_g:						  STD_LOGIC_VECTOR(2 downto 0):= "001";
	--CONSTANT player_b:						  STD_LOGIC_VECTOR(2 downto 0):= "010";
	SIGNAL player_r:							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_g:							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_b:							STD_LOGIC_VECTOR(2 downto 0);
	
	SIGNAL clock_50: 							  STD_LOGIC;
	SIGNAL clock_25: 							  STD_LOGIC;
	
	SIGNAL video_on: 							  STD_LOGIC;
	SIGNAL t_hsync, t_vsync: 				STD_LOGIC;
	SIGNAL H_count, V_count: 				STD_LOGIC_VECTOR(9 downto 0);
	
	SIGNAL map_r, map_g, map_b: 			STD_LOGIC;
	
	-- world positon for current pixel
	SIGNAL world_X, world_Y:				STD_LOGIC_VECTOR(8 downto 0);
	
	SIGNAL player_X, player_Y:				STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL play_out:							STD_LOGIC;
	SIGNAL tile_X, tile_Y: 					STD_LOGIC_VECTOR(4 downto 0);
	
	SIGNAL map_read_X, map_read_Y:		STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL map_data: 							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL coll_read_X, coll_read_Y: 	STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL logic_enable:						STD_LOGIC;
	SIGNAL pad_state: 						STD_LOGIC_VECTOR(7 downto 0);
	
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL clock_100'Event AND clock_100 = '1';	
		clock_50 <= NOT clock_50;
	END PROCESS;
	
	PROCESS
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
	
	tile_X <= world_X(8 downto 4);
	tile_Y <= world_Y(8 downto 4);
	
	dmap: draw_map PORT MAP (
		world_X  => world_X,
		world_Y  => world_Y,
		tile_num => map_data,
		red 		=> map_r,
		green 	=> map_g,
		blue 		=> map_b
	);
	
	player: draw_sprite PORT MAP (
		clock => clock_25,
		world_X  => world_X,
		world_Y  => world_Y,
		sprite_X => player_X,
		sprite_Y => player_Y,
		red 		=> player_r,
		green 	=> player_g,
		blue 		=> player_b,
		active 	=> play_out
	);
	
	maprom: map_rom PORT MAP (
		clock  => clock_25,
		tile_X => map_read_X,
		tile_Y => map_read_Y,
		data   => map_data
	);
	
	game_logic: game PORT MAP (
		clock => clock_25,
		enable => logic_enable,
		map_data => map_data,
		map_read_X => coll_read_X,
		map_read_Y => coll_read_Y,
		out_player_X => player_X,
		out_player_Y => player_Y,
		pad_state => pad_state
	);
	
	logic_enable <= not t_vsync;
	
	map_read_X <= tile_X WHEN video_on = '1' ELSE coll_read_X;
	map_read_Y <= tile_Y WHEN video_on = '1' ELSE coll_read_Y;
	
	PROCESS(clock_25)
	BEGIN
		IF rising_edge(clock_25) THEN
			IF video_on = '0' THEN
				r <= background_r;
				g <= background_g;
				b <= background_b;
			ELSE
				IF play_out = '1' THEN
					r <= player_r;
					g <= player_g;
					b <= player_b;
				ELSE
					r <= "0" & map_r & "0";
					g <= "0" & map_g & "0";
					b <= "0" & map_b & "0";
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END bhv;