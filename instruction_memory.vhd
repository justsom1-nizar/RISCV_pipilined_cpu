----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/04/2025 06:54:14 PM
-- Design Name: 
-- Module Name: instruction_memory - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_package.all;

entity instruction_memory is
    port(
        addr        : in std_logic_vector(31 downto 0);
        
        instr       : out std_logic_vector(31 downto 0)
    );
end instruction_memory;


architecture Behavioral of instruction_memory is
    signal memory           : INSTRUCTION_MEMORY_ARRAY_t := INSTRUCTION_MEMORY_CONTENT;
    signal word_index       : integer := 0;

begin
    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    
    instr <= 
        -- forbidding unaligned access
        (others => '1') when word_index >= INSTRUCTION_MEMORY_SIZE_WORDS or addr(1 downto 0) /= "00" else
        memory(word_index);
        
end Behavioral;