----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2025 05:47:43 PM
-- Design Name: 
-- Module Name: Main_decoder - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main_decoder is
    port (
        -- Inputs
        op        : in  std_logic_vector(6 downto 0);

        -- Outputs
        result_src     : out std_logic_vector(2 downto 0);
        branch         : out std_logic;
        Mem_write      : out std_logic;
        ALU_src        : out std_logic;
        Imm_src        : out std_logic_vector(2 downto 0);
        sig_reg_write_en : out std_logic;
        ALU_op         : out  std_logic_vector(1 downto 0);
        jump           : out std_logic
    );
end Main_decoder;

architecture Behavioral of Main_decoder is
-- RISC-V Instruction Type Opcodes (7 bits)
    constant OP_R_TYPE    : std_logic_vector(6 downto 0) := "0110011"; -- R-type (ADD, SUB, etc.)
    constant OP_I_TYPE    : std_logic_vector(6 downto 0) := "0010011"; -- I-type (ADDI, etc.)
    constant OP_LOAD      : std_logic_vector(6 downto 0) := "0000011"; -- Load instructions
    constant OP_STORE     : std_logic_vector(6 downto 0) := "0100011"; -- Store instructions
    constant OP_BRANCH    : std_logic_vector(6 downto 0) := "1100011"; -- Branch instructions
    constant OP_JAL       : std_logic_vector(6 downto 0) := "1101111"; -- JAL
    constant OP_JALR      : std_logic_vector(6 downto 0) := "1100111"; -- JALR
    constant OP_LUI       : std_logic_vector(6 downto 0) := "0110111"; -- LUI
    constant OP_AUIPC     : std_logic_vector(6 downto 0) := "0010111"; -- AUIPC
    
    -- Immediate source select constants
    constant IMM_I_TYPE   : std_logic_vector(2 downto 0) := "000"; -- I-type immediate
    constant IMM_S_TYPE   : std_logic_vector(2 downto 0) := "001"; -- S-type immediate
    constant IMM_B_TYPE   : std_logic_vector(2 downto 0) := "010"; -- B-type immediate
    constant IMM_J_TYPE   : std_logic_vector(2 downto 0) := "011"; -- J-type immediate
    constant IMM_U_TYPE   : std_logic_vector(2 downto 0) := "100"; -- U-type immediate
   
        -- ALU_op codes
    constant ALUOP_ADD    : std_logic_vector(1 downto 0) := "00"; -- Addition (loads/stores)
    constant ALUOP_BRANCH   : std_logic_vector(1 downto 0) := "01"; -- Subtraction (branches)
    constant ALUOP_FUNCT  : std_logic_vector(1 downto 0) := "10"; -- Function field decode (R/I-type)
    
        -- Single bit control signal constants
    constant ENABLE       : std_logic := '1';
    constant DISABLE      : std_logic := '0';
    
    -- Result source constants
    constant RESULT_ALU   : std_logic_vector(2 downto 0) := "000"; -- Use ALU result
    constant RESULT_MEM   : std_logic_vector(2 downto 0) := "001"; -- Use memory data
    constant RESULT_PCplus4   : std_logic_vector(2 downto 0) := "010"; -- Use memory data
    constant RESULT_IMM   : std_logic_vector(2 downto 0) := "011"; -- Use memory data
    constant RESULT_PC_target : std_logic_vector(2 downto 0) := "100"; -- Use target address for JAL or JALR
    -- ALU source constants
    constant ALU_SRC_REG  : std_logic := '0'; -- Use register for ALU src B
    constant ALU_SRC_IMM  : std_logic := '1'; -- Use immediate for ALU src B
begin
    
    process(op)
    begin
        -- Default values (all signals disabled, I-type immediate)
        result_src <= RESULT_ALU;
        branch <= DISABLE;
        Mem_write <= DISABLE;
        ALU_src <= ALU_SRC_REG;
        Imm_src <= IMM_I_TYPE;
        sig_reg_write_en <= DISABLE;
        ALU_op <= ALUOP_ADD;
        jump <= DISABLE;
        
        case op is
            when OP_R_TYPE =>
                -- R-type instructions (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA)
                result_src <= RESULT_ALU;       -- Use ALU result
                branch <= DISABLE;              -- No branch
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_REG;         -- Use register (rs2) for ALU src B
                Imm_src <= IMM_I_TYPE;          -- Don't care for R-type
                sig_reg_write_en <= ENABLE;     -- Write to register
                ALU_op <= ALUOP_FUNCT;          -- Function field decode
                jump <= DISABLE;
                
            when OP_I_TYPE =>
                -- I-type instructions (ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI)
                result_src <= RESULT_ALU;       -- Use ALU result
                branch <= DISABLE;              -- No branch
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_IMM;         -- Use immediate for ALU src B
                Imm_src <= IMM_I_TYPE;          -- I-type immediate
                sig_reg_write_en <= ENABLE;     -- Write to register
                ALU_op <= ALUOP_FUNCT;          -- Function field decode
                jump <= DISABLE;
            when OP_LOAD =>
                -- Load instructions (LW, LH, LB, LHU, LBU)
                result_src <= RESULT_MEM;       -- Use memory data
                branch <= DISABLE;              -- No branch
                Mem_write <= DISABLE;           -- No memory write (reading)
                ALU_src <= ALU_SRC_IMM;         -- Use immediate for address calculation
                Imm_src <= IMM_I_TYPE;          -- I-type immediate
                sig_reg_write_en <= ENABLE;     -- Write to register
                ALU_op <= ALUOP_ADD;            -- Addition for address calculation
                jump <= DISABLE;
            when OP_STORE =>
                -- Store instructions (SW, SH, SB)
                result_src <= RESULT_ALU;       -- Don't care (not writing to register)
                branch <= DISABLE;              -- No branch
                Mem_write <= ENABLE;            -- Enable memory write
                ALU_src <= ALU_SRC_IMM;         -- Use immediate for address calculation
                Imm_src <= IMM_S_TYPE;          -- S-type immediate
                sig_reg_write_en <= DISABLE;    -- Don't write to register
                ALU_op <= ALUOP_ADD;            -- Addition for address calculation
                jump <= DISABLE;
            when OP_BRANCH =>
                -- Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                result_src <= RESULT_ALU;       -- Don't care (not writing to register)
                branch <= ENABLE;               -- Enable branch logic
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_REG;         -- Use registers for comparison
                Imm_src <= IMM_B_TYPE;          -- B-type immediate
                sig_reg_write_en <= DISABLE;    -- Don't write to register
                ALU_op <= ALUOP_BRANCH;            -- Subtraction for branch comparison
                jump <= DISABLE;
            when OP_JAL =>
                -- JAL instruction (Jump and Link)
                result_src <= RESULT_PCplus4;       -- Use ALU result (PC+4)
                branch <= DISABLE;               -- Enable branch/jump logic
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_REG;         -- Don't care
                Imm_src <= IMM_J_TYPE;          -- J-type immediate (treated as U-type)
                sig_reg_write_en <= ENABLE;     -- Write return address to register
                ALU_op <= ALUOP_ADD;            -- Addition for PC calculation
                jump <= ENABLE;
            when OP_JALR =>
                -- JALR instruction (Jump and Link Register)
                result_src <= RESULT_PCplus4;       -- Use ALU result (PC+4)
                branch <= DISABLE;               -- Enable branch/jump logic
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_IMM;         -- Use immediate for target calculation
                Imm_src <= IMM_I_TYPE;          -- I-type immediate
                sig_reg_write_en <= ENABLE;     -- Write return address to register
                ALU_op <= ALUOP_ADD;            -- Addition for address calculation
                jump <= ENABLE;
            when OP_LUI =>
                -- LUI instruction (Load Upper Immediate)
                result_src <= RESULT_IMM;       -- Use ALU result
                branch <= DISABLE;              -- No branch
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_IMM;         -- Use immediate
                Imm_src <= IMM_U_TYPE;          -- U-type immediate
                sig_reg_write_en <= ENABLE;     -- Write to register
                ALU_op <= ALUOP_ADD;           -- Pass through immediate
                jump <= DISABLE;
            when OP_AUIPC =>
                -- AUIPC instruction (Add Upper Immediate to PC)
                result_src <= RESULT_PC_target;       -- Use ALU result
                branch <= DISABLE;              -- No branch
                Mem_write <= DISABLE;           -- No memory write
                ALU_src <= ALU_SRC_IMM;         -- dont care
                Imm_src <= IMM_U_TYPE;          -- U-type immediate
                sig_reg_write_en <= ENABLE;     -- Write to register
                ALU_op <= ALUOP_ADD;            -- dont care
                jump <= DISABLE;
            when others =>
                -- Default case - NOP/Invalid instruction
                result_src <= RESULT_ALU;
                branch <= DISABLE;
                Mem_write <= DISABLE;
                ALU_src <= ALU_SRC_REG;
                Imm_src <= IMM_I_TYPE;
                sig_reg_write_en <= DISABLE;
                ALU_op <= ALUOP_ADD;
                jump <= DISABLE;
        end case;
    end process;
    
end Behavioral;
