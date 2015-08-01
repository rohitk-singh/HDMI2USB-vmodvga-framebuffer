library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity hdmi2usb_vmodvga is
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;

		-- HDMI/DVI-D Port
		tmds  : out std_logic_vector(3 downto 0);
		tmdsb : out std_logic_vector(3 downto 0)
	);
end hdmi2usb_vmodvga;

architecture rtl of hdmi2usb_vmodvga is
	component pattern
		port(
			pclk  : in  std_logic;
			rst_n : in  std_logic;
			rgb   : out std_logic_vector(23 downto 0);
			resx  : out std_logic_vector(15 downto 0);
			resy  : out std_logic_vector(15 downto 0);
			de    : out std_logic;
			vsync : out std_logic;
			hsync : out std_logic
		);
	end component;

	component vga2dvi
		port(
			rst         : in  std_logic;
			pclk        : in  std_logic;
			pclk_locked : in  std_logic;
			hsync       : in  std_logic;
			vsync       : in  std_logic;
			de          : in  std_logic;
			rgb         : in  std_logic_vector(23 downto 0);
			tmds        : out std_logic_vector(3 downto 0);
			tmdsb       : out std_logic_vector(3 downto 0)
		);
	end component;

	signal pclk        : std_logic;
	signal rgb         : std_logic_vector(23 downto 0);
	signal de          : std_logic;
	signal vsync       : std_logic;
	signal hsync       : std_logic;
	signal pclk_locked : std_logic;

begin
	PCLK_GEN_INST : DCM_CLKGEN
		generic map(
			CLKFX_DIVIDE   => 4,
			CLKFX_MULTIPLY => 3,
			CLKIN_PERIOD   => 10.000)
		port map(
			CLKFX     => pclk,
			LOCKED    => pclk_locked,
			CLKIN     => clk,
			FREEZEDCM => '0',
			RST       => '0');

	Inst_pattern : pattern port map(
			rgb   => rgb,
			de    => de,
			pclk  => pclk,
			vsync => vsync,
			hsync => hsync,
			rst_n => not rst
		);

	Inst_vga2dvi : vga2dvi port map(
			rst         => rst,
			pclk        => pclk,
			pclk_locked => pclk_locked,
			hsync       => hsync,
			vsync       => vsync,
			de          => de,
			rgb         => rgb,
			tmds        => tmds,
			tmdsb       => tmdsb
		);

end architecture; 
