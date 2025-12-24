----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2025 11:56:19 AM
-- Design Name: 
-- Module Name: pc_testbench - Behavioral
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
use IEEE.NUMERIC_STD.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc_testbench is
--  Port ( );
end pc_testbench;

architecture Behavioral of pc_testbench is
    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal pc :std_logic_vector(31 downto 0);
    signal pc_next :std_logic_vector(31 downto 0);

begin

    clk <= not clk after 5ns;  -- 100MHz clock
    pc_next <= std_logic_vector(unsigned(pc) + 4);
    CPU : entity work.program_counter(Behavioral)
        port map(
            rst => rst,
            clk => clk,
            pc=>pc,
            pc_next=>pc_next
            
        );
        
        
    process
    begin
    
        wait for 12ns;
        rst <= '0';
        wait for 1ms;
        rst <= '1';
        wait;
        
    end process;


end Behavioral;


