LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY draw_sprite IS PORT (
	clock:					IN STD_LOGIC;
	world_X, world_Y:   	IN STD_LOGIC_VECTOR(8 downto 0);
	sprite_X, sprite_Y: 	IN STD_LOGIC_VECTOR(8 downto 0);
	red, green, blue:		OUT STD_LOGIC_VECTOR(2 downto 0);
	active:             	OUT STD_LOGIC
    );
END;

ARCHITECTURE draw_sprite OF draw_sprite IS
	COMPONENT player_rom PORT(
		clock:						IN STD_LOGIC;
		world_X, world_Y:			IN STD_LOGIC_VECTOR(8 downto 0);
		player_num:					IN STD_LOGIC_VECTOR(0 downto 0);
		data:							OUT STD_LOGIC_VECTOR(2 downto 0)
	);
	END COMPONENT;

	SIGNAL in_x, in_y: 				STD_LOGIC;
	SIGNAL sprite_x2, sprite_y2: 	STD_LOGIC_VECTOR(8 downto 0);

	SIGNAL player_num:				STD_LOGIC_VECTOR(0 downto 0);
	SIGNAL player_data:				STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_out:				STD_LOGIC;		-- = active
BEGIN
	-- FIXME - Pipeline and register this for speed
	sprite_x2 <= sprite_x + CONV_STD_LOGIC_VECTOR(16, 9);
	sprite_y2 <= sprite_y + CONV_STD_LOGIC_VECTOR(16, 9);

	in_x <= '1' WHEN world_x >= sprite_x AND world_x <= sprite_x2 ELSE '0';
	in_y <= '1' WHEN world_y >= sprite_y AND world_y <= sprite_y2 ELSE '0';

	player_num <= "0";
	
	player_out <= in_x AND in_y;
	active <= player_out;
	
	PROCESS(clock, player_out)
	BEGIN
		IF rising_edge(clock) THEN
			IF player_out = '1' THEN
				red <= '0' & player_data(2) & '0';
				green <= '0' & player_data(1) & '0';
				blue <= '1' & player_data(0) & '0';
			END IF;
		END IF;
	END PROCESS;
		
	player: player_rom PORT MAP (
		clock => clock,
		world_X => world_X,
		world_Y => world_Y,
		player_num => player_num,
		data => player_data
	);

END draw_sprite;
