library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY keyboard_id IS PORT(
    clk:     IN  std_logic;
    rst:     IN  std_logic;
    code:    IN  std_logic_vector(7 downto 0);
    key_id0: OUT std_logic_vector(3 downto 0);
    key_id1: OUT std_logic_vector(3 downto 0)
);
END keyboard_id;

architecture behave of keyboard_id is
    type state_type is ( WAITING, PRESSED);
    signal state : state_type;
begin
    
process(code)
begin
    if rst = '1' then
        state <= WAITING;
    elsif rising_edge(clk) then
        case state is 
            when WAITING =>
                case code is 
                    --player 1
                    when  "00010010" =>       -- 0X12
                        key_id0 <= "0101";
                    when "00011101" =>        -- 0X1d
                        key_id0 <= "0001";    -- UP
                    when "00011100" =>        -- 0X1c
                        key_id0 <= "0010";    -- Left
                    when "00011011" =>        -- 0X1b
                        key_id0 <= "0011";    -- Down    
                    when "00100011" =>        -- 0X23
                        key_id0 <= "0100";    -- Right
                    --------- player 2 ----------------------
                    when "01011001" =>        -- 0X59
                        key_id1 <= "1010";    -- place
                    when "01001101" =>        -- 0X4d
                        key_id1 <= "0110";    -- UP
                    when "01001011" =>
                        key_id1 <= "0111";    -- Left
                    when "01001100" =>
                        key_id1 <= "1000";    -- Down
                    when "01010010" =>
                        key_id1 <= "1001";    -- Right
                    when "11110000" =>
                        state <= PRESSED;
                    when others =>
                        null;
                end case;
            When PRESSED =>
                case code is 
                    --player 1
                    when  "00010010" =>       -- 0X12
                        key_id0 <= "0000";
                        state <= WAITING;
                    when "00011101" =>        -- 0X1d
                        key_id0 <= "0000";    -- UP
                        state <= WAITING;
                    when "00011100" =>        -- 0X1c
                        key_id0 <= "0000";    -- Left
                        state <= WAITING;
                    when "00011011" =>        -- 0X1b
                        key_id0 <= "0000";    -- Down    
                        state <= WAITING;
                    when "00100011" =>        -- 0X23
                        key_id0 <= "0000";    -- Right
                        state <= WAITING;
                    --------- player 2 ----------------------
                    when "01011001" =>        -- 0X59
                        key_id1 <= "0000";    -- place
                        state <= WAITING;
                    when "01001101" =>        -- 0X4d
                        key_id1 <= "0000";    -- UP
                        state <= WAITING;
                    when "01001011" =>
                        key_id1 <= "0000";    -- Left
                        state <= WAITING;
                    when "01001100" =>
                        key_id1 <= "0000";    -- Down
                        state <= WAITING;
                    when "01010010" =>
                        key_id1 <= "0000";    -- Right
                        state <= WAITING;
                    ----------------------------------------
                    when others =>
                        null;
                end case;
        end case;
    end if;
end process;
        
end behave;