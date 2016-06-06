LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY draw_sprite IS PORT (
	clock:						IN STD_LOGIC;
	world_X, world_Y:   		IN STD_LOGIC_VECTOR(8 downto 0);
	sprite_X0, sprite_Y0: 	IN STD_LOGIC_VECTOR(8 downto 0);
	sprite_X1, sprite_Y1: 	IN STD_LOGIC_VECTOR(8 downto 0);
	free0, free1:				IN STD_LOGIC;
	red, green, blue:			OUT STD_LOGIC_VECTOR(2 downto 0);
	active:             		OUT STD_LOGIC
    );
END;

ARCHITECTURE draw_sprite OF draw_sprite IS
	COMPONENT player_rom PORT(
		clock:						IN STD_LOGIC;
		world_X, world_Y:			IN STD_LOGIC_VECTOR(8 downto 0);
		player_num:					IN STD_LOGIC_VECTOR(1 downto 0);
		data:							OUT STD_LOGIC_VECTOR(2 downto 0)
	);
	END COMPONENT;

	SIGNAL in_x0, in_y0:				STD_LOGIC;
	SIGNAL in_x1, in_y1: 			STD_LOGIC;
	
	SIGNAL sprite_x2, sprite_y2: 	STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL sprite_x3, sprite_y3: 	STD_LOGIC_VECTOR(8 downto 0);

	SIGNAL player_num:				STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL player_data:				STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL player_out1:				STD_LOGIC;		-- = active
	SIGNAL player_out0:				STD_LOGIC;
	SIGNAl player_out:				STD_LOGIC;
BEGIN
	-- FIXME - Pipeline and register this for speed
	sprite_x2 <= sprite_x0 + CONV_STD_LOGIC_VECTOR(16, 9);
	sprite_y2 <= sprite_y0 + CONV_STD_LOGIC_VECTOR(16, 9);

	sprite_x3 <= sprite_x1 + CONV_STD_LOGIC_VECTOR(16, 9);
	sprite_y3 <= sprite_y1 + CONV_STD_LOGIC_VECTOR(16, 9);
	
	in_x0 <= '1' WHEN world_x >= sprite_X0 AND world_x <= sprite_x2 ELSE '0';
	in_y0 <= '1' WHEN world_y >= sprite_Y0 AND world_y <= sprite_y2 ELSE '0';
	in_x1 <= '1' WHEN world_x >= sprite_X1 AND world_x <= sprite_x3 ELSE '0';
	in_y1 <= '1' WHEN world_y >= sprite_Y1 AND world_y <= sprite_y3 ELSE '0';

	player_out0 <= (in_x0 AND in_y0);
	player_out1 <= (in_x1 AND in_y1);
	player_out <= player_out0 OR player_out1;
	active <= player_out;
	
	PROCESS(clock)
	BEGIN
		IF player_out0 = '1' THEN
			IF free0 = '1' THEN
				player_num <= "00";
			ELSE 
				player_num <= "10";
			END IF;
		ELSIF player_out1 = '1' THEN
			IF free1 = '1' THEN
				player_num <= "01";
			ELSE
				player_num <= "11";
			END IF;
		END IF;
	END PROCESS;	
	
	PROCESS(clock, player_out)
	BEGIN
		IF rising_edge(clock) THEN
			IF player_out = '1' THEN
				red 	<= player_data(2) & "00";
				green <= player_data(1) & "00";
				blue 	<= player_data(0) & "00";
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
