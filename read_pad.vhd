LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY read_pad IS PORT (
	clock:				IN  STD_LOGIC;
	pad_data:			OUT STD_LOGIC;
	pad_clock:			OUT STD_LOGIC;
	pad_load:			OUT STD_LOGIC;
	pad_state:			OUT STD_LOGIC_VECTOR(7 downto 0)
);
END;

ARCHITECTURE read_pad OF read_pad IS

BEGIN
	PROCESS (clock)
	BEGIN
		
		
	END PROCESS;


END read_pad;