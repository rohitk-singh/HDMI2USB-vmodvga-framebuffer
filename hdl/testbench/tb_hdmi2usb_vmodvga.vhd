--------------------------------------------------------------------------------
-- Engineer: Rohit Kumar Singh <rohitks1337@gmail.com>
--
-- Create Date:   14:21:56 08/03/2015
-- Design Name:   
-- Module Name:   /home/rohit/AcademicResearch/hardware/HDMI2USB-vmodvga/ise/tb_hdmi2usb_vmodvga.vhd
-- Project Name:  HDMI2USB-vmodvga
-- Target Device:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hdmi2usb_vmodvga
-- 
--

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_hdmi2usb_vmodvga IS
END tb_hdmi2usb_vmodvga;
 
ARCHITECTURE behavior OF tb_hdmi2usb_vmodvga IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hdmi2usb_vmodvga
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         tmds : OUT  std_logic_vector(3 downto 0);
         tmdsb : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal tmds : std_logic_vector(3 downto 0);
   signal tmdsb : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hdmi2usb_vmodvga PORT MAP (
          clk => clk,
          rst => rst,
          tmds => tmds,
          tmdsb => tmdsb
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;	
      rst <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
