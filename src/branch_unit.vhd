----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/13/2025 06:56:52 PM
-- Design Name: 
-- Module Name: branch_unit - Behavioral
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



entity branch_unit is
    port(
        opcode          : in std_logic_vector(6 downto 0);
        branch_type     : in std_logic_vector(2 downto 0);
        alu_result      : in std_logic_vector(31 downto 0);
        alu_zero_flag   : in std_logic;
        next_pc_sel     : out std_logic_vector(1 downto 0)
    );
end branch_unit;

architecture Behavioral of branch_unit is

    -- RISC-V Opcode Constants
    constant OP_BRANCH      : std_logic_vector(6 downto 0) := "1100011";  -- Branch instructions
    constant OP_JAL         : std_logic_vector(6 downto 0) := "1101111";  -- Jump and Link
    constant OP_JALR        : std_logic_vector(6 downto 0) := "1100111";  -- Jump and Link Register


    -- Branch Type Constants (funct3 field)
    constant BRANCH_BEQ     : std_logic_vector(2 downto 0) := "000";      -- Branch if Equal
    constant BRANCH_BNE     : std_logic_vector(2 downto 0) := "001";      -- Branch if Not Equal
    constant BRANCH_BLT     : std_logic_vector(2 downto 0) := "100";      -- Branch if Less Than
    constant BRANCH_BGE     : std_logic_vector(2 downto 0) := "101";      -- Branch if Greater or Equal
    constant BRANCH_BLTU    : std_logic_vector(2 downto 0) := "110";      -- Branch if Less Than Unsigned
    constant BRANCH_BGEU    : std_logic_vector(2 downto 0) := "111";      -- Branch if Greater or Equal Unsigned
    
    -- PC Next Source Constants
    constant PC_PLUS_4      : std_logic_vector(1 downto 0) := "00";       -- Next sequential instruction
    constant PC_TARGET      : std_logic_vector(1 downto 0) := "01";       -- Branch target address
    constant PC_ALU      : std_logic_vector(1 downto 0) := "10";       -- Jump target address


begin

    -- Your logic implementation goes here
    -- Example structure:
    process(opcode, branch_type, alu_result, alu_zero_flag)
    begin
        case opcode is
            when OP_BRANCH =>
                case branch_type is
                    when BRANCH_BEQ =>
                        if alu_zero_flag = '0' then
                            next_pc_sel <= PC_PLUS_4;
                        end if;
                    when BRANCH_BNE =>
                        if alu_zero_flag = '1' then
                            next_pc_sel <= PC_PLUS_4;

                        end if;
                    when BRANCH_BLT |  BRANCH_BLTU =>
                        if signed(alu_result) = 1 then
                            next_pc_sel <= PC_TARGET;
                        else
                            next_pc_sel <= PC_PLUS_4;
                        end if;
                    when BRANCH_BGE | BRANCH_BGEU =>
                        if signed(alu_result) = 0 then
                            next_pc_sel <= PC_TARGET;
                        else    
                            next_pc_sel <= PC_PLUS_4;
                        end if;
                    when others =>
                        next_pc_sel <= PC_PLUS_4;
                end case;
            
            when OP_JAL =>
                -- Jump and Link
                next_pc_sel <= PC_TARGET;
            
            when OP_JALR =>
                -- Jump and Link Register
                next_pc_sel <= PC_ALU;
            
            when others =>
                -- All other instructions continue to next instruction
                next_pc_sel <= PC_PLUS_4;
        end case;
    end process;

end Behavioral;