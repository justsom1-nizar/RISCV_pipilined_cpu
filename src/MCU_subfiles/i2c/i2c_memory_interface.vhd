----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nizar K.
-- 
-- Create Date: 12/24/2025 07:44:47 PM
-- Design Name: 
-- Module Name: i2c_memory_interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.work_package.all;
--use IEEE.NUMERIC_STD.ALL;

entity i2c_memory_interface is
    Port ( RegisterAddr : in STD_LOGIC_VECTOR (31 downto 0);
            Clk : in STD_LOGIC;
            Reset : in STD_LOGIC;
            DataIn : in STD_LOGIC_VECTOR (31 downto 0);
            WriteEnable : in STD_LOGIC;

            DataOut : out STD_LOGIC_VECTOR (31 downto 0);
            SDA : inout STD_LOGIC
            -- SCL : in STD_LOGIC

        );
end i2c_memory_interface;
architecture Rtl of i2c_memory_interface is
    --Registers
    signal  REG_I2C_ADDRESS      : STD_LOGIC_VECTOR (7 downto 0); := x"00";
    signal  REG_I2C_NUMB_BYTES_TO_WRITE
                                    : STD_LOGIC_VECTOR (7 downto 0); := x"00";
    signal REG_I2C_NUMB_BYTES_TO_READ
                                    : STD_LOGIC_VECTOR (7 downto 0); := x"00";
    signal  REG_I2C_CONTROL         : STD_LOGIC_VECTOR (7 downto 0); := x"00";
    signal  REG_I2C_STATUS          : STD_LOGIC_VECTOR (7 downto 0); := x"00";

    signal I2C_MEMORY_WRITTEN_ARRAY : I2C_MEMORY_ARRAY_t := (others => (others => '0'));
    signal I2C_MEMORY_RED_ARRAY : I2C_MEMORY_ARRAY_t := (others => (others => '0'));

    --i2c master controller signals
    signal sig_start_sending : STD_LOGIC := '0';
    signal sig_byte_to_write : STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0) := (others => '0');
    signal sig_lastByte : STD_LOGIC := '0';
    signal sig_currentState : state_type;
    signal sig_byte_to_read : STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0); := (others => '0');

    begin
        i2c_master_controller_inst: entity work.i2c_master_controller
         port map(
            SCL => SCL,
            SDA => SDA,
            Start_sending => sig_start_sending,
            Byte_to_write => sig_byte_to_write,
            lastByte => sig_lastByte,
            currentState => sig_currentState,
            Byte_to_read => sig_byte_to_read
        );

    end Rtl;