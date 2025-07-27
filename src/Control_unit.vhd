----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2025 05:18:26 PM
-- Design Name: 
-- Module Name: Control_unit - Behavioral
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

entity Control_unit is
    port (
        -- Inputs
        op        : in  std_logic_vector(6 downto 0);
        funct3    : in  std_logic_vector(2 downto 0);
        funct7    : in  std_logic_vector(6 downto 0);
        -- Outputs
        result_src     : out std_logic_vector(2 downto 0);
        branch         : out std_logic;
        jump         : out std_logic;
        Mem_write      : out std_logic;
        ALU_control    : out ALU_OP_TYPE_t;
        ALU_src        : out std_logic;
        Imm_src        : out std_logic_vector(2 downto 0);
        sig_reg_write_en : out std_logic;
        access_width : out MEM_ACCESS_WIDTH_t
    );
end Control_unit;

architecture Behavioral of Control_unit is

signal ALU_op : std_logic_vector(1 downto 0);

begin


    
   ALU_decoder : entity work.ALU_decoder(Behavioral)
        port map(
            op_bit5 => op(5),
            funct3 => funct3,
            funct7_bit5 => funct7(5),
            ALU_op => ALU_op,
            ALU_control => ALU_control,
            access_width=>access_width
        ); 
        
    Main_decoder : entity work.Main_decoder(Behavioral)
        port map(
            op => op,       
            -- Outputs
            result_src => result_src,
            branch => branch,
            Mem_write => Mem_write,
            ALU_src => ALU_src,
            Imm_src => Imm_src,
            sig_reg_write_en => sig_reg_write_en,
            ALU_op => ALU_op,
            Jump => jump
        ); 

end Behavioral;

