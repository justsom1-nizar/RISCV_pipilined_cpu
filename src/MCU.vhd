-- filepath: c:\everything\FPGA_projects\RISCV_pipilined_cpu\src\MCU.vhd
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2025
-- Design Name: 
-- Module Name: MCU - Behavioral
-- Project Name: RISCV Pipelined CPU
-- Target Devices: 
-- Tool Versions: 
-- Description: Top-level MCU connecting CPU, instruction memory, and data memory
-- 
-- Dependencies: CPU.vhd, instruction_memory.vhd, data_memory.vhd, memory_package.vhd
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

entity MCU is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end MCU;

architecture Behavioral of MCU is
    -- Instruction memory interface signals
    signal pc_to_instr_mem      : std_logic_vector(31 downto 0);
    signal instr_from_mem       : std_logic_vector(31 downto 0);
    
    -- Data memory interface signals
    signal data_mem_addr        : std_logic_vector(31 downto 0);
    signal data_to_mem          : std_logic_vector(31 downto 0);
    signal data_from_mem        : std_logic_vector(31 downto 0);
    signal mem_write_enable     : std_logic;
    signal mem_access_width     : MEM_ACCESS_WIDTH_t;

begin

    -- CPU instantiation
    cpu_inst : entity work.data_path(Behavioral)
        port map(
            clk                             => clk,
            rst                             => rst,
            -- Instruction memory interface
            instruction_memory_CPU_in       => instr_from_mem,
            PC_CPU_out                      => pc_to_instr_mem,
            -- Data memory interface
            data_memory_CPU_in              => data_from_mem,
            data_memory_CPU_out             => data_to_mem,
            addr_memory_CPU_out             => data_mem_addr,
            access_width_memory_CPU_out     => mem_access_width,
            mem_write_enable_memory_CPU_out => mem_write_enable
        );

    -- Instruction memory instantiation
    instr_mem_inst : entity work.instruction_memory(Behavioral)
        port map(
            addr  => pc_to_instr_mem,
            instr => instr_from_mem
        );

    -- Data memory instantiation
    data_mem_inst : entity work.data_memory(Behavioral)
        port map(
            clk              => clk,
            addr             => data_mem_addr,
            mem_write_enable => mem_write_enable,
            access_width     => mem_access_width,
            data_in          => data_to_mem,
            data_out         => data_from_mem
        );

end Behavioral;