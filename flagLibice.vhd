library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity flagLibice is

	port
	(
		-- use input clock 27 MHz to transform to 25.175 MHz using PLL
		CLOCK_27 : in std_logic;

		KEY : in std_logic_vector(4 downto 0);

		-- VGA stuff
		VGA_CLK : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_SYNC : out std_logic;
		VGA_R : out std_logic_vector(9 downto 0);
		VGA_G : out std_logic_vector(9 downto 0);
		VGA_B : out std_logic_vector(9 downto 0);

		-- to show things on 7seg displays
		HEX7 : out std_logic_vector(6 downto 0);
		HEX6 : out std_logic_vector(6 downto 0);
		HEX5 : out std_logic_vector(6 downto 0);
		HEX4 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX0 : out std_logic_vector(6 downto 0)
	);

end entity;

architecture wtf of flagLibice is

	signal syncX : unsigned(9 downto 0);
	signal syncY : unsigned(9 downto 0);
	signal syncClk : std_logic;
	signal syncBlank : std_logic;
	signal syncHS : std_logic;
	signal syncVS : std_logic;
	signal syncSync : std_logic;
	signal clock25p175 : std_logic;
	signal flagY : unsigned(9 downto 0);
	signal flagX : unsigned(9 downto 0);
	signal rowFlagY : unsigned(9 downto 0);
	signal rowFlagX : unsigned(9 downto 0);
	signal speedFlagY : unsigned(3 downto 0);
	signal speedFlagYHigh : unsigned(3 downto 0);
	signal speedFlagYLow : unsigned(3 downto 0);
	signal speedFlagX : unsigned(3 downto 0);
	signal speedFlagXHigh : unsigned(3 downto 0);
	signal speedFlagXLow : unsigned(3 downto 0);
	signal instructionPointer : unsigned(7 downto 0);

begin

	--
	-- clock
	--
	instClock : clock25mhz175 port map
	(
		inclk0 => CLOCK_27,
		c0 => clock25p175
	);

	--
	-- VGA synchronization
	--
	instSync : vgaSynchronization port map
	(
		CLK_25MHz175 => clock25p175,
		ACLRN => '1',
		y => syncY,
		x => syncX,
		VGA_CLK => syncClk,
		VGA_BLANK => syncBlank,
		VGA_HS => syncHS,
		VGA_VS => syncVS,
		VGA_SYNC => syncSync
	);

	VGA_CLK <= syncClk;
	VGA_BLANK <= syncBlank;
	VGA_HS <= syncHS;
	VGA_VS <= syncVS;
	VGA_SYNC <= syncSync;

	--
	-- position controller
	--
	instPostion : positionController port map
	(
		vgaY => syncY,
		vgaX => syncX,
		VGA_CLK_in => syncClk,
		VGA_BLANK_in => syncBlank,
		VGA_HS_in => syncHS,
		VGA_VS_in => syncVS,
		VGA_SYNC_in => syncSync,

		ACLRN => KEY(0),

		flagY => flagY,
		flagX => flagX,

		speedY => speedFlagY,
		speedX => speedFlagX,
		instructionPointer => instructionPointer
	);

	--
	-- displaying current speed and instruction on 7seg displays
	--
	speedFlagXHigh <= speedFlagX / to_unsigned(10, 4);
	speedFlagXLow <= speedFlagX mod to_unsigned(10, 4);

	instSpeedFlagXHigh : hex2hex7seg port map
	(
		A0 => speedFlagXHigh(0),
		A1 => speedFlagXHigh(1),
		A2 => speedFlagXHigh(2),
		A3 => speedFlagXHigh(3),
		hex => HEX7
	);

	instSpeedFlagXLow : hex2hex7seg port map
	(
		A0 => speedFlagXLow(0),
		A1 => speedFlagXLow(1),
		A2 => speedFlagXLow(2),
		A3 => speedFlagXLow(3),
		hex => HEX6
	);

	speedFlagYHigh <= speedFlagY / to_unsigned(10, 4);
	speedFlagYLow <= speedFlagY mod to_unsigned(10, 4);

	instSpeedFlagYHigh : hex2hex7seg port map
	(
		A0 => speedFlagYHigh(0),
		A1 => speedFlagYHigh(1),
		A2 => speedFlagYHigh(2),
		A3 => speedFlagYHigh(3),
		hex => HEX5
	);

	instSpeedFlagYLow : hex2hex7seg port map
	(
		A0 => speedFlagYLow(0),
		A1 => speedFlagYLow(1),
		A2 => speedFlagYLow(2),
		A3 => speedFlagYLow(3),
		hex => HEX4
	);

	instInstructionPointerHigh : hex2hex7seg port map
	(
		A0 => instructionPointer(4),
		A1 => instructionPointer(5),
		A2 => instructionPointer(6),
		A3 => instructionPointer(7),
		hex => HEX1
	);

	instInstructionPointerLow : hex2hex7seg port map
	(
		A0 => instructionPointer(0),
		A1 => instructionPointer(1),
		A2 => instructionPointer(2),
		A3 => instructionPointer(3),
		hex => HEX0
	);

	HEX2 <= "1111111";
	HEX3 <= "1111111";

	--
	-- synchronize flag coordinates from position controller so flag wouldn't shiver
	--
	process(syncVS)
	begin
		if rising_edge(syncVS) then
			rowFlagY <= flagY;
			rowFlagX <= flagX;
		end if;
	end process;

	--
	-- flag displaying unit
	-- 
	instFlag : flag port map
	(
		flagY => rowFlagY,
		flagX => rowFlagX,
		vgaY => syncY,
		vgaX => syncX,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,
		VGA_CLK_in => syncClk,
		VGA_BLANK_in => syncBlank,
		VGA_HS_in => syncHS,
		VGA_VS_in => syncVS,
		VGA_SYNC_in => syncSync
	);

end architecture;
