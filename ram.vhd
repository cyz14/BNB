LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ram IS 
PORT(
		clock:			IN STD_LOGIC;
		--query
		Q_X, Q_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
		Q_S:				OUT STD_LOGIC_VECTOR(2 downto 0);
		--query2
		Q2_X, Q2_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
		Q2_S:				OUT STD_LOGIC_VECTOR(2 downto 0);
		--read map
		rst:				IN STD_LOGIC;
		--change
		place_X:			IN STD_LOGIC_VECTOR(4 downto 0);
		place_Y:			IN STD_LOGIC_VECTOR(4 downto 0);
		place:			IN STD_LOGIC;
		explode_X:		IN STD_LOGIC_VECTOR(4 downto 0);
		explode_Y:		IN STD_LOGIC_VECTOR(4 downto 0);
		explode:			IN STD_LOGIC
		--
);
END;

ARCHITECTURE map_ram OF ram IS

BEGIN
	PROCESS(clock)
		SUBTYPE map_tile IS STD_LOGIC_VECTOR(0 to 2);
		TYPE ram_type IS ARRAY(0 to 1023) OF map_tile;
		
		VARIABLE ram: ram_type;
		VARIABLE place_num: integer:=0;
		VARIABLE explode_num: integer:=0;
		CONSTANT wid: integer:=32;
		CONSTANT size: integer:=1024;
		VARIABLE i2: integer;
		VARIABLE i1: integer;
		VARIABLE s: integer:=0;
		
		TYPE ESTATE IS (EWAIT, EUP, ERIGHT, EDOWN, ELEFT);
    BEGIN
		place_num := conv_integer(place_Y & place_X);
		
		explode_num := conv_integer(explode_Y & explode_X);
		
		i2 := conv_integer(Q2_Y & Q2_X);
		i1 := conv_integer(Q_Y & Q_X);
		
		Q_S <= ram(i1);
		Q2_S <= ram(i2);
		
		IF clock'Event AND clock = '1' THEN
			if rst='0' then
				ram:=(  
						"000","000","000","100","000","000","000","001","001","000","000","000","000","000","001","000","100","000","000","001","000","000","000","000","001","000","000","000","001","000","101","001",
						"000","000","100","000","000","000","101","001","000","000","000","000","101","110","000","000","000","000","001","100","000","101","000","000","000","000","000","111","001","110","000","000",
						"000","000","000","000","000","111","101","000","000","000","110","100","000","000","000","000","000","000","000","000","000","101","000","000","000","001","110","001","000","000","000","100",
						"001","000","001","100","001","100","000","100","101","101","000","111","000","110","000","000","100","110","110","100","100","001","001","001","000","001","000","101","101","000","100","000",
						"000","000","000","000","000","000","100","000","100","111","000","001","001","100","000","110","000","100","000","000","111","000","000","000","101","101","111","000","000","100","000","000",
						"001","000","000","101","100","110","000","001","000","000","000","000","001","001","000","000","000","000","000","100","000","000","000","000","110","000","100","100","000","000","000","100",
						"000","000","000","000","101","000","100","000","000","110","000","000","000","000","000","101","101","000","000","110","000","000","000","000","000","001","000","000","000","000","001","000",
						"111","100","100","000","111","001","001","101","000","000","110","000","000","000","000","000","000","100","000","000","000","000","100","000","100","000","000","000","111","000","000","111",
						"001","000","000","000","000","101","000","000","000","000","001","000","000","000","000","101","001","000","000","000","111","001","001","101","111","000","000","001","000","000","000","000",
						"111","000","110","100","000","110","000","000","000","000","000","111","000","000","000","000","000","001","000","100","001","000","001","001","000","111","100","101","100","001","000","000",
						"000","101","110","100","100","000","000","000","000","000","000","101","000","000","000","001","100","000","000","000","000","000","000","000","001","100","000","000","000","000","000","000",
						"000","100","000","000","100","000","000","100","100","000","000","000","000","000","101","000","000","000","100","000","000","111","001","000","000","000","001","000","111","001","000","000",
						"000","000","000","000","100","001","000","000","000","000","000","000","000","100","101","000","000","000","000","001","110","000","000","100","101","100","000","000","000","000","000","110",
						"111","000","000","100","000","101","110","101","110","000","100","000","101","000","111","000","110","000","000","111","101","001","000","110","000","000","000","000","000","000","000","001",
						"000","000","111","110","001","000","100","000","000","000","000","000","000","000","000","100","000","000","110","000","110","000","000","100","111","110","000","000","100","000","000","000",
						"000","100","000","101","110","000","100","000","000","000","001","000","111","000","000","000","000","000","000","100","000","000","001","000","110","000","000","100","111","000","000","100",
						"000","000","000","000","100","000","001","000","000","000","000","100","001","000","000","000","100","000","000","001","000","000","000","000","001","000","001","101","000","000","000","111",
						"001","111","000","100","000","000","000","000","001","001","000","100","111","111","000","000","000","101","000","000","000","000","000","000","000","001","000","000","000","000","000","000",
						"100","100","000","001","101","000","000","001","000","000","110","000","100","000","000","000","000","001","101","110","000","000","000","000","100","000","000","100","001","000","000","001",
						"001","000","000","000","000","100","000","111","000","110","000","000","000","000","000","111","100","101","001","000","000","110","000","000","100","000","000","000","000","000","000","000",
						"111","000","110","000","100","110","110","000","000","000","000","000","000","000","000","110","110","101","000","001","000","000","001","001","001","110","100","000","100","001","001","100",
						"000","000","000","001","000","100","101","000","000","000","101","000","100","000","111","000","001","000","111","110","000","111","110","110","000","001","000","100","000","000","000","000",
						"000","110","000","000","000","000","000","111","100","000","000","100","110","000","000","000","001","100","000","000","111","000","000","000","000","000","000","000","001","000","001","000",
						"000","000","000","000","000","001","100","000","001","000","000","111","101","000","000","000","000","000","110","001","100","110","000","001","001","000","000","000","111","110","100","001",
						"000","000","101","000","000","100","100","000","000","000","000","000","000","000","000","101","100","100","000","000","000","110","100","000","000","000","101","001","000","000","000","000",
						"000","000","111","000","101","000","000","100","001","000","000","101","000","000","000","111","101","000","100","100","101","100","100","110","000","000","000","000","000","100","000","000",
						"000","000","000","000","000","000","000","000","000","000","000","000","100","000","000","000","000","000","000","000","000","000","000","111","000","000","000","000","000","101","000","100",
						"101","001","000","000","000","100","001","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000","000",
						"101","000","000","000","000","000","101","111","000","000","000","000","000","110","111","000","000","000","000","000","111","100","000","000","110","101","000","000","000","000","001","100",
						"000","001","000","000","000","000","000","111","000","000","101","000","000","000","000","101","000","000","000","110","000","000","000","110","000","000","000","100","000","001","100","000",
						"000","000","000","000","000","000","100","000","000","111","000","000","000","000","000","001","000","111","110","000","101","000","000","100","000","000","000","000","001","000","000","000",
						"001","001","111","000","101","000","000","000","000","000","000","000","000","100","000","110","000","111","101","000","100","000","000","001","101","000","000","000","000","000","000","000"
);
			else
				if place='1' and ram(place_num)="000" then 
					ram(place_num):="010"; 
				end if;
				if ram(explode_num)="010" and explode='1' then 
					ram(explode_num):="011";
					--up
					if explode_num>=wid then 
						if ram(explode_num-wid)/="100" then
							ram(explode_num-wid):="000"; 
						end if;
					end if;
					--down
					if explode_num<size-wid then 
						if ram(explode_num+wid)/="100" then
							ram(explode_num+wid):="000"; 
						end if;
					end if;
					
					if explode_num/=0 then 
						if ram(explode_num-1)/="100" then
							ram(explode_num-1):="000"; 
						end if;
					end if;
					
					if explode_num/=467 then 
						if ram(explode_num+1)/="100" then
							ram(explode_num+1):="000"; 
						end if;
					end if;
				end if;
				if ram(explode_num)="011" then
					s:=s+1;
					if s=10000000 then
						s:=0;
						ram(explode_num):="000";
					end if;
				end if;
			end if;
		END IF;
	END PROCESS;
END map_ram;