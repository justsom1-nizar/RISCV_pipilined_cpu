-- Copyright (C) 2024 FPGA Project
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- MODIFICATION HISTORY:
-- Ver   Who  Date        Changes
-- ----- --- ----------- -----------------------------------------------
-- 1.0   Nizar 01/05/2026  Initial creation
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_package.all;

-- ============================================================================
-- Entity: BusController
-- ============================================================================
-- Description: Bus controller that manages communication between CPU,
--              data memory, and I2C interface. Handles address decoding and
--              arbitration of shared bus resources.
--

entity BusController is
  generic (
    ADDRESS_WIDTH : integer := 32;
    DATA_WIDTH    : integer := 32

  );
  port (
    -- System Signals
    clk   : in std_logic;
    rst   : in std_logic;
    

    -- CPU Interface (Master)
    cpu_addr       : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    cpu_data_out   : in std_logic_vector(DATA_WIDTH-1 downto 0);
    cpu_data_in    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    cpu_we         : in std_logic;
    -- cpu_re         : in std_logic;
    -- cpu_ready      : out std_logic;
    
    -- Data Memory Interface (Slave)
    mem_addr       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    mem_data_out   : in std_logic_vector(DATA_WIDTH-1 downto 0);
    mem_data_in    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    mem_we         : out std_logic;
    -- mem_re         : out std_logic;
    -- mem_valid      : in std_logic;
    
    -- I2C Interface (Slave)
    i2c_addr       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    i2c_data_out   : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i2c_data_in    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    i2c_we         : out std_logic;
    i2c_re         : out std_logic;
    i2c_valid      : in std_logic

    --Active Interface
    bus_interface_state : out BUS_INTERFACE_STATE_t
  );
end BusController;


architecture Structural of BusController is

  -- =========================================================================
  -- Signal Declarations
  -- =========================================================================
  signal addr_upper_bits         : std_logic_vector(7 downto 0);
  signal is_i2c_access           : std_logic;
  signal is_mem_access           : std_logic;
  
  -- Data Memory Interface Signals
  signal sig_mem_addr            : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal sig_mem_data_out        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sig_mem_data_in         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sig_mem_we              : std_logic;
  signal sig_mem_re              : std_logic;
  signal sig_mem_valid           : std_logic;
  
  -- I2C Interface Signals
  signal sig_i2c_addr            : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal sig_i2c_data_out        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sig_i2c_data_in         : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sig_i2c_we              : std_logic;
  signal sig_i2c_re              : std_logic;
  signal sig_i2c_valid           : std_logic;
  

    


begin
    addr_upper_bits<=cpu_addr(31 downto 24);
    bus_interface_state <= 
        BUS_INTERFACE_STATE_I2C when addr_upper_bits = I2C_ADDR_BASE else
        BUS_INTERFACE_STATE_RAM when addr_upper_bits = MEM_ADDR_BASE else
        BUS_INTERFACE_STATE_IDLE;

    sig_mem_addr<=cpu_addr when bus_interface_state=BUS_INTERFACE_STATE_RAM else (others=>'0');
    sig_mem_data_in<=cpu_data_out when bus_interface_state=BUS_INTERFACE_STATE_RAM else (others=>'0');
    sig_mem_we<=cpu_we when bus_interface_state=BUS_INTERFACE_STATE_RAM else '0';

    sig_i2c_addr<=cpu_addr when bus_interface_state=BUS_INTERFACE_STATE_I2C else (others=>'0');
    sig_i2c_data_in<=cpu_data_out when bus_interface_state=BUS_INTERFACE_STATE_I2C else (others=>'0');
    sig_i2c_we<=cpu_we when bus_interface_state=BUS_INTERFACE_STATE_I2C else '0';
    

    -- Data memory instantiation
    data_mem_inst : entity work.data_memory(Behavioral)
        port map(
            clk              => clk,
            addr             => sig_mem_addr,
            mem_write_enable => sig_mem_we,
            access_width     => mem_access_width,
            data_in          => sig_mem_data_in,
            data_out         => mem_data_out
        );
        
    --I2C interface instantiation
    i2c_interface_inst : entity work.i2c_memory_interface(Behavioral)
        port map(
            RegisterAddr => sig_i2c_addr,
            Clk => clk,
            Reset => rst,
            DataIn => sig_i2c_data_in,
            WriteEnable => sig_i2c_we,
            DataOut => i2c_data_out
        );
  

end Structural;
