-- Library for A0B35SPS - Structures of Computers System
-- CTU-FFE Prague, Dept. of Control Eng. [Richard Susta]
-- Published under GNU General Public License

library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- VGA 640x480@60Hz synchronization circuit
--
-- @see http://tinyvga.com/vga-timing/640x480@60Hz
--
entity vgaSynchronization is

	port
	(
		-- input clock, recommended 25.175 MHz
		CLK_25MHz175: in std_logic;

		-- asynchronously reset signal 
		ACLRN : in std_logic;

		-- coordinates
		x : out unsigned(9 downto 0);
		y : out unsigned(9 downto 0);

		-- copy of input clock frequency
		VGA_CLK : out std_logic;

		-- whether current coordinates are in visible part of picture
		VGA_BLANK : out std_logic;

		-- '0' = horizontal synchronization pulse
		VGA_HS : out std_logic;

		-- '0' = vertical synchronization pulse
		VGA_VS : out std_logic;

		-- '0' = any synchronization pulse (= VGA_HS='0' or VGA_VS='0')
		VGA_SYNC : out std_logic
	);

end entity;

architecture rtl of vgaSynchronization is
begin

	process (CLK_25MHz175, ACLRN)

		--
		-- vertical (rows, Y)
		--
		constant VS_LINE_VISIBLE : integer := 480;
		constant VS_FRONT_PORCH : integer := 10;
		constant VS_SYN_LINES : integer := 2;
		-- constant VS_BACK_PORCH : integer := 33;
		constant VS_LENGTH : integer := 525;

		--
		-- horizontal (column, X)
		--
		constant HS_PIXEL_VISIBLE  : integer := 640;
		constant HS_FRONT_PORCH : integer := 16;
		constant HS_SYN_PULS : integer := 96;
		-- constant HS_BACK_PORCH : integer := 48;
		constant HS_LENGTH : integer := 800;

		constant ZERO : unsigned(x'range) := (others=>'0');

		variable currentX : unsigned(x'range) := ZERO; -- horizontal  counter, i.e.  columns
		variable currentY : unsigned(y'range) := ZERO;   --vertical counter, i.e. rows
		variable currentVgaBLANK : std_logic;
		variable currentVgaVS : std_logic;
		variable currentVgaHS : std_logic;

	begin

		if ACLRN = '0' then
			-- zero coordinates
			currentX := ZERO;
			currentY := ZERO;

			y <= currentY;
			x <= currentX;

			-- deactivate synchronization pulses
			currentVgaVS := '1';
			currentVgaHS := '1';
			currentVgaBLANK := '1';

			VGA_BLANK <= currentVgaBLANK;
			VGA_VS <= currentVgaVS;
			VGA_HS <= currentVgaHS;
			VGA_SYNC <= currentVgaVS and currentVgaHS;

		elsif rising_edge(CLK_25MHz175) then
			-- vertical synchronization pulse
			if (currentY >= (VS_LINE_VISIBLE + VS_FRONT_PORCH)) and (currentY < (VS_LINE_VISIBLE + VS_FRONT_PORCH + VS_SYN_LINES)) then
				currentVgaVS := '0';
			else
				currentVgaVS := '1';
			end if;

			-- horizontal synchronization pulse
			if (currentX >= (HS_PIXEL_VISIBLE + HS_FRONT_PORCH)) and (currentX < (HS_PIXEL_VISIBLE + HS_FRONT_PORCH + HS_SYN_PULS)) then
				currentVgaHS := '0';
			else
				currentVgaHS := '1';
			end if;

			-- '0' if non visible part of picture, otherwise '1'
			if (currentX < HS_PIXEL_VISIBLE) and (currentY < VS_LINE_VISIBLE) then
				currentVgaBLANK := '1';
			else
				currentVgaBLANK := '0';
			end if;

			-- On rising edge of CLK_25MHz175 copy results to outputs to synchronize them all with clock
			y <= currentY;
			x <= currentX;

			VGA_BLANK <= currentVgaBLANK;
			VGA_HS <= currentVgaHS;
			VGA_VS <= currentVgaVS;
			VGA_SYNC <= currentVgaVS and currentVgaHS;

			-- Increment counters for the next loop
			if currentX < HS_LENGTH - 1 then
				currentX := currentX + 1;
			else
				currentX := (others => '0');

				if currentY < VS_LENGTH - 1 then
					currentY := currentY + 1;
				else 
					currentY := (others => '0');
				end if;
			end if;
		end if;

	end process;


	-- copy input clock to output 
	VGA_CLK <= CLK_25MHz175;

end architecture;
