library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.memory_package.all;
entity Hazard_control_unit is
    Port (
        -- Inputs
        rs1_decode       : in  std_logic_vector(4 downto 0); -- Source register 1 in ID stage
        rs2_decode        : in  std_logic_vector(4 downto 0); -- Source register 2 in ID stage
        rs1_execute     : in  std_logic_vector(4 downto 0); -- Source register 1 in EX stage
        rs2_execute      : in  std_logic_vector(4 downto 0);
        rd_execute       : in  std_logic_vector(4 downto 0); -- Destination register in EX stage
        sig_reg_write_en_execute : in  std_logic; -- Write enable for destination register in EX stage
        result_src_execute : in  std_logic_vector(2 downto 0); -- Source of the result in EX stage
        next_pc_sel    : in  std_logic_vector(1 downto 0); -- Next PC selection signal
        rd_memory        : in  std_logic_vector(4 downto 0); -- Destination register in MEM stage
        sig_reg_write_en_memory : in  std_logic; -- Write enable for destination register in MEM stage
        result_src_memory : in  std_logic_vector(2 downto 0); --
        rd_writeback     : in  std_logic_vector(4 downto 0); -- Destination register in WB stage
        sig_reg_write_en_writeback : in  std_logic; -- Write enable for destination register in WB stage
        -- Outputs
        reg_decode_src1  : out REG_DECODE_SOURCE_t; -- Register decode source for src1
        reg_decode_src2  : out REG_DECODE_SOURCE_t; -- Register decode source for src2
        sel_alu_src1  : out ALU_OP_SRC_t; -- Select signal for ALU input 1 mux
        sel_alu_src2  : out ALU_OP_SRC_t; -- Select signal for ALU input 2 mux
        stall_f_pc         : out std_logic;                    -- Stall signal for pipeline
        flush_fetch   : out std_logic;                    -- Flush signal for fetch stage
        flush_decode  : out std_logic                     -- Flush signal for decode stage
    );
end Hazard_control_unit;
architecture Behavioral of Hazard_control_unit is
        signal op_sel_signal : ALU_OP_SRC_t;
        signal stall_load    : std_logic;
        signal stall_jump    : std_logic;
    begin
        reg_decode_src1 <= REG_DECODE_SOURCE_WRITEBACK when sig_reg_write_en_writeback = '1' 
        and rd_writeback = rs1_decode and rd_writeback /= "00000" else REG_DECODE_SOURCE_REGISTER;

        reg_decode_src2 <= REG_DECODE_SOURCE_WRITEBACK when sig_reg_write_en_writeback = '1'
         and rd_writeback = rs2_decode and rd_writeback /= "00000" else
             REG_DECODE_SOURCE_REGISTER; 

        with result_src_memory select
            op_sel_signal <= 
                ALU_OP_SRC_IMM when "011" ,
                ALU_OP_SRC_PC_4 when "010" ,
                ALU_OP_SRC_PC_IMM when "100" ,
                ALU_OP_SRC_ALU_RES when "000" ,
                ALU_OP_SRC_REG when others;
        -- ALU input 1 selection

        sel_alu_src1 <= op_sel_signal when sig_reg_write_en_memory = '1' and rd_memory = rs1_execute and rd_memory /= "00000" else
                        ALU_OP_SRC_RD_DATA when sig_reg_write_en_writeback = '1' and rd_writeback = rs1_execute and rd_writeback /= "00000" else
                        ALU_OP_SRC_REG ;
                        
        -- ALU input 2 selection   
        sel_alu_src2 <= op_sel_signal when sig_reg_write_en_memory = '1' and rd_memory = rs2_execute and rd_memory /= "00000" else
                        ALU_OP_SRC_RD_DATA when sig_reg_write_en_writeback = '1' and rd_writeback = rs2_execute and rd_writeback /= "00000" else
                        ALU_OP_SRC_REG ;
        
        -- Stall signal generation
        stall_load <= '1' when  result_src_execute="001" and sig_reg_write_en_execute='1' and rd_execute /= "00000" 
        and (rd_execute = rs1_decode or rd_execute = rs2_decode) else '0';
        stall_jump <= '1' when next_pc_sel = PC_ALU or next_pc_sel = PC_TARGET else '0';

        stall_f_pc <= stall_load ;
        -- Flush signals
        flush_fetch <= not stall_load and stall_jump;
        flush_decode <=  stall_load or stall_jump;
end Behavioral;