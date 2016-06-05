LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
--USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY player_rom IS PORT(
	clock:						IN STD_LOGIC;
	world_X, world_Y:			IN STD_LOGIC_VECTOR(8 downto 0);
	player_num:					IN STD_LOGIC_VECTOR(0 downto 0);
	data:							OUT STD_LOGIC_VECTOR(2 downto 0)
);
END;

ARCHITECTURE player_rom OF player_rom IS
	SIGNAL sub_X, sub_Y: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL pixel_addr: 	STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL pixel_data: 	STD_LOGIC_VECTOR(2 downto 0);
	
	SUBTYPE pixel_type IS integer RANGE 0 TO 7;
	TYPE rom_type IS ARRAY(0 TO 511) OF pixel_type;
	CONSTANT sprite_rom : rom_type := (
	-- 1 -- Dao --
	7,7,7,7,7,7,7,7,7,7,0,7,7,7,7,7,
	7,7,7,7,0,0,3,3,3,3,1,0,0,7,7,7,
	7,7,0,0,3,3,3,3,3,7,7,3,0,0,0,7,
	7,0,0,0,3,1,1,3,3,3,0,0,0,7,0,0,
	7,0,3,0,0,4,0,0,0,0,6,0,1,3,0,7,
	7,7,0,3,0,6,6,0,6,0,6,0,3,0,0,7,
	7,7,0,1,3,3,0,0,0,0,1,3,0,4,7,7,
	7,7,7,0,0,0,0,0,0,0,3,0,0,7,7,7,
	7,7,1,0,6,3,1,0,7,0,3,0,7,0,0,7,
	7,7,0,7,6,3,3,0,0,3,3,0,6,0,7,7,
	7,7,7,7,0,0,3,3,3,3,1,7,7,7,7,7,
	7,7,7,7,7,7,0,0,3,0,0,7,7,7,7,7,
	7,7,7,7,7,0,0,0,0,0,0,0,7,7,7,7,
	7,7,7,7,7,7,3,7,7,3,3,7,7,7,7,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	
	-- 2 -- Dizni --
	7,7,7,7,7,7,7,7,7,3,7,7,7,7,7,7,
	7,0,0,0,0,4,4,4,4,4,0,0,0,7,7,7,
	7,7,0,4,4,4,4,6,6,6,6,0,0,0,0,7,
	7,7,0,4,4,4,4,4,4,4,4,6,0,0,7,7,
	7,0,0,6,4,4,4,4,4,4,4,4,0,0,7,7,
	7,7,4,6,0,0,4,6,6,0,0,0,0,7,7,7,
	7,7,4,0,0,7,6,6,6,0,7,0,4,7,7,7,
	7,7,7,4,4,3,0,6,6,0,7,4,4,7,7,7,
	7,7,7,7,0,0,0,6,6,0,0,4,7,7,7,7,
	7,7,7,7,0,0,0,0,0,0,4,4,7,7,7,7,
	7,7,7,0,0,0,4,4,0,4,4,0,4,7,7,7,
	7,7,0,7,0,4,4,0,0,0,4,0,0,7,7,7,
	7,0,0,7,0,4,4,0,0,0,4,4,7,7,7,7,
	7,7,7,7,7,0,0,0,7,6,0,0,7,7,7,7,
	7,7,7,7,7,0,7,7,7,0,7,7,0,7,7,7,
	7,7,7,7,7,0,7,7,7,7,7,7,7,7,7,7
	);



BEGIN
	sub_X <= world_X(3 downto 0);
	sub_Y <= world_Y(3 downto 0);
	
	pixel_addr <= player_num & sub_Y & sub_X;
	
    PROCESS(clock, pixel_addr)
        VARIABLE pixel: pixel_type;
    BEGIN
		IF rising_edge(clock) THEN
			pixel := sprite_rom(to_integer(unsigned(pixel_addr)));
			CASE pixel IS
				WHEN 0 => pixel_data <= "000";
				WHEN 1 => pixel_data <= "001";
				WHEN 2 => pixel_data <= "010";
				WHEN 3 => pixel_data <= "011";
				WHEN 4 => pixel_data <= "100";
				WHEN 5 => pixel_data <= "101";
				WHEN 6 => pixel_data <= "110";
				WHEN 7 => pixel_data <= "111";
				WHEN OTHERS => pixel_data <= "000";
			END CASE;
		END IF;
    END PROCESS;

END player_rom;