library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity positionController is
	port
	(
		-- current VGA coordinates
		vgaY : in unsigned(9 downto 0);
		vgaX : in unsigned(9 downto 0);

		-- asynchronous clear; active low
		ACLRN : in std_logic;

		VGA_CLK_in : in std_logic;
		VGA_BLANK_in : in std_logic;
		VGA_HS_in : in std_logic;
		VGA_VS_in : in std_logic;
		VGA_SYNC_in : in std_logic;

		-- output flag coordinates
		flagY : out unsigned(9 downto 0);
		flagX : out unsigned(9 downto 0);

		-- current flag speed
		speedY : out unsigned(3 downto 0);
		speedX : out unsigned(3 downto 0);

		-- outputs instruction pointer
		instructionPointer : out unsigned(7 downto 0);

		-- copy of VGA inputs
		VGA_CLK : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_SYNC : out std_logic
	);
end entity;

architecture dafuq of positionController is

	-- ROM addressing and data bus
	signal romAddress : std_logic_vector(7 downto 0);
	signal romData : std_logic_vector(15 downto 0);

	-- display stuff
	constant FLAG_ROWS : integer := 160;
	constant FLAG_COLUMNS : integer := 240;
	constant SCREEN_ROWS : integer := 480;
	constant SCREEN_COLUMNS : integer := 640;

	-- speed stuff
	constant CLOCKS_PER_SPEED_UNIT : integer := 2517500;

	-- instruction set stuff
	constant INST_NOP : std_logic_vector(7 downto 0) := x"00";
	constant INST_DIR : std_logic_vector(7 downto 0) := x"01";
	constant INST_LDSPEED : std_logic_vector(7 downto 0) := x"02";
	constant INST_WAITVS : std_logic_vector(7 downto 0) := x"03";
	constant INST_WAITLIM : std_logic_vector(7 downto 0) := x"04";
	constant INST_STOP : std_logic_vector(7 downto 0) := x"05";
	constant INST_RESTART : std_logic_vector(7 downto 0) := x"06";

begin

	instRom : positionControllerROM port map
	(
		clock => VGA_CLK_in,
		address => romAddress,
		q => romData
	);

	process(VGA_CLK_in, VGA_VS_in, ACLRN)

		variable ip : unsigned(7 downto 0) := to_unsigned(0, 8);
		variable enabled : std_logic := '1';

		variable xSpeed : unsigned(3 downto 0) := to_unsigned(0, 4);
		variable ySpeed : unsigned(3 downto 0) := to_unsigned(0, 4);
		variable xDirPositive : std_logic := '1';
		variable yDirPositive : std_logic := '1';
		variable xCounter : unsigned(31 downto 0) := to_unsigned(0, 32);
		variable yCounter : unsigned(31 downto 0) := to_unsigned(0, 32);
		variable xPosition : unsigned(9 downto 0) := to_unsigned(0, 10);
		variable yPosition : unsigned(9 downto 0) := to_unsigned(0, 10);
		variable xBounceLimit : unsigned(3 downto 0) := to_unsigned(0, 4);
		variable yBounceLimit : unsigned(3 downto 0) := to_unsigned(0, 4);
		variable waitVS : unsigned(7 downto 0) := to_unsigned(0, 8);
		variable prevVS : std_logic := '0';
		variable instr : std_logic_vector(15 downto 0);
		variable instrRead : std_logic := '0';

	begin

		if ACLRN = '0' then
			ip := to_unsigned(0, 8);
			enabled := '1';
			xDirPositive := '1';
			yDirPositive := '1';
			xCounter := to_unsigned(0, 32);
			yCounter := to_unsigned(0, 32);
			xBounceLimit := to_unsigned(0, 4);
			yBounceLimit := to_unsigned(0, 4);
			waitVS := to_unsigned(0, 8);
			prevVS := '0';
			instrRead := '0';

		elsif rising_edge(VGA_CLK_in) then
			--
			-- count down VS pulses
			--
			if waitVS > 0 and prevVS = '0' and VGA_VS_in = '1' then
				prevVS := VGA_VS_in;
				waitVS := waitVS - 1;
			end if;

			prevVS := VGA_VS_in;

			--
			-- read instruction from ROM
			--
			if instrRead = '1' then
				instrRead := '0';
				instr := romData;
				ip := ip + 1;

				case instr(15 downto 8) is
					when INST_NOP =>
						-- do nothing

					when INST_DIR =>
						xDirPositive := not instr(0);
						yDirPositive := not instr(0);

					when INST_LDSPEED =>
						xSpeed := unsigned(instr(7 downto 4));
						ySpeed := unsigned(instr(3 downto 0));

					when INST_WAITVS =>
						waitVS := unsigned(instr(7 downto 0));

					when INST_WAITLIM =>
						if instr(7 downto 0) = "00000000" then
							enabled := '0';
							xBounceLimit := to_unsigned(0, 4);
							yBounceLimit := to_unsigned(0, 4);
						else
							xBounceLimit := unsigned(instr(7 downto 4));
							yBounceLimit := unsigned(instr(3 downto 0));
						end if;

					when INST_STOP =>
						enabled := '0';

					when INST_RESTART =>
						ip := to_unsigned(0, 8);
						enabled := '1';

					when others =>
						assert false report "Unknown instruction" severity error;
				end case;
			end if;

			--
			-- prepare to read instruction in next cycle
			--
			if instrRead = '0' and enabled = '1' and (waitVS = 0) and (xBounceLimit = 0) and (yBounceLimit = 0) then
				romAddress <= std_logic_vector(ip);
				instrRead := '1';
			end if;

			--
			-- move X
			--
			if (xCounter * xSpeed) >= CLOCKS_PER_SPEED_UNIT then
				if xDirPositive = '1' then
					if (xPosition + FLAG_COLUMNS + 1) > SCREEN_COLUMNS then
						xDirPositive := not xDirPositive;
						if xBounceLimit > 0 then
							xBounceLimit := xBounceLimit - 1;
						end if;
					else
						xPosition := xPosition + 1;
					end if;
				else
					if xPosition = 0 then
						xDirPositive := not xDirPositive;
						if xBounceLimit > 0 then
							xBounceLimit := xBounceLimit - 1;
						end if;
					else
						xPosition := xPosition - 1;
					end if;
				end if;

				xCounter := to_unsigned(0, 32);
			end if;

			--
			-- move Y
			--
			if (yCounter * ySpeed) >= CLOCKS_PER_SPEED_UNIT then
				if yDirPositive = '1' then
					if (yPosition + FLAG_ROWS + 1) > SCREEN_ROWS then
						yDirPositive := not yDirPositive;
						if yBounceLimit > 0 then
							yBounceLimit := yBounceLimit - 1;
						end if;
					else
						yPosition := yPosition + 1;
					end if;
				else
					if yPosition = 0 then
						yDirPositive := not yDirPositive;
						if yBounceLimit > 0 then
							yBounceLimit := yBounceLimit - 1;
						end if;
					else
						yPosition := yPosition - 1;
					end if;
				end if;

				yCounter := to_unsigned(0, 32);
			end if;

			xCounter := xCounter + 1;
			yCounter := yCounter + 1;

			--
			-- copy state to output signals
			--
			flagY <= yPosition;
			flagX <= xPosition;

			speedY <= ySpeed;
			speedX <= xSpeed;
			instructionPointer <= ip;
		end if;

	end process;

	VGA_CLK <= VGA_CLK_in;
	VGA_BLANK <= VGA_BLANK_in;
	VGA_HS <= VGA_HS_in;
	VGA_VS <= VGA_VS_in;
	VGA_SYNC <= VGA_SYNC_in;

end architecture;
