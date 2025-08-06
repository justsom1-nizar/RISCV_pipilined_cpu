
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package memory_package is
    type MEM_ACCESS_WIDTH_t is (MEM_ACCESS_WIDTH_8, MEM_ACCESS_WIDTH_16, MEM_ACCESS_WIDTH_32,
                                MEM_ACCESS_WIDTH_8_UNSIGNED, MEM_ACCESS_WIDTH_16_UNSIGNED);
    type ALU_OP_TYPE_t is (ALU_OP_TYPE_ADD, ALU_OP_TYPE_SUB, ALU_OP_TYPE_SLT, ALU_OP_TYPE_SLTU,
                            ALU_OP_TYPE_AND, ALU_OP_TYPE_OR, ALU_OP_TYPE_XOR, ALU_OP_TYPE_SLL, ALU_OP_TYPE_SRL, ALU_OP_TYPE_SRA);
    type MEMORY_ACCESS_TYPE_t  is (MEMORY_ACCESS_TYPE_READ, MEMORY_ACCESS_TYPE_WRITE);

    type REG_DECODE_SOURCE_t is(REG_DECODE_SOURCE_REGISTER, REG_DECODE_SOURCE_WRITEBACK);
    constant DATA_MEMORY_BASE_ADDRESS : integer := 16#00FC8000#;
    type ALU_OP_SRC_t is (ALU_OP_SRC_IMM, ALU_OP_SRC_ALU_RES, ALU_OP_SRC_REG, ALU_OP_SRC_PC_IMM, ALU_OP_SRC_PC_4, ALU_OP_SRC_RD_DATA);
    constant PC_PLUS_4      : std_logic_vector(1 downto 0) := "00";       -- Next sequential instruction
    constant PC_TARGET      : std_logic_vector(1 downto 0) := "01";       -- Branch target address
    constant PC_ALU      : std_logic_vector(1 downto 0) := "10";       -- Jump target address

    
    
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

    -- Branch Type Constants (funct3 field)
    constant BRANCH_BEQ     : std_logic_vector(2 downto 0) := "000";      -- Branch if Equal
    constant BRANCH_BNE     : std_logic_vector(2 downto 0) := "001";      -- Branch if Not Equal
    constant BRANCH_BLT     : std_logic_vector(2 downto 0) := "100";      -- Branch if Less Than
    constant BRANCH_BGE     : std_logic_vector(2 downto 0) := "101";      -- Branch if Greater or Equal
    constant BRANCH_BLTU    : std_logic_vector(2 downto 0) := "110";      -- Branch if Less Than Unsigned
    constant BRANCH_BGEU    : std_logic_vector(2 downto 0) := "111";      -- Branch if Greater or Equal Unsigned
    
    -- Memory access width constants (funct3 field)
    constant BYTE : std_logic_vector(2 downto 0) := "000"; -- Byte access
    constant HALFWORD : std_logic_vector(2 downto 0) := "001"; -- Halfword access
    constant WORD : std_logic_vector(2 downto 0) := "010"; -- Word access
    constant UNSIGNED_BYTE : std_logic_vector(2 downto 0) := "100"; -- Unsigned byte access
    constant UNSIGNED_HALFWORD : std_logic_vector(2 downto 0) := "101"; -- Unsigned halfword access
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------ Instruction memory -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
    constant RESET_HANDLER_ADDRESS          : integer := 16#00000000#;
    constant INSTRUCTION_MEMORY_SIZE_BYTES  : integer := 8;     -- in bytes, must be a multiple of 4 (32-bits instructions) and must contain at least 2 instructions
    constant INSTRUCTION_MEMORY_SIZE_WORDS  : integer := INSTRUCTION_MEMORY_SIZE_BYTES/4;     -- in 32-bit words

    type INSTRUCTION_MEMORY_ARRAY_t is array(0 to INSTRUCTION_MEMORY_SIZE_WORDS-1) of std_logic_vector(31 downto 0);
    
    -- put the program instruction content here, its size must fit INSTRUCTION_MEMORY_SIZE
    constant INSTRUCTION_MEMORY_CONTENT : INSTRUCTION_MEMORY_ARRAY_t := (
    -- Initialize registers
    x"00001317", --  auipc x6, 0x1          ; skipped
    x"12330393" -- addi x7, x6, 0x123
);
        
        
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------------ Data ROM -----------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------  
    constant DATA_ROM_MEMORY_SIZE_BYTES     : integer := 8;     -- in bytes, must be a multiple of 4 and must be >= 8 (fill with 0s if needed)
    constant DATA_ROM_MEMORY_SIZE_WORDS     : integer := DATA_ROM_MEMORY_SIZE_BYTES/4;     -- in 32-bit words

    -- Memory organized as words, but byte addressable
    type DATA_ROM_MEMORY_ARRAY_t is array (0 to DATA_ROM_MEMORY_SIZE_WORDS-1, 3 downto 0) of std_logic_vector(7 downto 0);
    
    -- put the constant data content here, its size must fit DATA_ROM_MEMORY_SIZE_BYTES
    constant DATA_ROM_MEMORY_CONTENT : DATA_ROM_MEMORY_ARRAY_t := (
            (x"15", x"20", x"F5", x"F7"),
            (x"00", x"00", x"00", x"0b")
        );


---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------------ Data RAM ----------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
    constant DATA_RAM_BASE_ADDRESS        : integer := 16#00FC8100#;
    constant DATA_RAM_MEMORY_SIZE_BYTES   : integer := 512;     -- in bytes, must be a multiple of 4
    constant DATA_RAM_MEMORY_SIZE_WORDS   : integer := DATA_RAM_MEMORY_SIZE_BYTES/4;     -- in 32-bit words
    
    -- Memory organized as words, but byte addressable
    type DATA_RAM_MEMORY_ARRAY_t is array (0 to DATA_RAM_MEMORY_SIZE_WORDS-1, 3 downto 0) of std_logic_vector(7 downto 0);


end package memory_package;