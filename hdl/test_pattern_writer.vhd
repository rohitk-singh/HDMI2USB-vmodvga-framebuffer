----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Writes a simple test pattern into a MCB connected RAM
-- 
-- Writes a byte at time over a 32 bit interface.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Test_pattern_writer is
	generic(
		hVisible : natural;
		vVisible : natural
	);
	port(clk               : in  STD_LOGIC;
		 memory_ready      : in  std_logic;
		 completed         : out std_logic;
		 write_cmd_enable  : out std_logic;
		 write_cmd_address : out std_logic_vector(29 downto 0);
		 write_cmd_empty   : in  std_logic;
		 write_cmd_full    : in  std_logic;

		 write_data_empty  : in  std_logic;
		 write_data_count  : in  std_logic_vector(6 downto 0); -- How many words are queued 
		 write_data_enable : out std_logic;
		 write_mask        : out std_logic_vector(3 downto 0);
		 write_data        : out std_logic_vector(31 downto 0);

		 rst               : in  std_logic
	);
end Test_pattern_writer;

architecture rtl of Test_pattern_writer is
	signal x       : unsigned(10 downto 0) := (others => '0');
	signal y       : unsigned(10 downto 0) := (others => '0');
	signal address : unsigned(29 downto 0) := (others => '0');

	type states is (RESET_STATE, BUSY_WRITING, WRITING_DONE);
	signal state : states := RESET_STATE;

	signal data : unsigned(31 downto 0) := (others => '0');
	signal write_cmd_enable_q : std_logic := '0';
	signal write_data_enable_q : std_logic := '0';

begin
	
	write_data        <= std_logic_vector(data);
	write_cmd_address <= std_logic_vector(address);
	write_mask        <= "0000";
	write_cmd_enable  <= write_cmd_enable_q;
	write_data_enable <= write_data_enable_q;
	
	process(clk, rst)
	begin
		if rst = '1' then
			x         <= (others => '0');
			y         <= (others => '0');
			address   <= (others => '0');
			state     <= RESET_STATE;
			completed <= '0';

		elsif rising_edge(clk) then
			case state is
				when RESET_STATE =>
					-- If memory is ready go to writing state

					if memory_ready = '1' then
						state <= BUSY_WRITING;
					end if;
				
				
				-- NOTE: 2 clock cycles latency b/w rising edge of memory_ready 
				--	     and that of write_cmd_enable & write_data_enable
				-- 	     1 cycle lost for memory_ready
				-- 	     another cycle lost for switching b/w states RESET_STATE to BUSY_WRITING
				--       though this cycle can be recovered if definitely required. 
				--       for now, left as it is i.e, 2 cycle latency
				
				when BUSY_WRITING =>
					-- Write to memory

					if write_cmd_empty = '1' and write_data_empty = '1' then
						write_cmd_enable_q  <= '1';
						write_data_enable_q <= '1';
					end if;

					if write_cmd_enable_q = '1' then
						write_cmd_enable_q  <= '0';
						write_data_enable_q <= '0';

						address <= address + 4;
						data    <= data + 1;
						x       <= x + 1;
						
						if x = hVisible - 1 then
							x <= (others => '0');
							y <= y + 1;
						end if;
						
						if x = hVisible - 1 and y = vVisible - 1 then
							y <= (others => '0');
							
							state               <= WRITING_DONE;
							completed           <= '1';
							write_cmd_enable_q  <= '0';
							write_data_enable_q <= '0';
							address             <= (others => '0');
							data                <= (others => '0');
						end if;
						
					end if;

				when WRITING_DONE =>
					--Do Nothing, Idle

					completed <= '1';
			end case;

		end if;
	end process;
end rtl;