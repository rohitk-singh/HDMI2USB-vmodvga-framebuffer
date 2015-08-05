----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Writes a simple test pattern into a MCB connected RAM
-- 
-- Writes a byte at time over a 32 bit interface.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Test_pattern_writer is
   Generic (
      hVisible : natural;
      vVisible : natural
   );
   Port ( clk : in  STD_LOGIC;
      memory_ready      : IN std_logic;
      completed         : OUT std_logic;
      write_cmd_enable  : OUT std_logic;
      write_cmd_address : OUT std_logic_vector(29 downto 0);
      write_cmd_empty   : IN  std_logic;
      write_cmd_full    : IN  std_logic;
      
      write_data_empty  : IN  std_logic;
      write_data_count  : IN  std_logic_vector(6 downto 0); -- How many words are queued 
      write_data_enable : OUT std_logic;
      write_mask        : OUT std_logic_vector(3 downto 0);
      write_data        : OUT std_logic_vector(31 downto 0)
    );
end Test_pattern_writer;

architecture rtl of Test_pattern_writer is   
   signal x       : unsigned (10 downto 0) := (others => '0');
   signal y       : unsigned (10 downto 0) := (others => '0');
   signal address : unsigned (21 downto 0) := (others => '0');
   
   signal colour                : std_logic_vector(7 downto 0);
   signal pending_write         : std_logic := '0';
   signal start_write           : std_logic := '0';
   signal pending_write_address : std_logic_vector (21 downto 0) := (others => '0');
   signal completed_reg         : std_logic := '0';
begin
   colour <= std_logic_vector(x(8 downto 6) & y(8 downto 6) & (x(5 downto 4)+y(5 downto 4)));
   completed <= '1' when y = to_unsigned(vVisible,11) else '0';
   
process(clk)
   begin
      if rising_edge(clk) then
         write_cmd_address <= "00000000" & pending_write_address;
         write_cmd_enable <= pending_write;

         -- a white outline, with colour blocks			
         if x = 0 or y = 0 or x = hVisible -1 or y = vVisible - 1 then 
            write_data <= x"FFFFFFFF";
         elsif x = 100 or y = 100 or x = hVisible -101 or y = vVisible - 101 then 
            write_data <= x"FFFFFFFF";
         else
             write_data <= colour & colour & colour  & colour;
         end if;
      
         if start_write = '1' then
            pending_write <= '1';
            pending_write_address <= std_logic_vector(address(21 downto 2) & "00");
            write_data_enable <= '1';
            case address(1 downto 0) is
               when "00"   => write_mask <= "1110";
               when "01"   => write_mask <= "1101";
               when "10"   => write_mask <= "1011";
               when others => write_mask <= "0111";
            end case;
            
            address <= address + 1;
            if x = to_unsigned(hVisible-1,11) then
               x <= (others => '0');
               y <= y + 1;
            else
               x <= x + 1;
            end if;               
         else
            write_data_enable <= '0';
            pending_write <= '0';
         end if;

         start_write <=  '0';
         if write_data_count(6) = '0' and write_cmd_empty = '1' and write_data_empty = '1' then
            -- Do we need to actually write anything?
            if y /= to_unsigned(vVisible,11)  then
               start_write <= memory_ready;
            end if; 
         end if;
      end if;
   end process;
end rtl;