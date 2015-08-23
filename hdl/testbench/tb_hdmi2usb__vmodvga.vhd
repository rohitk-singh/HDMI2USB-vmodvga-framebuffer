--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:12:37 08/05/2015
-- Design Name:   
-- Module Name:   /home/rohit/AcademicResearch/hardware/HDMI2USB-vmodvga/hdl/testbench/tb_hdmi2usb__vmodvga.vhd
-- Project Name:  HDMI2USB-vmodvga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hdmi2usb_vmodvga
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 library UNISIM;
use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_hdmi2usb_vga IS
END tb_hdmi2usb_vga;
 
ARCHITECTURE behavior OF tb_hdmi2usb_vga IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hdmi2usb_vmodvga
    generic(
        C3_SIMULATION : string := "FALSE"
    );
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         tmds : OUT  std_logic_vector(3 downto 0);
         tmdsb : OUT  std_logic_vector(3 downto 0);
         mcb3_dram_dq : INOUT  std_logic_vector(15 downto 0);
         mcb3_dram_a : OUT  std_logic_vector(12 downto 0);
         mcb3_dram_ba : OUT  std_logic_vector(2 downto 0);
         mcb3_dram_ras_n : OUT  std_logic;
         mcb3_dram_cas_n : OUT  std_logic;
         mcb3_dram_we_n : OUT  std_logic;
         mcb3_dram_cke : OUT  std_logic;
         mcb3_dram_dm : OUT  std_logic;
         mcb3_dram_udqs : INOUT  std_logic;
         mcb3_dram_udqs_n : INOUT  std_logic;
         mcb3_rzq : INOUT  std_logic;
         mcb3_zio : INOUT  std_logic;
         mcb3_dram_udm : OUT  std_logic;
         mcb3_dram_odt : OUT  std_logic;
         mcb3_dram_dqs : INOUT  std_logic;
         mcb3_dram_dqs_n : INOUT  std_logic;
         mcb3_dram_ck : OUT  std_logic;
         mcb3_dram_ck_n : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

	--BiDirs
   signal mcb3_dram_dq : std_logic_vector(15 downto 0);
   signal mcb3_dram_udqs : std_logic;
   signal mcb3_dram_udqs_n : std_logic;
   signal mcb3_rzq : std_logic;
   signal mcb3_zio : std_logic;
   signal mcb3_dram_dqs : std_logic;
   signal mcb3_dram_dqs_n : std_logic;

 	--Outputs
   signal tmds : std_logic_vector(3 downto 0);
   signal tmdsb : std_logic_vector(3 downto 0);
   signal mcb3_dram_a : std_logic_vector(12 downto 0);
   signal mcb3_dram_ba : std_logic_vector(2 downto 0);
   signal mcb3_dram_ras_n : std_logic;
   signal mcb3_dram_cas_n : std_logic;
   signal mcb3_dram_we_n : std_logic;
   signal mcb3_dram_cke : std_logic;
   signal mcb3_dram_dm : std_logic;
   signal mcb3_dram_udm : std_logic;
   signal mcb3_dram_odt : std_logic;
   signal mcb3_dram_ck : std_logic;
   signal mcb3_dram_ck_n : std_logic;


 signal mcb3_command               : std_logic_vector(2 downto 0);
   signal mcb3_enable1                : std_logic;
   signal mcb3_enable2              : std_logic;
      signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
   signal mcb3_dram_dqs_n_vector : std_logic_vector(1 downto 0);
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   -- Clock period definitions
   signal mcb3_rdqs_n : std_logic_vector(1 downto 0) := "00";
   constant clk_period : time := 10 ns;
 
 
    function vector (asi:std_logic) return std_logic_vector is
  variable v : std_logic_vector(0 downto 0) ; 
begin
  v(0) := asi;
  return(v); 
end function vector; 

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hdmi2usb_vmodvga 
   generic map(
           C3_SIMULATION => "TRUE"
   )
   PORT MAP (
          clk => clk,
          rst => rst,
          tmds => tmds,
          tmdsb => tmdsb,
          mcb3_dram_dq => mcb3_dram_dq,
          mcb3_dram_a => mcb3_dram_a,
          mcb3_dram_ba => mcb3_dram_ba,
          mcb3_dram_ras_n => mcb3_dram_ras_n,
          mcb3_dram_cas_n => mcb3_dram_cas_n,
          mcb3_dram_we_n => mcb3_dram_we_n,
          mcb3_dram_cke => mcb3_dram_cke,
          mcb3_dram_dm => mcb3_dram_dm,
          mcb3_dram_udqs => mcb3_dram_udqs,
          mcb3_dram_udqs_n => mcb3_dram_udqs_n,
          mcb3_rzq => mcb3_rzq,
          mcb3_zio => mcb3_zio,
          mcb3_dram_udm => mcb3_dram_udm,
          mcb3_dram_odt => mcb3_dram_odt,
          mcb3_dram_dqs => mcb3_dram_dqs,
          mcb3_dram_dqs_n => mcb3_dram_dqs_n,
          mcb3_dram_ck => mcb3_dram_ck,
          mcb3_dram_ck_n => mcb3_dram_ck_n
        );
        
           -- The PULLDOWN component is connected to the ZIO signal primarily to avoid the
-- unknown state in simulation. In real hardware, ZIO should be a no connect(NC) pin.
   zio_pulldown3 : PULLDOWN port map(O => mcb3_zio);
   rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);
   
   
       mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

    process(mcb3_dram_ck)
    begin
      if (rising_edge(mcb3_dram_ck)) then
        if (mcb3_command = "100") then
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "101") then
          mcb3_enable2 <= '1';
        else
          mcb3_enable2 <= mcb3_enable2;
        end if;
        mcb3_enable1     <= mcb3_enable2;
      end if;
    end process;
-----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
    mcb3_dram_dqs_vector(1 downto 0)               <= (mcb3_dram_udqs & mcb3_dram_dqs)
                                                           when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
							   else "ZZ";
    mcb3_dram_dqs_n_vector(1 downto 0)             <= (mcb3_dram_udqs_n & mcb3_dram_dqs_n)
                                                           when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
							   else "ZZ";
    
-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
    mcb3_dram_dqs          <= mcb3_dram_dqs_vector(0)
                              when ( mcb3_enable1 = '1') else 'Z';

    mcb3_dram_udqs          <= mcb3_dram_dqs_vector(1)
                              when (mcb3_enable1 = '1') else 'Z';


     mcb3_dram_dqs_n        <= mcb3_dram_dqs_n_vector(0)
                              when (mcb3_enable1 = '1') else 'Z';
    mcb3_dram_udqs_n         <= mcb3_dram_dqs_n_vector(1)
                              when (mcb3_enable1 = '1') else 'Z';

   
   
mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);

    inst_ddr2_model: entity work.ddr2_model_c3 port map(
    ck => mcb3_dram_ck, 
    ck_n => mcb3_dram_ck_n,
    cke => mcb3_dram_cke,
    cs_n => '0',
    ras_n => mcb3_dram_ras_n,
    cas_n => mcb3_dram_cas_n,
    we_n => mcb3_dram_we_n,
    dm_rdqs => mcb3_dram_dm_vector,
    ba => mcb3_dram_ba,
    addr => mcb3_dram_a,
    dq => mcb3_dram_dq,
    dqs => mcb3_dram_dqs_vector,
    dqs_n => mcb3_dram_dqs_n_vector,
    rdqs_n => mcb3_rdqs_n,
    odt => mcb3_dram_odt
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
--      wait for 100 ns;
--      rst <= '1';
--      wait for 100 ns;
      --rst <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
