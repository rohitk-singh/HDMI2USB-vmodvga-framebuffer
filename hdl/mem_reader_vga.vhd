----------------------------------------------------------------------------------
-- Engineer: Rohit Kumar Singh
-- Create Date:    23:14:52 08/04/2015 
-- Design Name: Framebuffer
-- Module Name:    mem_reader_vga - rtl 
-- Project Name: HDMI2USB-vModVGA
-- Target Devices: Atlys, Opsis, [Optionally Saturn]
-- Description: Memory reader and VGA writer
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity mem_reader_vga is
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

		-- VGA signals
		hsync            : out std_logic;
		vsync            : out std_logic;
		rgb              : out std_logic_vector(23 downto 0);
		de               : out std_logic;

		led              : out std_logic_vector(7 downto 0);
		memory_ready     : in  std_logic;

		-- MCB signals
		-- Reads are in a burst length of 64
		read_cmd_enable  : out std_logic;
		read_cmd_refresh : out std_logic;
		read_cmd_address : out std_logic_vector(29 downto 0);
		read_cmd_full    : in  std_logic;
		read_cmd_empty   : in  std_logic;
		--
		read_data_enable : out std_logic;
		read_data        : in  std_logic_vector(31 downto 0);
		read_data_empty  : in  std_logic;
		read_data_full   : in  std_logic;
		read_data_count  : in  std_logic_vector(6 downto 0);

		rst              : in  std_logic
	);
end mem_reader_vga;

architecture rtl of mem_reader_vga is
	signal read_cmd_enable_q  : std_logic             := '0';
	signal read_data_enable_q : std_logic             := '0';
	signal address            : unsigned(29 downto 0) := (others => '0');
	signal x                  : unsigned(15 downto 0) := (others => '0');
	signal y                  : unsigned(15 downto 0) := (others => '0');

	component mem_FIFO
		port(
			clk          : in  STD_LOGIC;
			rst          : in  STD_LOGIC;
			din          : in  STD_LOGIC_VECTOR(31 downto 0);
			wr_en        : in  STD_LOGIC;
			rd_en        : in  STD_LOGIC;
			dout         : out STD_LOGIC_VECTOR(31 downto 0);
			full         : out STD_LOGIC;
			almost_full  : out STD_LOGIC;
			overflow     : out STD_LOGIC;
			empty        : out STD_LOGIC;
			almost_empty : out STD_LOGIC;
			underflow    : out STD_LOGIC;
			data_count   : out STD_LOGIC_VECTOR(5 downto 0)
		);
	end component;
	signal FIFO_rst                : std_logic                     := '0';
	signal FIFO_wr_en              : STD_LOGIC                     := '0';
	signal FIFO_rd_en              : STD_LOGIC                     := '0';
	signal FIFO_dout               : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal FIFO_full               : STD_LOGIC                     := '0';
	signal FIFO_almost_full        : STD_LOGIC                     := '0';
	signal FIFO_overflow           : STD_LOGIC                     := '0';
	signal FIFO_empty              : STD_LOGIC                     := '0';
	signal FIFO_underflow          : STD_LOGIC                     := '0';
	signal FIFO_almost_empty       : STD_LOGIC                     := '0';
	signal FIFO_data_count         : STD_LOGIC_VECTOR(5 downto 0)  := (others => '0');
	signal ready_to_read_new_frame : std_logic                     := '0';
	signal rgb_q                   : std_logic_vector(23 downto 0) := (others => '0');
	signal mem_sync_up             : std_logic                     := '0';
	type macro_states is (WAIT_FOR_MEMORY_READY, WAIT_FOR_SYNCUP, RUN_MACHINE);
	type micro_states is (IDLE, GIVE_READ_CMD, WAIT_FOR_DATA_ARRIVAL);
	signal macro_state  : macro_states         := WAIT_FOR_MEMORY_READY;
	signal micro_state  : micro_states         := IDLE;
	signal read_counter : std_logic_vector(7 downto 0);
	signal counter      : unsigned(7 downto 0) := (others => '0');
	signal led_q        : unsigned(7 downto 0);

begin
	read_cmd_enable  <= read_cmd_enable_q;
	read_cmd_address <= std_logic_vector(address);
	rgb              <= rgb_q;         --read_data(23 downto 0); 
	read_data_enable <= read_data_enable_q;
	led              <= std_logic_vector(led_q);

	process(rst, clk_reader)
	begin
		if rst = '1' then
			x <= (others => '0');
			y <= (others => '0');

			address            <= (others => '0');
			rgb_q              <= (others => '0');
			led_q                <= (others => '0');
			read_cmd_enable_q  <= '0';
			read_data_enable_q <= '0';

			macro_state <= WAIT_FOR_MEMORY_READY;
			micro_state <= IDLE;

		elsif rising_edge(clk_reader) then
			if memory_ready = '1' then
				if read_cmd_full = '1' or read_data_full = '1' then
					led_q <= led_q + 1;
				end if;
			end if;

			if x < hVisible and y < vVisible then
				de <= '1';
				if macro_state = RUN_MACHINE then
					read_data_enable_q <= '1';
					rgb_q              <= read_data(23 downto 0);
				end if;

			else
				de <= '0';
				if macro_state = RUN_MACHINE then
					read_data_enable_q <= '0';
					rgb_q              <= x"ff00ff";
				end if;
			end if;

			if x = hSyncStart then
				hsync <= hSyncActive;
			end if;

			if x = hSyncEnd then
				hsync <= not hSyncActive;
			end if;

			if x = hMax then
				x <= (others => '0');

				if y = vMax then
					y <= (others => '0');
				else
					y <= y + 1;
				end if;

				if y = vSyncStart - 1 then
					vsync <= vSyncActive;
				end if;

				if y = vSyncEnd - 1 then
					vsync <= not vSyncActive;
				end if;

			else
				x <= x + 1;
			end if;

			case macro_state is
				when WAIT_FOR_MEMORY_READY =>
					-- wait for memory ready
					-- when memory is ready switch to next state

					if memory_ready = '1' then
						macro_state <= WAIT_FOR_SYNCUP;
					end if;

				when WAIT_FOR_SYNCUP =>
					-- do something
					if y = vMax and x = 0 then
						macro_state       <= RUN_MACHINE;
						address           <= (others => '0');
						read_cmd_enable_q <= '1';
					end if;

				when RUN_MACHINE =>
					-- do someting


					--FIFO_wr_en <= not(FIFO_almost_full) and (not read_data_empty);

					case micro_state is
						when GIVE_READ_CMD =>
							-- give the fucking read cmd
							--read_cmd_enable_q <= read_cmd_empty and read_data_empty;
							if read_data_count < std_logic_vector(to_unsigned(28, 7)) then
								read_cmd_enable_q <= '1';
							end if;

						when WAIT_FOR_DATA_ARRIVAL =>
							--							if read_data_empty /= '1' then
							--								micro_state <= GIVE_READ_CMD;
							--							end if;
							counter <= counter + 1;
							if counter = to_unsigned(26, 8) then
								micro_state <= GIVE_READ_CMD;
							end if;

						when IDLE =>
							--do nothing
					end case;
					
					if read_cmd_enable_q = '1' then
						read_cmd_enable_q <= '0';
						if address = (hVisible * vVisible - 32) * 4 then
							address <= (others => '0');
						else
							address <= address + 4 * 32;
						end if;
						micro_state <= WAIT_FOR_DATA_ARRIVAL;
						counter     <= (others => '0');
					end if;
					
			end case;
			
			
		end if;
	end process;
	
end rtl;