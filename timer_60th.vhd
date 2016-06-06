LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY timer_60th IS PORT(
		reset				:		IN  std_logic;
		clk24				:		IN  std_logic; 		-- 24M clock
		stime          :		OUT std_logic
	);
END timer_60th;

ARCHITECTURE timer_60th OF timer_60th IS
	SIGNAL s_tmp : std_logic;
	SIGNAL cnt: STD_LOGIC_VECTOR(18 downto 0) := CONV_STD_LOGIC_VECTOR(400000, 19);
BEGIN
	stime <= s_tmp;
	
	PROCESS (reset, clk24)
	BEGIN
		IF reset = '0' THEN
			cnt <= CONV_STD_LOGIC_VECTOR(0, 19);
		ELSIF rising_edge(clk24) THEN
			cnt <= cnt + CONV_STD_LOGIC_VECTOR(1, 19);
			IF cnt > CONV_STD_LOGIC_VECTOR(399998) AND cnt < CONV_STD_LOGIC_VECTOR(400000) THEN
				cnt <= CONV_STD_LOGIC_VECTOR(0, 19);
				s_tmp <= '1';
			ELSE
				s_tmp <= '0';
			END IF;
		END IF;
	END PROCESS;
END timer_60th;