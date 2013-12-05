library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity flag is
	port
	(
		-- flag position on screen
		flagY : in unsigned(9 downto 0);
		flagX : in unsigned(9 downto 0);

		-- currenct VGA pixel drawn
		vgaY : in unsigned(9 downto 0);
		vgaX : in unsigned(9 downto 0);

		-- VGA synchronization inputs
		VGA_CLK_in : in std_logic;
		VGA_BLANK_in : in std_logic;
		VGA_HS_in : in std_logic;
		VGA_VS_in : in std_logic;
		VGA_SYNC_in : in std_logic;

		-- VGA RGB output
		VGA_R : out std_logic_vector(9 downto 0);
		VGA_G : out std_logic_vector(9 downto 0);
		VGA_B : out std_logic_vector(9 downto 0);

		-- copy of VGA synchronization inputs
		VGA_CLK : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_SYNC : out std_logic
	);
end entity;

architecture omg of flag is

	-- color stuff
	constant BLACK_RGB : std_logic_vector(29 downto 0) := "0000000000" & "0000000000" & "0000000000";
	constant WHITE_RGB : std_logic_vector(29 downto 0) := "1111111111" & "1111111111" & "1111111111";
	constant BLUE_RGB : std_logic_vector(29 downto 0) := "0000000000" & "0000000000" & "1111111111";

	--
	-- AUTO-GENERATED by util/flagGenerator
	--

	constant FLAG_ROWS : integer := 160;
	constant FLAG_COLUMNS : integer := 240;

	subtype index is unsigned(9 downto 0);
	type indexPair is array(0 to 1) of index;
	type imageData is array(0 to 159) of indexPair;
	constant IMAGE : imageData := ( (to_unsigned(0, 10), to_unsigned(15, 10)), (to_unsigned(0, 10), to_unsigned(17, 10)), (to_unsigned(0, 10), to_unsigned(22, 10)), (to_unsigned(0, 10), to_unsigned(27, 10)), (to_unsigned(0, 10), to_unsigned(28, 10)), (to_unsigned(0, 10), to_unsigned(32, 10)), (to_unsigned(0, 10), to_unsigned(34, 10)), (to_unsigned(0, 10), to_unsigned(35, 10)), (to_unsigned(0, 10), to_unsigned(35, 10)), (to_unsigned(0, 10), to_unsigned(39, 10)), (to_unsigned(0, 10), to_unsigned(39, 10)), (to_unsigned(0, 10), to_unsigned(39, 10)), (to_unsigned(0, 10), to_unsigned(42, 10)), (to_unsigned(0, 10), to_unsigned(43, 10)), (to_unsigned(0, 10), to_unsigned(43, 10)), (to_unsigned(0, 10), to_unsigned(44, 10)), (to_unsigned(0, 10), to_unsigned(45, 10)), (to_unsigned(0, 10), to_unsigned(45, 10)), (to_unsigned(0, 10), to_unsigned(46, 10)), (to_unsigned(0, 10), to_unsigned(47, 10)), (to_unsigned(0, 10), to_unsigned(47, 10)), (to_unsigned(0, 10), to_unsigned(47, 10)), (to_unsigned(0, 10), to_unsigned(48, 10)), (to_unsigned(0, 10), to_unsigned(49, 10)), (to_unsigned(0, 10), to_unsigned(49, 10)), (to_unsigned(0, 10), to_unsigned(51, 10)), (to_unsigned(0, 10), to_unsigned(52, 10)), (to_unsigned(0, 10), to_unsigned(52, 10)), (to_unsigned(0, 10), to_unsigned(52, 10)), (to_unsigned(0, 10), to_unsigned(54, 10)), (to_unsigned(0, 10), to_unsigned(55, 10)), (to_unsigned(0, 10), to_unsigned(56, 10)), (to_unsigned(0, 10), to_unsigned(87, 10)), (to_unsigned(0, 10), to_unsigned(89, 10)), (to_unsigned(0, 10), to_unsigned(92, 10)), (to_unsigned(0, 10), to_unsigned(94, 10)), (to_unsigned(0, 10), to_unsigned(96, 10)), (to_unsigned(0, 10), to_unsigned(98, 10)), (to_unsigned(0, 10), to_unsigned(99, 10)), (to_unsigned(0, 10), to_unsigned(99, 10)), (to_unsigned(0, 10), to_unsigned(99, 10)), (to_unsigned(0, 10), to_unsigned(100, 10)), (to_unsigned(0, 10), to_unsigned(102, 10)), (to_unsigned(0, 10), to_unsigned(103, 10)), (to_unsigned(0, 10), to_unsigned(103, 10)), (to_unsigned(0, 10), to_unsigned(104, 10)), (to_unsigned(0, 10), to_unsigned(105, 10)), (to_unsigned(0, 10), to_unsigned(105, 10)), (to_unsigned(0, 10), to_unsigned(106, 10)), (to_unsigned(1, 10), to_unsigned(107, 10)), (to_unsigned(5, 10), to_unsigned(108, 10)), (to_unsigned(7, 10), to_unsigned(109, 10)), (to_unsigned(10, 10), to_unsigned(110, 10)), (to_unsigned(12, 10), to_unsigned(112, 10)), (to_unsigned(15, 10), to_unsigned(113, 10)), (to_unsigned(16, 10), to_unsigned(115, 10)), (to_unsigned(17, 10), to_unsigned(143, 10)), (to_unsigned(18, 10), to_unsigned(146, 10)), (to_unsigned(20, 10), to_unsigned(148, 10)), (to_unsigned(20, 10), to_unsigned(149, 10)), (to_unsigned(22, 10), to_unsigned(151, 10)), (to_unsigned(23, 10), to_unsigned(152, 10)), (to_unsigned(23, 10), to_unsigned(153, 10)), (to_unsigned(24, 10), to_unsigned(154, 10)), (to_unsigned(25, 10), to_unsigned(155, 10)), (to_unsigned(25, 10), to_unsigned(155, 10)), (to_unsigned(25, 10), to_unsigned(156, 10)), (to_unsigned(26, 10), to_unsigned(157, 10)), (to_unsigned(27, 10), to_unsigned(157, 10)), (to_unsigned(27, 10), to_unsigned(159, 10)), (to_unsigned(28, 10), to_unsigned(159, 10)), (to_unsigned(29, 10), to_unsigned(160, 10)), (to_unsigned(30, 10), to_unsigned(161, 10)), (to_unsigned(30, 10), to_unsigned(162, 10)), (to_unsigned(31, 10), to_unsigned(163, 10)), (to_unsigned(32, 10), to_unsigned(163, 10)), (to_unsigned(33, 10), to_unsigned(164, 10)), (to_unsigned(34, 10), to_unsigned(165, 10)), (to_unsigned(36, 10), to_unsigned(166, 10)), (to_unsigned(44, 10), to_unsigned(167, 10)), (to_unsigned(67, 10), to_unsigned(169, 10)), (to_unsigned(70, 10), to_unsigned(172, 10)), (to_unsigned(73, 10), to_unsigned(177, 10)), (to_unsigned(74, 10), to_unsigned(198, 10)), (to_unsigned(76, 10), to_unsigned(200, 10)), (to_unsigned(77, 10), to_unsigned(201, 10)), (to_unsigned(78, 10), to_unsigned(202, 10)), (to_unsigned(79, 10), to_unsigned(205, 10)), (to_unsigned(80, 10), to_unsigned(205, 10)), (to_unsigned(80, 10), to_unsigned(206, 10)), (to_unsigned(81, 10), to_unsigned(207, 10)), (to_unsigned(82, 10), to_unsigned(207, 10)), (to_unsigned(83, 10), to_unsigned(209, 10)), (to_unsigned(83, 10), to_unsigned(210, 10)), (to_unsigned(85, 10), to_unsigned(210, 10)), (to_unsigned(85, 10), to_unsigned(211, 10)), (to_unsigned(86, 10), to_unsigned(212, 10)), (to_unsigned(87, 10), to_unsigned(213, 10)), (to_unsigned(87, 10), to_unsigned(213, 10)), (to_unsigned(89, 10), to_unsigned(214, 10)), (to_unsigned(90, 10), to_unsigned(215, 10)), (to_unsigned(92, 10), to_unsigned(215, 10)), (to_unsigned(93, 10), to_unsigned(215, 10)), (to_unsigned(95, 10), to_unsigned(217, 10)), (to_unsigned(98, 10), to_unsigned(217, 10)), (to_unsigned(125, 10), to_unsigned(219, 10)), (to_unsigned(128, 10), to_unsigned(221, 10)), (to_unsigned(130, 10), to_unsigned(222, 10)), (to_unsigned(130, 10), to_unsigned(224, 10)), (to_unsigned(131, 10), to_unsigned(226, 10)), (to_unsigned(132, 10), to_unsigned(228, 10)), (to_unsigned(133, 10), to_unsigned(232, 10)), (to_unsigned(134, 10), to_unsigned(236, 10)), (to_unsigned(135, 10), to_unsigned(239, 10)), (to_unsigned(136, 10), to_unsigned(239, 10)), (to_unsigned(137, 10), to_unsigned(239, 10)), (to_unsigned(138, 10), to_unsigned(239, 10)), (to_unsigned(138, 10), to_unsigned(239, 10)), (to_unsigned(139, 10), to_unsigned(239, 10)), (to_unsigned(140, 10), to_unsigned(239, 10)), (to_unsigned(140, 10), to_unsigned(239, 10)), (to_unsigned(141, 10), to_unsigned(239, 10)), (to_unsigned(142, 10), to_unsigned(239, 10)), (to_unsigned(143, 10), to_unsigned(239, 10)), (to_unsigned(144, 10), to_unsigned(239, 10)), (to_unsigned(145, 10), to_unsigned(239, 10)), (to_unsigned(146, 10), to_unsigned(239, 10)), (to_unsigned(147, 10), to_unsigned(239, 10)), (to_unsigned(149, 10), to_unsigned(239, 10)), (to_unsigned(155, 10), to_unsigned(239, 10)), (to_unsigned(175, 10), to_unsigned(239, 10)), (to_unsigned(177, 10), to_unsigned(239, 10)), (to_unsigned(181, 10), to_unsigned(239, 10)), (to_unsigned(182, 10), to_unsigned(239, 10)), (to_unsigned(183, 10), to_unsigned(239, 10)), (to_unsigned(184, 10), to_unsigned(239, 10)), (to_unsigned(186, 10), to_unsigned(239, 10)), (to_unsigned(187, 10), to_unsigned(239, 10)), (to_unsigned(188, 10), to_unsigned(239, 10)), (to_unsigned(189, 10), to_unsigned(239, 10)), (to_unsigned(189, 10), to_unsigned(239, 10)), (to_unsigned(190, 10), to_unsigned(239, 10)), (to_unsigned(191, 10), to_unsigned(239, 10)), (to_unsigned(191, 10), to_unsigned(239, 10)), (to_unsigned(192, 10), to_unsigned(239, 10)), (to_unsigned(193, 10), to_unsigned(239, 10)), (to_unsigned(194, 10), to_unsigned(239, 10)), (to_unsigned(194, 10), to_unsigned(239, 10)), (to_unsigned(195, 10), to_unsigned(239, 10)), (to_unsigned(196, 10), to_unsigned(239, 10)), (to_unsigned(197, 10), to_unsigned(239, 10)), (to_unsigned(198, 10), to_unsigned(239, 10)), (to_unsigned(198, 10), to_unsigned(239, 10)), (to_unsigned(199, 10), to_unsigned(239, 10)), (to_unsigned(200, 10), to_unsigned(239, 10)), (to_unsigned(202, 10), to_unsigned(239, 10)), (to_unsigned(203, 10), to_unsigned(239, 10)), (to_unsigned(207, 10), to_unsigned(239, 10)), (to_unsigned(210, 10), to_unsigned(239, 10)), (to_unsigned(212, 10), to_unsigned(239, 10)) );

	--
	-- END AUTO-GENERATED
	--

begin

	process(VGA_CLK_in, vgaY, vgaX, flagY, flagX)

		variable relativeY : unsigned(9 downto 0);
		variable relativeX : unsigned(9 downto 0);
		variable startStopIndexes : indexPair;

	begin

		if rising_edge(VGA_CLK_in) then
			if (vgaY < flagY) or (vgaY >= (flagY + FLAG_ROWS)) or (vgaX < flagX) or (vgaX >= (flagX + FLAG_COLUMNS)) then
				VGA_R <= BLACK_RGB(29 downto 20);
				VGA_G <= BLACK_RGB(19 downto 10);
				VGA_B <= BLACK_RGB(9 downto 0);
			else
				relativeY := vgaY - flagY;
				relativeX := vgaX - flagX;
				startStopIndexes := IMAGE(to_integer(relativeY));

				if (relativeX >= startStopIndexes(0)) and (relativeX <= startStopIndexes(1)) then
					VGA_R <= BLUE_RGB(29 downto 20);
					VGA_G <= BLUE_RGB(19 downto 10);
					VGA_B <= BLUE_RGB(9 downto 0);
				else
					VGA_R <= WHITE_RGB(29 downto 20);
					VGA_G <= WHITE_RGB(19 downto 10);
					VGA_B <= WHITE_RGB(9 downto 0);
				end if;

				VGA_BLANK <= VGA_BLANK_in;
				VGA_HS <= VGA_HS_in;
				VGA_VS <= VGA_VS_in;
				VGA_SYNC <= VGA_SYNC_in;
			end if;
			
			VGA_CLK <= VGA_CLK_in;
		end if;

	end process;

end architecture;