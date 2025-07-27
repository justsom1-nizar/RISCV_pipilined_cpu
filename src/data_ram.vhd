----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2025 09:59:23 AM
-- Design Name: 
-- Module Name: data_ram - Behavioral
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


entity data_ram is
    port(
        clk             : in std_logic;
        addr            : in std_logic_vector(31 downto 0);
        access_width    : in MEM_ACCESS_WIDTH_t;
        write_enable    : in std_logic;
        data_in         : in std_logic_vector(31 downto 0);
        
        data_out        : out std_logic_vector(31 downto 0)
    );
end data_ram;


architecture Behavioral of data_ram is
    signal memory           : DATA_RAM_MEMORY_ARRAY_t;
    signal word_index       : integer := 0;
    signal halfword_index   : integer := 0;
    signal byte_index       : integer := 0;

begin

    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    halfword_index  <= to_integer(unsigned(addr(1 downto 0) and "10"));
    byte_index      <= to_integer(unsigned(addr(1 downto 0)));
    
    
    -- reading
    data_out <= 
        -- forbidding unaligned access
        (others => '1') when word_index >= DATA_RAM_MEMORY_SIZE_WORDS 
                            or (access_width = MEM_ACCESS_WIDTH_16 and addr(0) = '1')
                            or (access_width = MEM_ACCESS_WIDTH_32 and addr(1 downto 0) /= "00") else
                            
        -- 16-bit
        (31 downto 16 => memory(word_index, halfword_index+1)(7)) & memory(word_index, halfword_index+1) & memory(word_index, halfword_index)
            when access_width = MEM_ACCESS_WIDTH_16 else

        -- 32-bit
        memory(word_index, 3) & memory(word_index, 2) & memory(word_index, 1) & memory(word_index, 0)
            when access_width = MEM_ACCESS_WIDTH_32 else
            
        -- 8-bit
        (31 downto 8 => memory(word_index, byte_index)(7)) & memory(word_index, byte_index);
        
        
        
    -- writing
    process(clk)
    begin
        if rising_edge(clk) then
            if(word_index < DATA_RAM_MEMORY_SIZE_WORDS) then
                case access_width is
                    when MEM_ACCESS_WIDTH_16 =>    -- 16-bit
                        -- forbidding unaligned access
                        if addr(0) = '0' and write_enable = '1' then
                                memory(word_index, halfword_index) <= data_in(7 downto 0);
                                memory(word_index, halfword_index+1) <= data_in(15 downto 8);
                        end if;
                        
                    when MEM_ACCESS_WIDTH_32 =>  -- 32-bit
                        -- forbidding unaligned access
                        if addr(1 downto 0) = "00" and write_enable = '1' then
                                memory(word_index, 0) <= data_in(7 downto 0);
                                memory(word_index, 1) <= data_in(15 downto 8);
                                memory(word_index, 2) <= data_in(23 downto 16);
                                memory(word_index, 3) <= data_in(31 downto 24);
                        end if;
                        
                    when others =>  -- 8-bit
                        if(write_enable = '1') then
                            memory(word_index, byte_index) <= data_in(7 downto 0);
                        end if;
                end case;
            end if;
        end if;
        
    end process;


end Behavioral;