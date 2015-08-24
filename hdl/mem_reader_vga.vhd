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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

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
	signal read_cmd_enable_q  : std_logic                     := '0';
	signal read_data_enable_q : std_logic                     := '0';
	signal address            : std_logic_vector(29 downto 0) := (others => '0');
	signal counterX           : std_logic_vector(15 downto 0) := (others => '0');
	signal counterY           : std_logic_vector(15 downto 0) := (others => '0');

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
	signal FIFO_rst : std_logic := '0';
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
	signal mem_sync_up : std_logic := '0';
	type write_states is (GIVE_READ_CMD, WAIT_FOR_DATA, READING_DATA);
	signal state : write_states := GIVE_READ_CMD;
	signal read_counter : std_logic_vector(7 downto 0);

begin
	read_cmd_enable  <= read_cmd_enable_q;
	read_cmd_address <= address;
	rgb              <= rgb_q;
	read_data_enable <= read_data_enable_q;

	-- Infer Debug LED latches
	process(read_cmd_full, read_data_full, FIFO_overflow, FIFO_underflow)
	begin
		if read_cmd_full = '1' then
			led(0) <= '1';
		end if;

		if read_data_full = '1' then
			led(1) <= '1';
		end if;

		if FIFO_overflow = '1' then
			led(2) <= '1';
		end if;

		if FIFO_underflow = '1' then
			led(3) <= '1';
		end if;

	end process;

	process(rst, clk_reader)
	begin
		if rst = '1' then
			counterX <= (others => '0');
			counterY <= (others => '0');

			address <= (others => '0');
			rgb_q   <= (others => '0');

			read_cmd_enable_q <= '0';
			state <= GIVE_READ_CMD;
			
			FIFO_rst <= '1';

		elsif rising_edge(clk_reader) then
			
			if FIFO_rst = '1' then
				FIFO_rst <= '0';
			end if;
				
			if memory_ready = '1' and mem_sync_up = '1' then
				read_data_enable_q <= not read_data_empty;

				case state is
					when GIVE_READ_CMD =>
						if read_cmd_empty = '1' and read_data_empty = '1' then
							read_cmd_enable_q <= '1';
						end if;

						if read_cmd_enable_q = '1' then
							read_cmd_enable_q <= '0';
							address           <= address + 4 * 64; -- 4 bytes since 32-bit word, 64 since burst length is 64 words
							state             <= WAIT_FOR_DATA;
						end if;

					when WAIT_FOR_DATA =>
						if read_data_empty = '0' then
							state        <= READING_DATA;
							read_counter <= (others => '0');
						end if;

					when READING_DATA =>
						read_counter <= read_counter + 1;
						if read_counter = conv_std_logic_vector(62, 8) then
						end if;
						state <= GIVE_READ_CMD;

				end case;

			end if;
			
			FIFO_wr_en <= (not FIFO_almost_full) and (not read_data_empty);
		
			if (FIFO_empty /= '1') and (counterX < hVisible) and (counterY < vVisible) then --mind here counterX < vVisible!! WTF!! x-(
				FIFO_rd_en <= '1';
			else
				FIFO_rd_en <= '0';
			end if;


			rgb_q <= FIFO_dout(23 downto 0);
			
			if counterX < hvisible and counterY < vVisible then
				de <= '1';
			else
				de <= '0';
			end if;
			
			-- Generate Timings independently
			if counterX = hMax then
				counterX <= (others => '0');
				if counterY = vMax then
					counterY <= (others => '0');
				else
					counterY <= counterY + 1;
				end if;

				if counterY = vSyncStart then
					vSync <= vSyncActive;
					ready_to_read_new_frame <= '1';
				end if;

				if counterY = vSyncEnd then
					vSync <= not vSyncActive;
				end if;
			else
				counterX <= counterX + 1;
			end if;

			if counterX = hSyncStart then
				hSync <= hSyncActive;
			end if;

			if counterX = hSyncEnd then
				hSync <= not hSyncActive;

				if counterY = vMax-1 then
					if memory_ready = '1' then
						mem_sync_up <= '1';
					end if;

					address           <= (others => '0');
					FIFO_rst <= '1';
					read_cmd_enable_q <= memory_ready and read_cmd_empty and read_data_empty;
				end if;

			end if;
			
		end if;
	end process;

	inst_mem_FIFO : mem_FIFO
		port map(
			clk          => clk_reader,
			rst          => rst,
			din          => read_data,
			wr_en        => FIFO_wr_en,
			rd_en        => FIFO_rd_en,
			dout         => FIFO_dout,
			full         => FIFO_full,
			almost_full  => FIFO_almost_full,
			overflow     => FIFO_overflow,
			empty        => FIFO_empty,
			almost_empty => FIFO_almost_empty,
			underflow    => FIFO_underflow,
			data_count   => FIFO_data_count
		);
end rtl;