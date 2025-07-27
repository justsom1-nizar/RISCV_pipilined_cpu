----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/04/2025 03:39:12 PM
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        read_reg1     : in  std_logic_vector(4 downto 0); -- 5-bit register index
        read_reg2     : in  std_logic_vector(4 downto 0);
        write_reg     : in  std_logic_vector(4 downto 0);
        write_data    : in  std_logic_vector(31 downto 0);
        reg_write_en  : in  std_logic;
        read_data1    : out std_logic_vector(31 downto 0);
        read_data2    : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    type reg_array is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    -- Combinational read ports
    process(read_reg1, read_reg2, regs)
    begin
        if read_reg1 = "00000" then
            read_data1 <= (others => '0');
        else
            read_data1 <= regs(to_integer(unsigned(read_reg1)));
        end if;

        if read_reg2 = "00000" then
            read_data2 <= (others => '0');
        else
            read_data2 <= regs(to_integer(unsigned(read_reg2)));
        end if;
    end process;

    -- Synchronous write port
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif reg_write_en = '1' then
                if write_reg /= "00000" then
                    regs(to_integer(unsigned(write_reg))) <= write_data;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
