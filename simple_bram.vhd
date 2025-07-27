----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/04/2025 05:13:08 PM
-- Design Name: 
-- Module Name: simple_bram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.memory_package.all;


entity simple_bram is
    port(
        clk                 : in std_logic;
        addr                : in std_logic_vector(31 downto 0);
        mem_write_enable    : in std_logic;
        access_width        : in MEM_ACCESS_WIDTH_t;
        data_in             : in std_logic_vector(31 downto 0);
        
        data_out            : out std_logic_vector(31 downto 0)
    );
end simple_bram;



architecture Behavioral of simple_bram is
    signal data_out_ram_signal  : std_logic_vector(31 downto 0);
    signal data_out_rom_signal  : std_logic_vector(31 downto 0);
    signal addr_relative        : std_logic_vector(31 downto 0);

begin

    addr_relative <= std_logic_vector(unsigned(addr) - to_unsigned(DATA_RAM_BASE_ADDRESS, addr'length))
                        when to_integer(unsigned(addr)) >= DATA_RAM_BASE_ADDRESS
                        else
                     std_logic_vector(unsigned(addr) - to_unsigned(DATA_MEMORY_BASE_ADDRESS, addr'length));

    data_ram_ : entity work.data_ram(Behavioral)
        port map(
            clk => clk,
            addr => addr_relative,
            access_width => access_width,
            write_enable => mem_write_enable,
            data_in => data_in,
            
            data_out => data_out_ram_signal
        );
        
        
    data_rom : entity work.data_rom(Behavioral)
        port map(
            addr => addr_relative,
            access_width => access_width,
            
            data => data_out_rom_signal
        );
        
        
    data_out <= data_out_ram_signal when to_integer(unsigned(addr)) >= DATA_RAM_BASE_ADDRESS else data_out_rom_signal;


end Behavioral;