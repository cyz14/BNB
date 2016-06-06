LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITU coll_det IS PORT (
	clock:					IN		STD_LOGIC;
	valid_in:				IN		STD_LOGIC;
	sprite_X, sprite_Y:	IN		STD_LOGIC_VECTOR(8 downto 0);
	map_data:				IN		STD_LOGIC_VECTOR(2 downto 0);
	collision:				OUT	STD_LOGIC;
	valid_out:				OUT	STD_LOGIC
	);
END;

ARCHITECTURE coll_det OF coll_det IS
	TYPE CHECK_TYPE IS (check_INIT, check_L, check_R, check_U, check_D);
	SIGNAL read_X, read_Y:	STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL check:				CHECK_TYPE;
	SIGNAL result:				STD_LOGIC;
BEGIN
	
	PROCESS(clock)
	BEGIN
		IF rising_edge(clock) THEN
			IF valid_in = '1' THEN
				check <= CHECK_L;
				result <= '0';
				valid_out <= '0';
				read_X <= CONV_STD_LOGIC_VECTOR(0, 9);
				read_Y <= CONV_STD_LOGIC_VECTOR(0, 9);
			END IF;
			
		END IF;
	END PROCESS;


END coll_det;