----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/04/2025 07:27:23 PM
-- Design Name: 
-- Module Name: program_counter - Behavioral
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



entity program_counter is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        pc_next     : in std_logic_vector(31 downto 0);
        stall_pc   : in std_logic;
        pc          : out std_logic_vector(31 downto 0)
    );
end program_counter;



architecture Behavioral of program_counter is
    signal pc_signal        : std_logic_vector(31 downto 0);
    
begin
    pc <= pc_signal;
    
    process(clk, rst)
    begin
        if rst = '1' then
            pc_signal <= (others => '0');
        elsif rising_edge(clk) then
            if stall_pc = '0' then
                pc_signal <= pc_next;
            end if;
        end if;
    end process;
    
end Behavioral;