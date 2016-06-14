LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY timer_1st IS PORT (
		place		:		IN  std_logic;
		valid_in	:		IN  std_logic;
		rst			:		IN  std_logic;
		clk24  		:		IN  std_logic; 							-- 24M clock
		place_X		:		IN  std_logic_vector(4 downto 0);
		place_Y		:		IN  std_logic_vector(4 downto 0);
		out_place_X	:		OUT std_logic_vector(4 downto 0);
		out_place_Y	:	 	OUT std_logic_vector(4 downto 0);
		s          	:		OUT std_logic
	);
END timer_1st;

ARCHITECTURE timer_1st OF timer_1st IS
	SIGNAL s_tmp : std_logic;
	TYPE timer_state IS (SWAIT, STIME);
	SIGNAL state: timer_state := SWAIT;
	
BEGIN
   s <= s_tmp;
	
	PROCESS(rst, clk24, valid_in)
		VARIABLE cnt : integer RANGE 0 TO 24000000;
	BEGIN
		IF rst = '0' THEN
			cnt := 0;
			s_tmp <= '0';
			state <= SWAIT;
		elsif rising_edge(clk24) then
			case state is 
				when SWAIT => 
					if valid_in = '1' then
						cnt := 0;
						s_tmp <= '0';
						state <= STIME;
					end if;
				when STIME =>
					cnt := cnt + 1;
					if cnt = 23000000 then
						--state <= SOFF;
						s_tmp <= '1';
					end if;
			end case;
		end if;
	END PROCESS;
	
END timer_1st;