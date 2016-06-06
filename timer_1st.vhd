LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY timer_1st IS PORT (
		seconds    :    IN  std_logic_vector(7 downto 0);	-- total time
		rst        :    IN  std_logic;
		clk24      :    IN  std_logic; 							-- 24M clock
		s          :    OUT std_logic
	);
end timer_1st;

ARCHITECTURE timer_1st OF timer_1st IS
	SIGNAL s_tmp : std_logic;
	SIGNAL total : std_logic_vector(7 downto 0) := seconds;
BEGIN
   s <= s_tmp;
	PROCESS(rst, clk24)
		VARIABLE cnt : integer RANGE 0 TO 24000000;
	BEGIN
		IF rst = '0' THEN
			cnt := 0;
		elsif rising_edge(clk24) then
			cnt := cnt + 1;
			total <= total - 1;
			if cnt = 24000000 then
				cnt := 0;
				if total > 0 AND total < 10 then
					s_tmp <= '1';
				else
					s_tmp <= '0';
				end if;
			else
				s_tmp <= '0';
			end if;
		end if;
	END PROCESS;
END timer_1st;