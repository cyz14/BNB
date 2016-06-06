library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity keyboard_id is
port(
code: in std_logic_vector(7 downto 0);
key_id : out std_logic_vector(3 downto 0)
);
end keyboard_id;

architecture behave of keyboard_id is

begin
process(code)
begin
	case code is 
		--player 1
		when  "00010010" =>	-- 0X12
			key_id<="0101";
		when "00011101" =>   -- 0X1d
			key_id<="0001"; -- UP
		when "00011100" =>	-- 0X1c
			key_id<="0010";	-- Left
		when "00011011" =>	-- 0X1b
			key_id<="0011";	-- Down	
		when "00100011" =>	-- 0X23
			key_id<="0100";	-- Right
		--player 2
		when "01011001" =>	-- 0X59
			key_id<="1010";		
		when "01001101" =>	-- 0X4d
			key_id<="0110";		
		when "01001011" =>
			key_id<="0111";		
		when "01001100" =>
			key_id<="1000";		
		when "01010010" =>
			key_id<="1001";		
		--Esc
		when "00000000" =>
			key_id<="0000";
		when "01110110" =>
			key_id<="1111";	
		--choose	
		when "00010110" =>
			key_id<="1011";		
		when "00011110" =>
			key_id<="1100";
		--enter		
		when "01011010" =>
			key_id<="1101";		
		when others =>
			key_id<="0000";
		end case;
	end process;
	

 end behave;