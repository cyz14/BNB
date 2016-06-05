library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY Keyboard IS PORT (
	datain, clkin: 	IN std_logic ; 	-- PS2 clk and data
	fclk, rst: 			IN std_logic ;  		-- filter clock
	scancode: 			OUT std_logic_vector(7 downto 0) -- scan code signal output
	) ;
END;

ARCHITECTURE rtl OF Keyboard IS
TYPE state_type IS (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
SIGNAL data, clk, clk1, clk2, odd, fok : std_logic ; -- 毛刺处理内部信号, odd为奇偶校验
SIGNAL code : std_logic_vector(7 downto 0) ; 
SIGNAL state : state_type ;
BEGIN
    -- 去除尖峰
	clk1 <= clkin WHEN rising_edge(fclk) ;
	clk2 <= clk1 WHEN rising_edge(fclk) ;
	clk <= (not clk1) and clk2 ;
	
	data <= datain WHEN rising_edge(fclk) ;
	
    -- 偶校验
	odd <= code(0) xor code(1) xor code(2) xor code(3) 
		xor code(4) xor code(5) xor code(6) xor code(7) ;
	
	scancode <= code WHEN fok = '1' ;
	
	PROCESS(rst, fclk)
	BEGIN
		IF rst = '1' THEN
			state <= delay ;
			code <= (others => '0') ;
			fok <= '0' ;
		ELSIF rising_edge(fclk) THEN
			fok <= '0' ;
			CASE state IS
				WHEN delay =>
					state <= start ;
				WHEN start =>
					IF clk = '1' THEN
						IF data = '0' THEN
							state <= d0 ;
						ELSE
							state <= delay ;
						END IF;
					END IF;
				WHEN d0 =>
					IF clk = '1' THEN
						code(0) <= data ;
						state <= d1 ;
					END IF;
				WHEN d1 =>
					IF clk = '1' THEN
						code(1) <= data ;
						state <= d2 ;
					END IF;
				WHEN d2 =>
					IF clk = '1' THEN
						code(2) <= data ;
						state <= d3 ;
					END IF;
				WHEN d3 =>
					IF clk = '1' THEN
						code(3) <= data ;
						state <= d4 ;
					END IF;
				WHEN d4 =>
					IF clk = '1' THEN
						code(4) <= data ;
						state <= d5 ;
					END IF;
				WHEN d5 =>
					IF clk = '1' THEN
						code(5) <= data ;
						state <= d6 ;
					END IF ;
				WHEN d6 =>
					IF clk = '1' THEN
						code(6) <= data ;
						state <= d7 ;
					END IF ;
				WHEN d7 =>
					IF clk = '1' THEN
						code(7) <= data ;
						state <= parity ;
					END IF ;
				WHEN parity =>
					IF clk = '1' THEN
						IF (data xor odd) = '1' THEN
							state <= stop ;
						ELSE
							state <= delay ;
						END IF;
					END IF;

				WHEN stop =>
					IF clk = '1' THEN
						IF data = '1' THEN
							state <= finish;
						ELSE
							state <= delay;
						END IF;
					END IF;

				WHEN finish =>
					state <= delay ;
					fok <= '1' ;
				WHEN others =>
					state <= delay ;
			END CASE ; 
		END IF ;
	END PROCESS ;
END rtl ;

