LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ram IS 
PORT(
		clock:			IN STD_LOGIC;
		--query
		Q_X, Q_Y:		IN STD_LOGIC_VECTOR(0 to 3);
		Q_S:			OUT STD_LOGIC_VECTOR(0 to 1);
--		Q_valid_in:		IN STD_LOGIC;
--		Q_valid_out:	BUFFER STD_LOGIC;
		--query2
		Q2_X, Q2_Y:	IN STD_LOGIC_VECTOR(0 to 3);
		Q2_S:			OUT STD_LOGIC_VECTOR(0 to 1);
		--read map
		rst:			IN STD_LOGIC;
		--change
		place_X:		IN STD_LOGIC_VECTOR(0 to 3);
		place_Y:		IN STD_LOGIC_VECTOR(0 to 3);
		place:			IN STD_LOGIC;
		explode_X:		IN STD_LOGIC_VECTOR(0 to 3);
		explode_Y:		IN STD_LOGIC_VECTOR(0 to 3);
		explode:		IN STD_LOGIC
		--
);
END;

ARCHITECTURE map_ram OF ram IS

BEGIN
--	process(clock)
--	variable valid_in: std_logic:='0';
--	begin
--	IF clock'Event AND clock = '1' THEN
--		IF rst='1' then
--			valid_in:='0';
--		ELSE
--			if valid_in='1' then
--				valid_in:='0';
--				Q_valid_out<='1';
--			end if;			
--			if Q_valid_in='1' then
--				valid_in:='1';
--				Q_valid_out<='0';
--			end if;
--			if Q_valid_out='1' then
--			Q_valid_out<='0';
--			end if;
--		END IF;
--	end if;
--	end process;

	PROCESS(clock)
		SUBTYPE map_tile IS STD_LOGIC_VECTOR(0 to 1);
		TYPE ram_type IS ARRAY(0 to 255) OF map_tile;
		variable ram: ram_type;
		variable place_num: integer:=0;
		variable explode_num: integer:=0;
		constant wid: integer:=16;
		constant size: integer:=256;
		variable i2: integer;
		variable i1: integer;
		variable s: integer:=0;
    BEGIN
		place_num:=conv_integer(place_X & place_Y);
		explode_num:=conv_integer(explode_X & explode_Y);
		i2:=conv_integer(Q2_X & Q2_Y);
		i1:=conv_integer(Q_X & Q_Y);
		Q_S<=ram(i1);
		Q2_S<=ram(i2);
		IF clock'Event AND clock = '1' THEN
			if rst='1' then
				ram:=(  "00", "01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"01", "01", "01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "01", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",
						"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"
						);
			else
				if place='1' and ram(place_num)="00" then 
					ram(place_num):="10"; 
				end if;
				if ram(explode_num)="10" and explode='1' then 
					ram(explode_num):="11";
					if explode_num>=wid then ram(explode_num-wid):="00"; end if;
					if explode_num<size-wid then ram(explode_num+wid):="00"; end if;
					if (explode_num mod wid)/=0 then ram(explode_num-1):="00"; end if;
					if (explode_num+1) mod wid /=0 then ram(explode_num+1):="00"; end if;
				end if;
				if ram(explode_num)="11" then
					s:=s+1;
					if s=10 then
						s:=0;
						ram(explode_num):="00";
					end if;
				end if;
			end if;
		END IF;
	END PROCESS;
END map_ram;