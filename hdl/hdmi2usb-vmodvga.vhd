library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity hdmi2usb_vmodvga is
	generic(
		C3_SIMULATION : string := "FALSE"
	);
	port(
		clk              : in    std_logic;
		rst              : in    std_logic;

		-- LED ports
		LED              : out   std_logic_vector(7 downto 0);

		-- HDMI/DVI-D Port
		tmds             : out   std_logic_vector(3 downto 0);
		tmdsb            : out   std_logic_vector(3 downto 0);

		-- DDR2 Signals
		mcb3_dram_dq     : inout std_logic_vector(15 downto 0);
		mcb3_dram_a      : out   std_logic_vector(12 downto 0);
		mcb3_dram_ba     : out   std_logic_vector(2 downto 0);
		mcb3_dram_ras_n  : out   std_logic;
		mcb3_dram_cas_n  : out   std_logic;
		mcb3_dram_we_n   : out   std_logic;
		mcb3_dram_cke    : out   std_logic;
		mcb3_dram_dm     : out   std_logic;
		mcb3_dram_udqs   : inout std_logic;
		mcb3_dram_udqs_n : inout std_logic;
		mcb3_rzq         : inout std_logic;
		mcb3_zio         : inout std_logic;
		mcb3_dram_udm    : out   std_logic;
		mcb3_dram_odt    : out   std_logic;
		mcb3_dram_dqs    : inout std_logic;
		mcb3_dram_dqs_n  : inout std_logic;
		mcb3_dram_ck     : out   std_logic;
		mcb3_dram_ck_n   : out   std_logic
	);
end hdmi2usb_vmodvga;

architecture rtl of hdmi2usb_vmodvga is
	--	component pattern
	--		port(
	--			pclk  : in  std_logic;
	--			rst_n : in  std_logic;
	--			rgb   : out std_logic_vector(23 downto 0);
	--			resx  : out std_logic_vector(15 downto 0);
	--			resy  : out std_logic_vector(15 downto 0);
	--			de    : out std_logic;
	--			vsync : out std_logic;
	--			hsync : out std_logic
	--		);
	--	end component;

	component mem_reader_vga
		generic(
			-- Timings for 1280x720@60Hx
			hVisible    : natural;
			hSyncStart  : natural;
			hSyncEnd    : natural;
			hMax        : natural;
			hSyncActive : std_logic;

			vVisible    : natural;
			vSyncStart  : natural;
			vSyncEnd    : natural;
			vMax        : natural;
			vSyncActive : std_logic
		);
		port(
			clk_reader       : in  std_logic;
			memory_ready     : in  std_logic;
			read_cmd_full    : in  std_logic;
			read_cmd_empty   : in  std_logic;
			read_data        : in  std_logic_vector(31 downto 0);
			read_data_empty  : in  std_logic;
			read_data_full   : in  std_logic;
			read_data_count  : in  std_logic_vector(6 downto 0);
			rst              : in  std_logic;
			hsync            : out std_logic;
			vsync            : out std_logic;
			rgb              : out std_logic_vector(23 downto 0);
			de               : out std_logic;
			led              : out std_logic_vector(7 downto 0);
			read_cmd_enable  : out std_logic;
			read_cmd_refresh : out std_logic;
			read_cmd_address : out std_logic_vector(29 downto 0);
			read_data_enable : out std_logic
		);
	end component;
	component Test_pattern_writer
		generic(
			hVisible : natural;
			vVisible : natural
		);
		port(
			clk               : in  std_logic;
			completed         : out std_logic;
			memory_ready      : in  std_logic;
			write_cmd_empty   : in  std_logic;
			write_cmd_full    : in  std_logic;
			write_data_empty  : in  std_logic;
			write_data_count  : in  std_logic_vector(6 downto 0);
			write_cmd_enable  : out std_logic;
			write_cmd_address : out std_logic_vector(29 downto 0);
			write_data_enable : out std_logic;
			write_mask        : out std_logic_vector(3 downto 0);
			write_data        : out std_logic_vector(31 downto 0);
			rst               : in  std_logic
		);
	end component;
	component vga2dvi
		port(
			rst   : in  std_logic;
			pclk  : in  std_logic;
			--pclk_locked : in  std_logic;
			hsync : in  std_logic;
			vsync : in  std_logic;
			de    : in  std_logic;
			rgb   : in  std_logic_vector(23 downto 0);
			tmds  : out std_logic_vector(3 downto 0);
			tmdsb : out std_logic_vector(3 downto 0)
		);
	end component;

	component ddr2_wrapper
		generic(
			C3_SIMULATION : string := "FALSE"
		);
		port(
			clk_sys           : in    std_logic;
			clk_writer        : in    std_logic;
			clk_reader        : in    std_logic;
			write_cmd_enable  : in    std_logic;
			write_cmd_address : in    std_logic_vector(29 downto 0);
			write_data_enable : in    std_logic;
			write_mask        : in    std_logic_vector(3 downto 0);
			write_data        : in    std_logic_vector(31 downto 0);
			read_cmd_enable   : in    std_logic;
			read_cmd_address  : in    std_logic_vector(29 downto 0);
			read_data_enable  : in    std_logic;
			rst               : in    std_logic;
			mcb3_dram_dq      : inout std_logic_vector(15 downto 0);
			mcb3_dram_udqs    : inout std_logic;
			mcb3_dram_udqs_n  : inout std_logic;
			mcb3_rzq          : inout std_logic;
			mcb3_zio          : inout std_logic;
			mcb3_dram_dqs     : inout std_logic;
			mcb3_dram_dqs_n   : inout std_logic;
			c3_clk0           : out   std_logic;
			write_cmd_empty   : out   std_logic;
			write_cmd_full    : out   std_logic;
			write_data_empty  : out   std_logic;
			write_data_full   : out   std_logic;
			write_data_count  : out   std_logic_vector(6 downto 0);
			read_cmd_full     : out   std_logic;
			read_cmd_empty    : out   std_logic;
			read_data         : out   std_logic_vector(31 downto 0);
			read_data_empty   : out   std_logic;
			read_data_full    : out   std_logic;
			read_data_count   : out   std_logic_vector(6 downto 0);
			mcb3_dram_a       : out   std_logic_vector(12 downto 0);
			mcb3_dram_ba      : out   std_logic_vector(2 downto 0);
			mcb3_dram_ras_n   : out   std_logic;
			mcb3_dram_cas_n   : out   std_logic;
			mcb3_dram_we_n    : out   std_logic;
			mcb3_dram_cke     : out   std_logic;
			mcb3_dram_dm      : out   std_logic;
			mcb3_dram_udm     : out   std_logic;
			mcb3_dram_odt     : out   std_logic;
			mcb3_dram_ck      : out   std_logic;
			mcb3_dram_ck_n    : out   std_logic;
			calib_done        : out   std_logic;
			read_error        : out   std_logic;
			read_overflow     : out   std_logic;
			write_error       : out   std_logic;
			write_underrun    : out   std_logic;

			pll_locked        : out   std_logic
		);
	end component;
	
	-- Timings for 1280x720@60Hz, 75Mhz pixel clock

 	constant hFront : natural := 72;
 	constant hSynch : natural := 80;
 	constant hBack  : natural := 216;
 	constant vFront : natural := 3;
 	constant vSynch : natural := 5;
 	constant vBack  : natural := 22;

	constant hVisible    : natural   := 1280;
	constant hSyncStart  : natural   := hVisible + hFront; --1352;
	constant hSyncEnd    : natural   := hVisible + hFront + hSynch; --1432;
	constant hMax        : natural   := hVisible + hFront + hSynch + hBack - 1; --1647;
	constant hSyncActive : std_logic := '1';

	constant vVisible    : natural   := 720;
	constant vSyncStart  : natural   := vVisible + vFront; --723;
	constant vSyncEnd    : natural   := vVisible + vFront + vSynch; --728;
	constant vMax        : natural   := vVisible + vFront + vSynch + vBack - 1; --749;
	constant vSyncActive : std_logic := '1';
	
--	-- Timings for simulation
--	constant hVisible    : natural   := 64;
--	constant hSyncStart  : natural   := 64 + 2;
--	constant hSyncEnd    : natural   := 64 + 2 + 3;
--	constant hMax        : natural   := 64 + 2 + 3 + 4  - 1;
--	constant hSyncActive : std_logic := '1';
--
--	constant vVisible    : natural   := 8 ;
--	constant vSyncStart  : natural   := 8 + 2;
--	constant vSyncEnd    : natural   := 8 + 2 + 3;
--	constant vMax        : natural   := 8 + 2 + 3 + 4  - 1;
--	constant vSyncActive : std_logic := '1';
	
	signal pclk          : std_logic                     := '0';
	signal rgb           : std_logic_vector(23 downto 0) := (others => '0');
	signal de            : std_logic                     := '0';
	signal vsync         : std_logic                     := '0';
	signal hsync         : std_logic                     := '0';
	signal pclk_locked   : std_logic                     := '0';

	signal clk_reader        : std_logic                     := '0';
	signal memory_ready      : std_logic                     := '0';
	signal read_cmd_enable   : std_logic                     := '0';
	signal read_cmd_refresh  : std_logic                     := '0';
	signal read_cmd_address  : std_logic_vector(29 downto 0) := (others => '0');
	signal read_cmd_full     : std_logic                     := '0';
	signal read_cmd_empty    : std_logic                     := '0';
	signal read_data_enable  : std_logic                     := '0';
	signal read_data         : std_logic_vector(31 downto 0) := (others => '0');
	signal read_data_empty   : std_logic                     := '0';
	signal read_data_full    : std_logic                     := '0';
	signal read_data_count   : std_logic_vector(6 downto 0)  := (others => '0');
	signal clk_out           : std_logic                     := '0';
	signal clk_writer        : std_logic                     := '0';
	signal write_cmd_enable  : std_logic                     := '0';
	signal write_cmd_empty   : std_logic                     := '0';
	signal write_cmd_full    : std_logic                     := '0';
	signal write_cmd_address : std_logic_vector(29 downto 0) := (others => '0');
	signal write_data_enable : std_logic                     := '0';
	signal write_mask        : std_logic_vector(3 downto 0)  := (others => '0');
	signal write_data_empty  : std_logic                     := '0';
	signal write_data        : std_logic_vector(31 downto 0) := (others => '0');
	signal write_data_full   : std_logic                     := '0';
	signal write_data_count  : std_logic_vector(6 downto 0)  := (others => '0');
	signal pll_locked        : std_logic                     := '0';
	signal read_error        : std_logic                     := '0';
	signal read_overflow     : std_logic                     := '0';
	signal write_error       : std_logic                     := '0';
	signal write_underrun    : std_logic                     := '0';
	signal memory_written    : std_logic                     := '0';
	signal leds              : std_logic_vector(7 downto 0)  := (others => '0');

begin
	--	PCLK_GEN_INST : DCM_CLKGEN
	--		generic map(
	--			CLKFX_DIVIDE   => 4,
	--			CLKFX_MULTIPLY => 3,
	--			CLKIN_PERIOD   => 10.000)
	--		port map(
	--			CLKFX     => pclk,
	--			LOCKED    => pclk_locked,
	--			CLKIN     => clk,
	--			FREEZEDCM => '0',
	--			RST       => '0');

	--	Inst_pattern : pattern port map(
	--			rgb   => rgb,
	--			de    => de,
	--			pclk  => pclk,
	--			vsync => vsync,
	--			hsync => hsync,
	--			rst_n => not rst
	--		);

	clk_reader <= clk_out;
	clk_writer <= clk_out;
	pclk       <= clk_out;

	LED <= memory_ready & memory_written & read_error & read_overflow & leds(3 downto 0);

	Inst_mem_reader_vga : mem_reader_vga
		generic map(
			hVisible    => hVisible,
			hSyncStart  => hSyncStart,
			hSyncEnd    => hSyncEnd,
			hMax        => hMax,
			hSyncActive => hSyncActive,
			vVisible    => vVisible,
			vSyncStart  => vSyncStart,
			vSyncEnd    => vSyncEnd,
			vMax        => vMax,
			vSyncActive => vSyncActive
		)
		port map(
			clk_reader       => clk_reader,
			hsync            => hsync,
			vsync            => vsync,
			rgb              => rgb,
			de               => de,
			led              => leds,
			memory_ready     => memory_written, --memory_ready,
			read_cmd_enable  => read_cmd_enable,
			read_cmd_refresh => read_cmd_refresh,
			read_cmd_address => read_cmd_address,
			read_cmd_full    => read_cmd_full,
			read_cmd_empty   => read_cmd_empty,
			read_data_enable => read_data_enable,
			read_data        => read_data,
			read_data_empty  => read_data_empty,
			read_data_full   => read_data_full,
			read_data_count  => read_data_count,
			rst              => rst);

	Inst_Test_pattern_writer : Test_pattern_writer 
		generic map(
			hVisible => hVisible,
			vVisible => vVisible
		)
		port map(
			clk               => clk_writer,
			completed         => memory_written,
			memory_ready      => memory_ready,
			write_cmd_enable  => write_cmd_enable,
			write_cmd_address => write_cmd_address,
			write_cmd_empty   => write_cmd_empty,
			write_cmd_full    => write_cmd_full,
			write_data_empty  => write_data_empty,
			write_data_count  => write_data_count,
			write_data_enable => write_data_enable,
			write_mask        => write_mask,
			write_data        => write_data,
			rst               => rst
		);

	Inst_vga2dvi : vga2dvi 
		port map(
			rst   => rst,
			pclk  => pclk,
			--pclk_locked => open,
			hsync => hsync,
			vsync => vsync,
			de    => de,
			rgb   => rgb,
			tmds  => tmds,
			tmdsb => tmdsb
		);
	Inst_ddr2_wrapper : ddr2_wrapper
		generic map(
			C3_SIMULATION => C3_SIMULATION
		)
		port map(
			clk_sys           => clk,
			c3_clk0           => clk_out,
			clk_writer        => clk_writer,
			clk_reader        => clk_reader,
			write_cmd_enable  => write_cmd_enable,
			write_cmd_empty   => write_cmd_empty,
			write_cmd_full    => write_cmd_full,
			write_cmd_address => write_cmd_address,
			write_data_enable => write_data_enable,
			write_mask        => write_mask,
			write_data        => write_data,
			write_data_empty  => write_data_empty,
			write_data_full   => write_data_full,
			write_data_count  => write_data_count,
			read_cmd_enable   => read_cmd_enable,
			read_cmd_address  => read_cmd_address,
			read_cmd_full     => read_cmd_full,
			read_cmd_empty    => read_cmd_empty,
			read_data_enable  => read_data_enable,
			read_data         => read_data,
			read_data_empty   => read_data_empty,
			read_data_full    => read_data_full,
			read_data_count   => read_data_count,
			mcb3_dram_dq      => mcb3_dram_dq,
			mcb3_dram_a       => mcb3_dram_a,
			mcb3_dram_ba      => mcb3_dram_ba,
			mcb3_dram_ras_n   => mcb3_dram_ras_n,
			mcb3_dram_cas_n   => mcb3_dram_cas_n,
			mcb3_dram_we_n    => mcb3_dram_we_n,
			mcb3_dram_cke     => mcb3_dram_cke,
			mcb3_dram_dm      => mcb3_dram_dm,
			mcb3_dram_udqs    => mcb3_dram_udqs,
			mcb3_dram_udqs_n  => mcb3_dram_udqs_n,
			mcb3_rzq          => mcb3_rzq,
			mcb3_zio          => mcb3_zio,
			mcb3_dram_udm     => mcb3_dram_udm,
			mcb3_dram_odt     => mcb3_dram_odt,
			mcb3_dram_dqs     => mcb3_dram_dqs,
			mcb3_dram_dqs_n   => mcb3_dram_dqs_n,
			mcb3_dram_ck      => mcb3_dram_ck,
			mcb3_dram_ck_n    => mcb3_dram_ck_n,
			calib_done        => memory_ready,
			read_error        => read_error,
			read_overflow     => read_overflow,
			write_error       => write_error,
			write_underrun    => write_underrun,
			pll_locked        => pll_locked,
			rst               => rst);
end architecture;
