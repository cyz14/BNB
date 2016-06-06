LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY BNB IS PORT (
	clock_100:			IN 	STD_LOGIC;
	clock_24:			IN		STD_LOGIC;
	reset:				IN 	STD_LOGIC;
	r, g, b:				OUT 	STD_LOGIC_VECTOR(2 downto 0);
	hs, vs:				OUT 	STD_LOGIC;
	move:					OUT	STD_LOGIC_VECTOR(6 downto 0);
	key_data_in:		IN 	STD_LOGIC;
	key_clock:			IN		STD_LOGIC;
	out_player_x:		OUT		STD_LOGIC_VECTOR(8 downto 0);
	out_player_y:		OUT		STD_LOGIC_VECTOR(8 downto 0)
);
END BNB;

ARCHITECTURE BNB OF BNB IS
	
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
		sprite_X0, sprite_Y0: 	IN 	STD_LOGIC_VECTOR(8 downto 0);
		sprite_X1, sprite_Y1: 	IN 	STD_LOGIC_VECTOR(8 downto 0);
		free0, free1:				IN 	STD_LOGIC;
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
	
	COMPONENT keyboard PORT (
		datain, clkin: 	IN std_logic ; 						-- PS2 clk and data
		fclk, rst: 			IN std_logic ;  						-- filter clock
		scancode: 			OUT std_logic_vector(7 downto 0) -- scan code signal output
	) ;
	END COMPONENT;
	
	COMPONENT keyboard_id PORT (
		code: 			IN STD_LOGIC_VECTOR(7 downto 0);
		key_id : 		OUT STD_LOGIC_VECTOR(3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT timer_1st PORT (
		seconds    :    IN  std_logic_vector(7 downto 0);	-- total time
		rst        :    IN  std_logic;
		clk24      :    IN  std_logic; 							-- 24M clock
		s          :    OUT std_logic
	);
	END COMPONENT;
	
	COMPONENT test PORT (
    	clock, enable, reset: 					IN STD_LOGIC;
		key:                  					IN STD_LOGIC_VECTOR(3 downto 0);
		timer:                					IN STD_LOGIC;
		timer_x, timer_y:     					IN STD_LOGIC_VECTOR(4 downto 0);

		Q_tile_X, Q_tile_Y:	  					IN STD_LOGIC_VECTOR(4 downto 0);
		Q_tile_type:								OUT STD_LOGIC_VECTOR(0 to 1);
		 
		out_player_X0, out_player_Y0:			OUT STD_LOGIC_VECTOR(8 downto 0); -- player0 position
		out_player_X1, out_player_Y1:			OUT STD_LOGIC_VECTOR(8 downto 0); -- player1 position
		out_free0, out_free1:					OUT STD_LOGIC;
		
		out_place_x0, out_place_y0:			OUT STD_LOGIC_VECTOR(8 downto 0); 	 -- bubble 0 position
		out_explode_x0, out_explode_y0: 		OUT STD_LOGIC_VECTOR(8 downto 0);    -- explode center position
		out_qs: 										OUT std_logic_vector(1 downto 0)
	);
	END COMPONENT;
	
	COMPONENT seg7 PORT (
		code: 		IN std_logic_vector(3 downto 0);
		seg_out : 	OUT std_logic_vector(6 downto 0)
	);
	END COMPONENT;
	
	COMPONENT dao_rom PORT (
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT bubble_rom PORT (
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock			: IN STD_LOGIC  := '1';
		q				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT explo_rom PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock			: IN STD_LOGIC  := '1';
		q				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
	END COMPONENT;

	CONSTANT zero2:							STD_LOGIC_VECTOR(1 downto 0) := "00";
	CONSTANT zero3:							STD_LOGIC_VECTOR(2 downto 0) := "000";
	CONSTANT TOTAL_TIME:						STD_LOGIC_VECTOR(7 downto 0) := CONV_STD_LOGIC_VECTOR(120, 8);
	CONSTANT background_r: 					STD_LOGIC_VECTOR(2 downto 0) := zero3;
	CONSTANT background_g: 					STD_LOGIC_VECTOR(2 downto 0) := zero3;
	CONSTANT background_b: 					STD_LOGIC_VECTOR(2 downto 0) := zero3;
	
	constant player2_r    : STD_LOGIC_VECTOR(2 downto 0) := "000";
	constant player2_g    : STD_LOGIC_VECTOR(2 downto 0) := "010";
	constant player2_b    : STD_LOGIC_VECTOR(2 downto 0) := "000";
	
	--CONSTANT player_r:						  STD_LOGIC_VECTOR(2 downto 0):= "101";
	--CONSTANT player_g:						  STD_LOGIC_VECTOR(2 downto 0):= "001";
	--CONSTANT player_b:						  STD_LOGIC_VECTOR(2 downto 0):= "010";
	SIGNAL player_r:							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_g:							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_b:							STD_LOGIC_VECTOR(2 downto 0);
	
	SIGNAL clock_50: 							STD_LOGIC;
	SIGNAL clock_25: 							STD_LOGIC;
	
	SIGNAL video_on: 							STD_LOGIC;
	SIGNAL t_hsync, t_vsync: 				STD_LOGIC;
	SIGNAL H_count, V_count: 				STD_LOGIC_VECTOR(9 downto 0);
	
	SIGNAL key_reset:							STD_LOGIC;
	SIGNAL scancode:							STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL key:									STD_LOGIC_VECTOR(3 downto 0);
	
	SIGNAL bub_data:							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL explo_data:						STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL map_r, map_g, map_b: 			STD_LOGIC;
	SIGNAL bub_r, bub_g, bub_b:			STD_LOGIC;
	SIGNAL exp_r, exp_g, exp_b:			STD_LOGIC;
	
	-- world positon for current pixel
	SIGNAL world_X, world_Y:				STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL tile_X, tile_Y: 					STD_LOGIC_VECTOR(4 downto 0);
	
	SIGNAL player_X0, player_Y0:			STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL player_X1, player_Y1:			STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL free0, free1:						STD_LOGIC := '1';
	SIGNAL play_out:							STD_LOGIC;
	
	SIGNAL bubble_X0, bubble_Y0:		   STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL bubble_X1, bubble_Y1:		   STD_LOGIC_VECTOR(8 downto 0);
	
	SIGNAL explode_X, explode_Y:			STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL timer_X, timer_Y:				STD_LOGIC_VECTOR(4 downto 0) := "00000";
	SIGNAL timer_s:							STD_LOGIC;
	
	SIGNAL map_read_X, map_read_Y:		STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL map_data: 							STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL map_state:							STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL inner_state:						STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL logic_enable:						STD_LOGIC;
	
	SIGNAL address_32:						STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL q_dao:								STD_LOGIC_vector(0 downto 0);
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
		tile_num => map_data,
		red 		=> map_r,
		green 	=> map_g,
		blue 		=> map_b
	);
	
	player: draw_sprite PORT MAP (
		clock => clock_25,
		world_X  => world_X,
		world_Y  => world_Y,
		sprite_X0 => player_X0,
		sprite_Y0 => player_Y0,
		sprite_X1 => player_X1,
		sprite_Y1 => player_Y1,
		free0		=> free0,
		free1 	=> free1,
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
	
--	game_logic: game PORT MAP (
--		clock => clock_25,
--		enable => logic_enable,
--		map_data => map_data,
--		map_read_X => coll_read_X,
--		map_read_Y => coll_read_Y,
--		out_player_X => player_X,
--		out_player_Y => player_Y,
--		pad_state => pad_state
--	);

	t_timer: timer_1st PORT MAP (
		seconds 	=> TOTAL_TIME,
		rst 		=> reset,
		clk24 	=> clock_24,
		s 			=> timer_s
	);
	
	key_reset <= not reset;
	keyboard_scancode: keyboard PORT MAP (
		datain 	=> key_data_in,
		clkin  	=> key_clock,
		fclk 	 	=> clock_100,
		rst    	=> key_reset,
		scancode => scancode
	);
	
	key_id:	keyboard_id PORT MAP (
		code => scancode,
		key_id => key
	);
	
	seg0: seg7 PORT MAP (
		code => key,
		seg_out => move
	);
	
	test_logic: test PORT MAP(
		clock  => clock_25,
		enable => logic_enable,
		reset  => reset,
		key 	 => key,
		
		timer   => timer_s,
		timer_x => timer_x,
		timer_y => timer_y,
		
		Q_tile_X => map_read_X,
		Q_tile_Y => map_read_Y,
		Q_tile_type => map_state,
		
		out_player_X0 => player_X0,
		out_player_Y0 => player_Y0,
		out_player_X1 => player_X1,
		out_player_Y1 => player_Y1,
		out_free0 => free0,
		out_free1 => free1,
		
		out_place_x0 => bubble_X0,
		out_place_y0 => bubble_Y0,
		
		out_explode_x0 => explode_X,
		out_explode_y0 => explode_Y,
		out_qs => inner_state
	);
	
	address_32 <= V_count(4 downto 0) & H_count(4 downto 0);
	dao: dao_rom PORT MAP (
		address => address_32,
		clock => clock_25,
		q => q_dao
	);
	
	bubble: bubble_rom PORT MAP (
		address => address_32,
		clock => clock_25,
		q => bub_data
	);
	
	explo: explo_rom PORT MAP (
		address => address_32,
		clock  => clock_25,
		q => explo_data
	);
	
	bub_r <= bub_data(2);
	bub_g <= bub_data(1);
	bub_b <= bub_data(0);
	
	exp_r <= explo_data(2);
	exp_g <= explo_data(1);
	exp_b <= explo_data(0);
	
	logic_enable <= not t_vsync;
	
	map_read_X <= tile_X WHEN video_on = '1';-- ELSE coll_read_X;
	map_read_Y <= tile_Y WHEN video_on = '1';-- ELSE coll_read_Y;
	
	out_player_x <= player_X0;
	out_player_y <= player_Y0;
	
	PROCESS(clock_25)
	BEGIN
		IF rising_edge(clock_25) THEN
			IF video_on = '0' THEN
				r <= background_r;
				g <= background_g;
				b <= background_b;
			ELSE
				IF play_out = '1' THEN
					IF q_dao = "1" THEN
						r <= player_r;
						g <= player_g;
						b <= player_b;
					ELSE
						r <= "111";			  	
						g <= "011";
						b <= "001";
					END IF;
				ELSE
					CASE map_state IS 
						WHEN "01" =>
							r <= map_r & zero2;
							g <= map_g & zero2;
							b <= map_b & zero2;
						WHEN "10" =>
							r <= bub_r & zero2;
							g <= bub_g & zero2;
							b <= bub_b & zero2;
						WHEN "11" =>
							r <= exp_r & zero2;
							g <= exp_g & zero2;
							b <= exp_b & zero2;
						WHEN "00" => 
							r <= map_r & "00";
							g <= map_g & "00";
							b <= map_b & "00";
						WHEN others => 
							r <= background_r;
							g <= background_g;
							b <= background_b;
					END CASE;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END BNB;