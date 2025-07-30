
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package memory_package is
    type MEM_ACCESS_WIDTH_t is (MEM_ACCESS_WIDTH_8, MEM_ACCESS_WIDTH_16, MEM_ACCESS_WIDTH_32,
                                MEM_ACCESS_WIDTH_8_UNSIGNED, MEM_ACCESS_WIDTH_16_UNSIGNED);
    type ALU_OP_TYPE_t is (ALU_OP_TYPE_ADD, ALU_OP_TYPE_SUB, ALU_OP_TYPE_SLT, ALU_OP_TYPE_SLTU,
                            ALU_OP_TYPE_AND, ALU_OP_TYPE_OR, ALU_OP_TYPE_XOR, ALU_OP_TYPE_SLL, ALU_OP_TYPE_SRL, ALU_OP_TYPE_SRA);
    type MEMORY_ACCESS_TYPE_t  is (MEMORY_ACCESS_TYPE_READ, MEMORY_ACCESS_TYPE_WRITE);

    constant DATA_MEMORY_BASE_ADDRESS : integer := 16#00FC8000#;
    
    
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------ Instruction memory -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
    constant RESET_HANDLER_ADDRESS          : integer := 16#00000000#;
    constant INSTRUCTION_MEMORY_SIZE_BYTES  : integer := 184;     -- in bytes, must be a multiple of 4 (32-bits instructions) and must contain at least 2 instructions
    constant INSTRUCTION_MEMORY_SIZE_WORDS  : integer := INSTRUCTION_MEMORY_SIZE_BYTES/4;     -- in 32-bit words

    type INSTRUCTION_MEMORY_ARRAY_t is array(0 to INSTRUCTION_MEMORY_SIZE_WORDS-1) of std_logic_vector(31 downto 0);
    
    -- put the program instruction content here, its size must fit INSTRUCTION_MEMORY_SIZE
    constant INSTRUCTION_MEMORY_CONTENT : INSTRUCTION_MEMORY_ARRAY_t := (
            x"00c00093", --addi x1, x0, 12
            x"01800113", --addi x2, x0, 24
            x"01800313", --addi x6, x0, 24
            x"01800313", --addi x6, x0, 24
            x"01800313", --addi x6, x0, 24
            x"001101b3", --add x3, x2, x1
            x"01800313", --addi x6, x0, 24
            x"01800313", --addi x6, x0, 24
            x"01800313", --addi x6, x0, 24
            x"01800313", --addi x6, x0, 24
            x"00fc8137",  --lui x2, 0x00FC8
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"10010193",  --addi x3, x2, 0x100
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"00012383",  --lw x7, 0(x2)
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"00011403",  --lh x8, 0(x2)
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"00010483",  --lb x9, 0(x2)
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"0071a023",  --sw x7, 0(x3)
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"00719223",  --sh x7, 4(x3)
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy
            x"01800313", --dummy 
            x"00718423"   --sb x7, 8(x3)

            

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
            (x"15", x"20", x"F5", x"07"),
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