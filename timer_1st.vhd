LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY timer_1st IS PORT (
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
	SIGNAL tmp_x, tmp_y:		STD_LOGIC_VECTOR(4 downto 0);
BEGIN
   s <= s_tmp;
	PROCESS(rst, clk24, valid_in)
		VARIABLE cnt : integer RANGE 0 TO 24000000;
		VARIABLE add : integer RANGE 0 to 1;
	BEGIN
		IF rst = '0' THEN
			cnt := 0;
			s_tmp <= '0';
			state <= SWAIT;
		elsif rising_edge(clk24) then
			cnt := cnt + add;
			case state is 
				when SWAIT => 
					add := 0;
					if valid_in = '1' then
						cnt := 0;
						s_tmp <= '0';
						tmp_x <= place_X;
						tmp_y <= place_Y;
						state <= STIME;
					end if;
				when STIME =>
					add := 1;
					if cnt = 23000000 then
						--state <= SOFF;
						s_tmp <= not s_tmp; --'1';
						out_place_X <= tmp_x;
						out_place_Y <= tmp_y;
						cnt := 0;
						if s_tmp = '0' then
							state <= SWAIT;
						end if;
						--state <= SEND;
					end if;
--				WHEN SEND =>
--					add := 1;
--					if cnt = 23000000 then
--						s_tmp <= '0';
--						state <= SWAIT;
--						tmp_x <= "00000";
--						tmp_y <= "00000";
--					end if;
			end case;
		end if;
	END PROCESS;
	
END timer_1st;