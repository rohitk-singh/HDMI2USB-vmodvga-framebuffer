library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity vga2dvi is
	port(
		rst         : in  std_logic;    -- RSTBTN

		-- VGA input signals
		pclk        : in  std_logic;
		pclk_locked : in  std_logic;
		hsync       : in  std_logic;
		vsync       : in  std_logic;
		de          : in  std_logic;
		rgb         : in  std_logic_vector(23 downto 0);

		-- HDMI/DVI-D Signal lines
		tmds        : out std_logic_vector(3 downto 0);
		tmdsb       : out std_logic_vector(3 downto 0)
	);
end entity vga2dvi;

architecture rtl of vga2dvi is
	component dvi_encoder_top
		port(
			pclk         : in  std_logic;
			pclkx2       : in  std_logic;
			pclkx10      : in  std_logic;
			serdesstrobe : in  std_logic;
			rstin        : in  std_logic;
			blue_din     : in  std_logic_vector(7 downto 0);
			green_din    : in  std_logic_vector(7 downto 0);
			red_din      : in  std_logic_vector(7 downto 0);
			hsync        : in  std_logic;
			vsync        : in  std_logic;
			de           : in  std_logic;
			TMDS         : out std_logic_vector(3 downto 0);
			TMDSB        : out std_logic_vector(3 downto 0)
		);
	end component;
	signal clkfbout     : std_logic;
	signal pll_lckd     : std_logic;
	signal pllclk0      : std_logic;
	signal pllclk1      : std_logic;
	signal pllclk2      : std_logic;
	signal serdesstrobe : std_logic;
	signal pclkx10      : std_logic;
	signal bufpll_lock  : std_logic;
	signal serdes_rst   : std_logic;
	signal pclkx1       : std_logic;
	signal pclkx2       : std_logic;

begin
	PLL_OSERDES : PLL_BASE
		generic map(
			CLKIN_PERIOD   => 13.3333333,
			CLKFBOUT_MULT  => 10,       --set VCO to 10x of CLKIN
			CLKOUT0_DIVIDE => 1,
			CLKOUT1_DIVIDE => 10,
			CLKOUT2_DIVIDE => 5,
			COMPENSATION   => "INTERNAL")
		port map(
			CLKFBOUT => clkfbout,
			CLKOUT0  => pllclk0,        -- = 10x pclk
			CLKOUT1  => pllclk1,        -- = 1x  pclk
			CLKOUT2  => pllclk2,        -- = 2x  pclk
			LOCKED   => pll_lckd,
			CLKFBIN  => clkfbout,
			CLKIN    => pclk,
			RST      => not pclk_locked);

	pclkbufg : BUFG port map(I => pllclk1, O => pclkx1);
	pclkx2bufg : BUFG port map(I => pllclk2, O => pclkx2);

	ioclk_buf : BUFPLL
		generic map(DIVIDE => 5)
		port map(PLLIN => pllclk0, GCLK => pclkx2, LOCKED => pll_lckd,
			     IOCLK => pclkx10, SERDESSTROBE => serdesstrobe, LOCK => bufpll_lock);

	serdes_rst <= rst or not (bufpll_lock);

	Inst_dvi_encoder_top : dvi_encoder_top port map(
			pclk         => pclkx1,
			pclkx2       => pclkx2,
			pclkx10      => pclkx10,
			serdesstrobe => serdesstrobe,
			rstin        => serdes_rst,
			blue_din     => rgb(7 downto 0),
			green_din    => rgb(15 downto 8),
			red_din      => rgb(23 downto 16),
			hsync        => hsync,
			vsync        => vsync,
			de           => de,
			TMDS         => TMDS,
			TMDSB        => TMDSB);

end architecture rtl;
