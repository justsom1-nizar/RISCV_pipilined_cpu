
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.memory_package.all;


entity data_rom is
    port(
        addr            : in std_logic_vector(31 downto 0);
        access_width    : in MEM_ACCESS_WIDTH_t;
        
        data            : out std_logic_vector(31 downto 0)
    );
end data_rom;


architecture Behavioral of data_rom is
    signal memory           : DATA_ROM_MEMORY_ARRAY_t := DATA_ROM_MEMORY_CONTENT;
    signal word_index       : integer := 0;
    signal halfword_index   : integer := 0;
    signal byte_index       : integer := 0;

begin
    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    halfword_index  <= to_integer(unsigned(addr(1 downto 0) and "10"));
    byte_index      <= to_integer(unsigned(addr(1 downto 0)));
    
    
    -- reading
    data <= 
        -- forbidding unaligned access
        (others => '1') when word_index >= DATA_ROM_MEMORY_SIZE_WORDS 
                            or ((access_width = MEM_ACCESS_WIDTH_16 or access_width = MEM_ACCESS_WIDTH_16_UNSIGNED) and addr(0) = '1')
                            or (access_width = MEM_ACCESS_WIDTH_32 and addr(1 downto 0) /= "00") else
                            
        -- 16-bit unisigned
        (31 downto 16 => '0') & memory(word_index, halfword_index+1) & memory(word_index, halfword_index)
            when access_width = MEM_ACCESS_WIDTH_16_UNSIGNED else

        -- 32-bit
        memory(word_index, 3) & memory(word_index, 2) & memory(word_index, 1) & memory(word_index, 0)
            when access_width = MEM_ACCESS_WIDTH_32 else

        -- 8-bit unsigned
        (31 downto 8 => '0') & memory(word_index, byte_index)
        when access_width = MEM_ACCESS_WIDTH_8_UNSIGNED else
        -- 8-bit
        (31 downto 8 => memory(word_index, byte_index)(7)) & memory(word_index, byte_index)
            when access_width = MEM_ACCESS_WIDTH_8 else
        -- 16-bit
        (31 downto 16 => memory(word_index, halfword_index+1)(7)) & memory(word_index, halfword_index+1) & memory(word_index, halfword_index);
        
end Behavioral;