----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/04/2025 07:33:58 PM
-- Design Name: 
-- Module Name: data_path - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.memory_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_path is
  port (
    clk          : in std_logic;
    rst          : in std_logic;
    data_XOR_out : out std_logic
  );
end data_path;

architecture Behavioral of data_path is
    constant PC_PLUS_4      : std_logic_vector(1 downto 0) := "00";       -- Next sequential instruction
    constant PC_TARGET      : std_logic_vector(1 downto 0) := "01";       -- Branch target address
    constant PC_ALU      : std_logic_vector(1 downto 0) := "10";       -- Jump target address
  --  fetch signals
  signal pc_next_signal_fetch        : std_logic_vector(31 downto 0):= (others => '0');
  signal pc_signal_fetch             : std_logic_vector(31 downto 0) := (others => '0');
  signal PCplus4_signal_fetch        : std_logic_vector(31 downto 0);
  signal executing_instruction_fetch : std_logic_vector(31 downto 0);
  --  decode signals    
  signal pc_signal_decode             : std_logic_vector(31 downto 0);
  signal executing_instruction_decode : std_logic_vector(31 downto 0);
  signal PCplus4_signal_decode        : std_logic_vector(31 downto 0);
  signal ImmOut_decode                : std_logic_vector(31 downto 0);
  --    register signals
  signal sig_read_reg1         : std_logic_vector(4 downto 0);
  signal sig_read_reg2         : std_logic_vector(4 downto 0);
  signal sig_write_reg_decode  : std_logic_vector(4 downto 0);
  signal sig_read_data1_decode : std_logic_vector(31 downto 0);
  signal sig_read_data2_decode : std_logic_vector(31 downto 0);
  --    control unit
  signal op                      : std_logic_vector(6 downto 0);
  signal funct3                  : std_logic_vector(2 downto 0);
  signal funct7                  : std_logic_vector(6 downto 0);
  signal result_src_decode       : std_logic_vector(2 downto 0);
  signal Mem_write_decode        : std_logic;
  signal ALU_control_decode      : ALU_OP_TYPE_t;
  signal ALU_src_decode          : std_logic;
  signal Imm_src_decode          : std_logic_vector(2 downto 0);
  signal sig_reg_write_en_decode : std_logic;
  signal branch_decode           : std_logic;
  signal jump_decode             : std_logic;
  signal access_width_decode            : MEM_ACCESS_WIDTH_t;
  --  execute signals
  signal pc_signal_execute      : std_logic_vector(31 downto 0);
  signal pc_target_execute      : std_logic_vector(31 downto 0);
  signal PCplus4_signal_execute : std_logic_vector(31 downto 0);
  signal ImmOut_execute         : std_logic_vector(31 downto 0);
  --    register signals
  signal sig_write_reg_execute  : std_logic_vector(4 downto 0);
  signal sig_read_data1_execute : std_logic_vector(31 downto 0);
  signal sig_read_data2_execute : std_logic_vector(31 downto 0);
  --    control unit
  signal result_src_execute       : std_logic_vector(2 downto 0);
  signal Mem_write_execute        : std_logic;
  signal ALU_control_execute      : ALU_OP_TYPE_t;
  signal ALU_src_execute          : std_logic;
  signal sig_reg_write_en_execute : std_logic;
  signal branch_execute           : std_logic;
  signal jump_execute             : std_logic;
  signal PC_source_execute        : std_logic_vector(1 downto 0):=PC_PLUS_4;
  signal PC_IMM_execute           : std_logic_vector(31 downto 0);
  signal ALU_result_execute : std_logic_vector(31 downto 0);
  signal ALU_zero_execute   : std_logic;
  signal srcA               : std_logic_vector(31 downto 0);
  signal srcB               : std_logic_vector(31 downto 0);
  signal access_width_execute           : MEM_ACCESS_WIDTH_t;
  --  
  -- memory signals   
  signal PCplus4_signal_memory      : std_logic_vector(31 downto 0);
  signal sig_data_read_from_memory  : std_logic_vector(31 downto 0);
  signal sig_data_written_to_memory : std_logic_vector(31 downto 0);
  signal ALU_result_memory          : std_logic_vector(31 downto 0);
  signal sig_write_reg_memory       : std_logic_vector(4 downto 0);
  signal ImmOut_memory        : std_logic_vector(31 downto 0);
  signal pc_target_memory    : std_logic_vector(31 downto 0);
  --    control unit
  signal result_src_memory       : std_logic_vector(2 downto 0);
  signal Mem_write_memory        : std_logic;
  signal sig_reg_write_en_memory : std_logic;
  signal access_width_memory            : MEM_ACCESS_WIDTH_t;

  -- writeback signals   
  signal PCplus4_signal_writeback            : std_logic_vector(31 downto 0);
  signal sig_data_read_from_memory_writeback : std_logic_vector(31 downto 0);
  signal ALU_result_writeback                : std_logic_vector(31 downto 0);
  signal sig_write_reg_writeback             : std_logic_vector(4 downto 0);
  signal ImmOut_writeback       : std_logic_vector(31 downto 0);
  signal pc_target_writeback   : std_logic_vector(31 downto 0);
  --    control unit
  signal result_src_writeback       : std_logic_vector(2 downto 0);
  signal sig_reg_write_en_writeback : std_logic;
  signal final_result_writeback     : std_logic_vector(31 downto 0);

begin
  process (final_result_writeback)
    variable temp : std_logic;
  begin
    temp := '0';
    for i in final_result_writeback'range loop
      temp := temp xor final_result_writeback(i);
    end loop;
    data_XOR_out <= temp;
  end process;
  -- fetch
  PCplus4_signal_fetch <= std_logic_vector(unsigned(pc_signal_fetch) + 4);
  -- decode
  op                   <= executing_instruction_decode(6 downto 0);
  funct3               <= executing_instruction_decode(14 downto 12);
  funct7               <= executing_instruction_decode(31 downto 25);
  sig_read_reg1        <= executing_instruction_decode(19 downto 15);
  sig_read_reg2        <= executing_instruction_decode(24 downto 20);
  sig_write_reg_decode <= executing_instruction_decode(11 downto 7);
  -- execute
  srcA              <= sig_read_data1_execute;
  pc_target_execute <= std_logic_vector(unsigned(pc_signal_execute) + unsigned(ImmOut_execute));
  PC_IMM_execute <=ALU_result_execute(31 downto 1) & "0"; -- For JALR instruction

  -- Fetch to Decode Pipeline Register
  fetch_to_decode_reg : process (clk, rst)
  begin
    if rst = '1' then
      pc_signal_decode             <= (others => '0');
      executing_instruction_decode <= (others => '0');
      PCplus4_signal_decode        <= (others => '0');
    elsif rising_edge(clk) then
      pc_signal_decode             <= pc_signal_fetch;
      executing_instruction_decode <= executing_instruction_fetch;
      PCplus4_signal_decode        <= PCplus4_signal_fetch;
    end if;
  end process;

  -- Decode to Execute Pipeline Register
  decode_to_execute_reg : process (clk, rst)
  begin
    if rst = '1' then
      pc_signal_execute        <= (others => '0');
      PCplus4_signal_execute   <= (others => '0');
      ImmOut_execute           <= (others => '0');
      sig_write_reg_execute    <= (others => '0');
      sig_read_data1_execute   <= (others => '0');
      sig_read_data2_execute   <= (others => '0');
      result_src_execute       <= (others => '0');
      Mem_write_execute        <= '0';
      ALU_control_execute      <=ALU_OP_TYPE_ADD;
      ALU_src_execute          <= '0';
      sig_reg_write_en_execute <= '0';
      branch_execute           <= '0';
      jump_execute             <= '0';
    elsif rising_edge(clk) then
      pc_signal_execute        <= pc_signal_decode;
      PCplus4_signal_execute   <= PCplus4_signal_decode;
      ImmOut_execute           <= ImmOut_decode;
      sig_write_reg_execute    <= sig_write_reg_decode;
      sig_read_data1_execute   <= sig_read_data1_decode;
      sig_read_data2_execute   <= sig_read_data2_decode;
      result_src_execute       <= result_src_decode;
      Mem_write_execute        <= Mem_write_decode;
      ALU_control_execute      <= ALU_control_decode;
      ALU_src_execute          <= ALU_src_decode;
      sig_reg_write_en_execute <= sig_reg_write_en_decode;
      branch_execute           <= branch_decode;
      jump_execute             <= jump_decode;
      access_width_execute     <= access_width_decode;
    end if;
  end process;

  -- Execute to Memory Pipeline Register
  execute_to_memory_reg : process (clk, rst)
  begin
    if rst = '1' then
      PCplus4_signal_memory      <= (others => '0');
      ALU_result_memory          <= (others => '0');
      sig_write_reg_memory       <= (others => '0');
      sig_data_written_to_memory <= (others => '0');
      result_src_memory          <= (others => '0');
      Mem_write_memory           <= '0';
      sig_reg_write_en_memory    <= '0';
    elsif rising_edge(clk) then
      PCplus4_signal_memory      <= PCplus4_signal_execute;
      ALU_result_memory          <= ALU_result_execute;
      sig_write_reg_memory       <= sig_write_reg_execute;
      sig_data_written_to_memory <= sig_read_data2_execute; -- Store data comes from read_data2
      result_src_memory          <= result_src_execute;
      Mem_write_memory           <= Mem_write_execute;
      sig_reg_write_en_memory    <= sig_reg_write_en_execute;
      ImmOut_memory              <= ImmOut_execute; 
      pc_target_memory<= pc_target_execute;
      access_width_memory <= access_width_execute;
    end if;
  end process;

  -- Memory to Writeback Pipeline Register
  memory_to_writeback_reg : process (clk, rst)
  begin
    if rst = '1' then
      PCplus4_signal_writeback            <= (others => '0');
      sig_data_read_from_memory_writeback <= (others => '0');
      ALU_result_writeback                <= (others => '0');
      sig_write_reg_writeback             <= (others => '0');
      result_src_writeback                <= (others => '0');
      sig_reg_write_en_writeback          <= '0';
    elsif rising_edge(clk) then
      PCplus4_signal_writeback            <= PCplus4_signal_memory;
      sig_data_read_from_memory_writeback <= sig_data_read_from_memory;
      ALU_result_writeback                <= ALU_result_memory;
      sig_write_reg_writeback             <= sig_write_reg_memory;
      result_src_writeback                <= result_src_memory;
      sig_reg_write_en_writeback          <= sig_reg_write_en_memory;
      ImmOut_writeback                    <= ImmOut_memory; 
      pc_target_writeback<= pc_target_memory;
    end if;
  end process;
  process (ALU_src_execute, PC_source_execute, result_src_writeback,
           sig_read_data2_execute, ImmOut_execute, ALU_result_writeback,
           sig_data_read_from_memory_writeback, PCplus4_signal_writeback,
           pc_target_execute, PCplus4_signal_fetch, ImmOut_writeback,
           pc_target_writeback, PC_IMM_execute)
  begin
    --   ALUsrc mux execute
    if ALU_src_execute = '0' then
      srcB <= sig_read_data2_execute;   
    else
      srcB <= ImmOut_execute;
    end if;

    --   result mux writeback
    if result_src_writeback = "000" then
      final_result_writeback <= ALU_result_writeback;
    elsif result_src_writeback = "001" then
      final_result_writeback <= sig_data_read_from_memory_writeback;
    elsif result_src_writeback = "010" then
      final_result_writeback <= PCplus4_signal_writeback;
    elsif result_src_writeback = "011" then
      final_result_writeback <= ImmOut_writeback; -- Use immediate value for LUI or AU  
    elsif result_src_writeback = "100" then
      final_result_writeback <= pc_target_writeback; -- Use target address for JAL or JALR
    else
      final_result_writeback <= (others => '0');
    end if;

    --        PC source mux fetch
    if PC_source_execute = PC_PLUS_4 then
      pc_next_signal_fetch <= PCplus4_signal_fetch;
    elsif PC_source_execute = PC_TARGET then
      pc_next_signal_fetch <= pc_target_execute;
    elsif PC_source_execute = PC_ALU then
      pc_next_signal_fetch <= PC_IMM_execute; -- Use ALU result for JALR
    else
      pc_next_signal_fetch <= (others => '0'); -- Default case, should not happen
    end if;
  end process;
  brnaching_unit : entity work.branch_unit(Behavioral)
    port map
    (
      opcode          => op,
      branch_type     => funct3,
      alu_result      => ALU_result_execute,
      alu_zero_flag   => ALU_zero_execute,
      next_pc_sel     => PC_source_execute
    );
  program_counter : entity work.program_counter(Behavioral)
    port map
    (
      clk     => clk,
      rst     => rst,
      pc_next => pc_next_signal_fetch,
      pc      => pc_signal_fetch
    );
  instruction_memory : entity work.instruction_memory(Behavioral)
    port map
    (
      addr  => pc_signal_fetch,
      instr => executing_instruction_fetch
    );
  register_file : entity work.register_file(Behavioral)
    port map
    (
      clk          => clk,
      rst          => rst,
      read_reg1    => sig_read_reg1,
      read_reg2    => sig_read_reg2,
      write_reg    => sig_write_reg_writeback,
      write_data   => final_result_writeback,
      reg_write_en => sig_reg_write_en_writeback,
      read_data1   => sig_read_data1_decode,
      read_data2   => sig_read_data2_decode
    );
  alu : entity work.alu(Behavioral)
    port map
    (
      operand_a   => srcA,
      operand_b   => srcB,
      alu_control => ALU_control_execute,
      result      => ALU_result_execute,
      zero        => ALU_zero_execute
    );
  Imm_extension : entity work.Imm_extension(Behavioral)
    port map
    (
      imm_in  => executing_instruction_decode(31 downto 7),
      imm_src => Imm_src_decode,
      imm_out => ImmOut_decode
    );
  data_memory : entity work.data_memory(Behavioral)
    port map
    (
      clk      => clk,
      addr     => ALU_result_memory,
      data_in  => sig_data_written_to_memory,
      mem_write_enable       => Mem_write_memory,
      access_width => access_width_memory,
      data_out => sig_data_read_from_memory
    );
  Control_unit : entity work.Control_unit(Behavioral)
    port map
    (
      op               => op,
      funct3           => funct3,
      funct7           => funct7,
      result_src       => result_src_decode,
      branch           => branch_decode,
      jump             => jump_decode,
      Mem_write        => Mem_write_decode,
      ALU_control      => ALU_control_decode,
      ALU_src          => ALU_src_decode,
      Imm_src          => Imm_src_decode,
      sig_reg_write_en => sig_reg_write_en_decode,
      access_width     => access_width_decode
    );

end Behavioral;
