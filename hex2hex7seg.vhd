-------------------------------------------------------
-- 7segment driver for displaying a hexadecimal number
--------------------------------------------------------
-- Library for A0B35SPS - Structures of Computers System
-- CTU-FFE Prague, Dept. of Control Eng. [Richard Susta]
--  Published under GNU General Public License
-------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY hex2hex7seg IS 
	PORT( A0, A1, A2, A3 :IN STD_LOGIC; -- A3.. A0 input hexadecimal number A0-LSB  A3-MSB
		   hex: OUT STD_LOGIC_VECTOR(6 DOWNTO 0) );-- HEX[6..0] output to hexadecimal display
END hex2hex7seg;

architecture Behavioral of hex2hex7seg IS
signal A:STD_LOGIC_VECTOR(3 downto 0);
BEGIN
	A<=A3 & A2 & A1 & A0;
	with A SELECT		-- 7segment bits are A to G, the LSB is A
		hex
		 <=	"1000000" WHEN "0000",		-- 0
			"1111001" WHEN "0001",		-- 1
			"0100100" WHEN "0010", 		-- 2
			"0110000" WHEN "0011", 		-- 3
			"0011001" WHEN "0100",		-- 4
			"0010010" WHEN "0101", 		-- 5
			"0000010" WHEN "0110", 		-- 6
			"1111000" WHEN "0111",		-- 7
			"0000000" WHEN "1000", 		-- 8
			"0010000" WHEN "1001",		-- 9
			"0001000" WHEN "1010",		-- A
			"0000011" WHEN "1011",		-- b
			"1000110" WHEN "1100",		-- C
			"0100001" WHEN "1101",		-- d
			"0000110" WHEN "1110",		-- E
			"0001110" WHEN others;		-- for F "111" and simulation
END Behavioral;