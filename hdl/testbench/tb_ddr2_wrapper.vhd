--------------------------------------------------------------------------------
-- Engineer: Rohit Kumar Singh
--
-- Create Date:   03:53:17 08/04/2015
-- Design Name:   
-- Module Name:   /home/rohit/AcademicResearch/hardware/HDMI2USB-vmodvga/hdl/tb_ddr2_wrapper.vhd
-- Project Name:  HDMI2USB-vmodvga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ddr2_wrapper
-- 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ddr2_wrapper IS
END tb_ddr2_wrapper;
 
ARCHITECTURE behavior OF tb_ddr2_wrapper IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ddr2_wrapper
    Generic( 
        C3_SIMULATION         : string  := "FALSE"
        );
    PORT(
         clk_sys : IN  std_logic;
         c3_clk0 : OUT  std_logic;
         clk_writer : IN  std_logic;
         clk_reader : IN  std_logic;
         write_cmd_enable : IN  std_logic;
         write_cmd_empty : OUT  std_logic;
         write_cmd_full : OUT  std_logic;
         write_cmd_address : IN  std_logic_vector(29 downto 0);
         write_data_enable : IN  std_logic;
         write_mask : IN  std_logic_vector(3 downto 0);
         write_data : IN  std_logic_vector(31 downto 0);
         write_data_empty : OUT  std_logic;
         write_data_full : OUT  std_logic;
         write_data_count : OUT  std_logic_vector(6 downto 0);
         read_cmd_enable : IN  std_logic;
         read_cmd_address : IN  std_logic_vector(29 downto 0);
         read_cmd_full : OUT  std_logic;
         read_cmd_empty : OUT  std_logic;
         read_data_enable : IN  std_logic;
         read_data : OUT  std_logic_vector(31 downto 0);
         read_data_empty : OUT  std_logic;
         read_data_full : OUT  std_logic;
         read_data_count : OUT  std_logic_vector(6 downto 0);
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
         mcb3_dram_ck_n : OUT  std_logic;
         calib_done : OUT  std_logic;
         read_error : OUT  std_logic;
         read_overflow : OUT  std_logic;
         write_error : OUT  std_logic;
         write_underrun : OUT  std_logic;
         rst : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_sys : std_logic := '0';
   signal clk_writer : std_logic := '0';
   signal clk_reader : std_logic := '0';
   signal write_cmd_enable : std_logic := '0';
   signal write_cmd_address : std_logic_vector(29 downto 0) := (others => '0');
   signal write_data_enable : std_logic := '0';
   signal write_mask : std_logic_vector(3 downto 0) := (others => '0');
   signal write_data : std_logic_vector(31 downto 0) := (others => '0');
   signal read_cmd_enable : std_logic := '0';
   signal read_cmd_address : std_logic_vector(29 downto 0) := (others => '0');
   signal read_data_enable : std_logic := '0';
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
   signal c3_clk0 : std_logic;
   signal write_cmd_empty : std_logic;
   signal write_cmd_full : std_logic;
   signal write_data_empty : std_logic;
   signal write_data_full : std_logic;
   signal write_data_count : std_logic_vector(6 downto 0);
   signal read_cmd_full : std_logic;
   signal read_cmd_empty : std_logic;
   signal read_data : std_logic_vector(31 downto 0);
   signal read_data_empty : std_logic;
   signal read_data_full : std_logic;
   signal read_data_count : std_logic_vector(6 downto 0);
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
   signal calib_done : std_logic;
   signal read_error : std_logic;
   signal read_overflow : std_logic;
   signal write_error : std_logic;
   signal write_underrun : std_logic;

   -- Clock period definitions
   constant clk_sys_period : time := 10 ns;
   constant clk_writer_period : time := 50 ns;
   constant clk_reader_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ddr2_wrapper 
   generic map(
    C3_SIMULATION  => "TRUE")
    
   PORT MAP (
          clk_sys => clk_sys,
          c3_clk0 => c3_clk0,
          clk_writer => clk_writer,
          clk_reader => clk_reader,
          write_cmd_enable => write_cmd_enable,
          write_cmd_empty => write_cmd_empty,
          write_cmd_full => write_cmd_full,
          write_cmd_address => write_cmd_address,
          write_data_enable => write_data_enable,
          write_mask => write_mask,
          write_data => write_data,
          write_data_empty => write_data_empty,
          write_data_full => write_data_full,
          write_data_count => write_data_count,
          read_cmd_enable => read_cmd_enable,
          read_cmd_address => read_cmd_address,
          read_cmd_full => read_cmd_full,
          read_cmd_empty => read_cmd_empty,
          read_data_enable => read_data_enable,
          read_data => read_data,
          read_data_empty => read_data_empty,
          read_data_full => read_data_full,
          read_data_count => read_data_count,
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
          mcb3_dram_ck_n => mcb3_dram_ck_n,
          calib_done => calib_done,
          read_error => read_error,
          read_overflow => read_overflow,
          write_error => write_error,
          write_underrun => write_underrun,
          rst => rst
        );

   -- Clock process definitions
   clk_sys_process :process
   begin
		clk_sys <= '0';
		wait for clk_sys_period/2;
		clk_sys <= '1';
		wait for clk_sys_period/2;
   end process;
 
   clk_writer_process :process
   begin
		clk_writer <= '0';
		wait for clk_writer_period/2;
		clk_writer <= '1';
		wait for clk_writer_period/2;
   end process;
 
   clk_reader_process :process
   begin
		clk_reader <= '0';
		wait for clk_reader_period/2;
		clk_reader <= '1';
		wait for clk_reader_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;	
      rst <= '0';

      wait for clk_sys_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
