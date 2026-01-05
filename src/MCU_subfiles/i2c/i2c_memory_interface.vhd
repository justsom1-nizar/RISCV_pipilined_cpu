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
    Port ( state : in state_type;
           Byte_to_Read : in STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0);

           Start_sending_trigger : out STD_LOGIC;
           lastByte : out STD_LOGIC;
           Byte_to_write : out STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0);
           Data_to_read : out STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0));
end i2c_memory_interface;
architecture Behavioral of i2c_memory_interface is
    begin
        