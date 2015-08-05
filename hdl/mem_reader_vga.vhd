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
	signal read_cmd_enable_q : std_logic;
	signal read_data_enable_q : std_logic;
	signal address           : std_logic_vector(29 downto 0);
	signal counterX          : std_logic_vector(15 downto 0);
	signal counterY          : std_logic_vector(15 downto 0);

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
	signal FIFO_wr_en        : STD_LOGIC;
	signal FIFO_rd_en        : STD_LOGIC;
	signal FIFO_dout         : STD_LOGIC_VECTOR(31 downto 0);
	signal FIFO_full         : STD_LOGIC;
	signal FIFO_almost_full  : STD_LOGIC;
	signal FIFO_overflow     : STD_LOGIC;
	signal FIFO_empty        : STD_LOGIC;
	signal FIFO_underflow    : STD_LOGIC;
	signal FIFO_almost_empty : STD_LOGIC;
	signal FIFO_data_count   : STD_LOGIC_VECTOR(5 downto 0);
	signal ready_to_read_new_frame : std_logic;
    signal rgb_q               : std_logic_vector(23 downto 0);
begin
	read_cmd_enable  <= read_cmd_enable_q;
	read_cmd_address <= address;
    rgb <= rgb_q;
    read_data_enable <= read_data_enable_q;
    
	process(rst, clk_reader)
	begin
		if rst = '1' then
			counterX <= (others => '0');
			counterY <= (others => '0');
			address  <= (others => '0');
            rgb_q <= (others => '0');
            read_cmd_enable_q <= '0';
		elsif rising_edge(clk_reader) then
			
			read_cmd_enable_q <= '0';
			read_cmd_enable_q <= memory_ready and read_data_empty and read_cmd_empty;
			
			
			if read_cmd_enable_q <= '1' then
				address <= address + 4 * 64; -- 4 bytes since 32-bit word, 64 since burst length is 64 words
			end if;
			
            read_data_enable_q <= memory_ready and (not read_data_empty);
            
			if (FIFO_empty /= '1') and (counterX < hVisible) then
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
			
			-- Generate Timing Signals
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
			end if;


			-- At the end of frame, reset address to start
			if counterY = vVisible then
				--   read_data_enable <= memory_ready and not read_data_empty;
				address <= (others => '0');
			end if;
		
		
		end if;
	end process;

	inst_mem_FIFO : mem_FIFO
		port map(
			clk          => clk_reader,
			rst          => rst,
			din          => read_data,
			wr_en        => read_data_enable_q,
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


--
------------------------------------------------------------------------------------
---- Engineer: Mike Field <hasmter@snap.net.nz>
---- 
---- Module Name: mcb_vga.vhd - Behavioral 
----
---- Description: Reads from the MCB to display a picture on the screen.
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--
--entity mem_reader_vga is
--	GENERIC (
--		-- Timings for 1280x720@60Hx
--		hVisible    : natural;
--		hSyncStart  : natural;
--		hSyncEnd    : natural;
--		hMax        : natural;
--		hSyncActive : std_logic;
--
--		vVisible    : natural;
--		vSyncStart  : natural;
--		vSyncEnd    : natural;
--		vMax        : natural;
--		vSyncActive : std_logic
--	);
--    Port ( clk_reader : in  STD_LOGIC;
--           hsync      : out  STD_LOGIC;
--           vsync      : out  STD_LOGIC;
--           rgb : out std_logic_vector(23 downto 0);
--           
--           de      : out  STD_LOGIC;
--                rst : in std_logic;
--            
--           memory_ready : in  std_logic;
--
--            -- Reads are in a burst length of 16
--            read_cmd_enable   : out std_logic;
--            read_cmd_refresh  : out  std_logic;
--            read_cmd_address  : out std_logic_vector(29 downto 0);
--            read_cmd_full     : in  std_logic;
--            read_cmd_empty    : in  std_logic;
--            --
--            read_data_enable  : out std_logic;
--            read_data         : in  std_logic_vector(31 downto 0);
--            read_data_empty   : in  std_logic;
--            read_data_full    : in  std_logic;
--            read_data_count   : in  std_logic_vector(6 downto 0)
--   );
--end mem_reader_vga;
--
--architecture rtl of mem_reader_vga is
--   signal hCounter : unsigned(10 downto 0) := (others => '0');
--   signal vCounter : unsigned(10 downto 0) := (others => '0');
--   signal address  : unsigned(29 downto 0) := (others => '0');
--   signal read_cmd_enable_local : std_logic := '0';
--   signal blank : std_logic;
--   signal red : std_logic_vector(2 downto 0);
--   signal green : std_logic_vector(2 downto 0);
--   signal blue : std_logic_vector(1 downto 0);
--begin
--   read_cmd_address <= std_logic_vector(address);
--   read_cmd_enable  <= read_cmd_enable_local;
--    rgb <= red & green & blue & red & green & blue & red & green & blue;
--    de <= not blank;
--process(clk_reader)
--   begin
--      if rising_edge(clk_reader) then
--         if read_cmd_enable_local = '1' then
--            address <= address + 64;  -- Address is the byte address, so each read is 16 words
--         end if;
--
--         -------------------------------------------
--         -- should we issue a read command?
--         -------------------------------------------
--         read_cmd_enable_local <= '0';
--         if hCounter >= hVisible-64 then
--            read_cmd_refresh <= '1';
--         else
--            read_cmd_refresh <= '0';
--         end if;
--         if hCounter(5 downto 0) = "111100" then -- once out of 64 cycles
--            if vCounter < vVisible-1 then
--               if hCounter < hVisible then 
--                  -- issue a read every 64th cycle of a visible line (except last)
--                  read_cmd_enable_local <= memory_ready and not read_cmd_full;
--               end if;
--            elsif vCounter = vVisible-1 then
--               -- don't issue the last three reads on the last line
--               if hCounter < (hVisible-4*64) then 
--                  read_cmd_enable_local <= memory_ready and not read_cmd_full;
--               end if;
--            elsif vCounter = vMax-1 then 
--               -- prime the read queue just before the first line with 3 read * 16 words * 4 bytes = 192 bytes
--               if hCounter < 4 * 64 then
--                  read_cmd_enable_local <= memory_ready and not read_cmd_full;            
--               end if;
--            end if;   
--         end if;
--         
--         -------------------------------------------
--         -- Should we read a word from the read FIFO
--         -------------------------------------------
--         read_data_enable <= '0';
--
--         -------------------------------------------
--         -- Flushing the MCB's read port at the end of frame
--         -------------------------------------------
--         if vCounter = vVisible then
--         --   read_data_enable <= memory_ready and not read_data_empty;
--            address <= (others => '0');
--         end if;
--
--         -------------------------------------------
--         -- Display pixels and trigger data FIFO reads
--         -------------------------------------------
--         if hCounter < hVisible and vCounter < vVisible then 
--            case hcounter(1 downto 0) is
--               when "00" =>
--                  red   <= read_data( 7 downto 5);
--                  green <= read_data( 4 downto 2);
--                  blue  <= read_data( 1 downto 0);
--               when "01" =>
--                  red   <= read_data(15 downto 13);
--                  green <= read_data(12 downto 10);
--                  blue  <= read_data( 9 downto  8);
--               when "10" =>
--                  red   <= read_data(23 downto 21);
--                  green <= read_data(20 downto 18);
--                  blue  <= read_data(17 downto 16);
--						 -- read_data_enable will be asserted next cycele
--						 -- so read_data will change the one following that
--                  read_data_enable <= memory_ready and not read_data_empty;
--               when others =>
--                  red   <= read_data(31 downto 29);
--                  green <= read_data(28 downto 26);
--                  blue  <= read_data(25 downto 24);
--            end case; 
--				blank <= '0';
--         else
--            red   <= (others => '0');
--            green <= (others => '0');
--            blue  <= (others => '0');
--				blank <= '1';
--         end if;
--
--         -------------------------------------------
--         -- track the horizontal and vertical position
--         -- and generate sync pulses
--         -------------------------------------------
--         if hCounter = hMax then
--            hCounter <= (others => '0');
--            if vCounter = vMax then 
--               vCounter <= (others => '0');
--            else
--               vCounter <= vCounter +1;
--            end if;
--            
--            if vCounter = vSyncStart then
--               vSync <= vSyncActive;
--            end if;
--         
--            if vCounter = vSyncEnd then
--               vSync <= not vSyncActive;
--            end if;
--         else
--            hCounter <= hCounter+1;
--         end if;
--         
--         if hCounter = hSyncStart then
--            hSync <= hSyncActive;
--         end if;
--         
--         if hCounter = hSyncEnd then
--            hSync <= not hSyncActive;
--         end if;         
--      end if;
--   end process;
--end rtl;