----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nizar K.
-- 
-- Create Date: 12/24/2025 07:44:47 PM
-- Design Name: 
-- Module Name: i2c_memory_interface - Behavioral
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
use work.memory_package.all;
--use IEEE.NUMERIC_STD.ALL;

entity i2c_memory_interface is
    Port ( RegisterAddr : in STD_LOGIC_VECTOR (31 downto 0);
            Clk : in STD_LOGIC;
            Reset : in STD_LOGIC;
            DataIn : in STD_LOGIC_VECTOR (31 downto 0);
            WriteEnable : in STD_LOGIC;

            DataOut : out STD_LOGIC_VECTOR (31 downto 0);
            SDA : inout STD_LOGIC
            -- SCL : in STD_LOGIC

        );
end i2c_memory_interface;
architecture Rtl of i2c_memory_interface is
    --Registers
    signal  REG_I2C_ADDRESS      : STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0) := x"00";
    signal  REG_I2C_NUMB_BYTES_TO_WRITE
                                    : STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal REG_I2C_NUMB_BYTES_TO_READ
                                    : STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal  REG_I2C_CONTROL         : STD_LOGIC_VECTOR (7 downto 0) := x"00";

    signal index : integer := 0; 
    signal I2C_MEMORY_WRITTEN_ARRAY : I2C_MEMORY_ARRAY_t := (others => (others => '0'));
    signal I2C_MEMORY_RED_ARRAY : I2C_MEMORY_ARRAY_t := (others => (others => '0'));
    --i2c master controller signals
    signal sig_byte_counter : integer:=0;
    signal sig_start_sending : STD_LOGIC := '0';
    signal sig_byte_to_write : STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0) := (others => '0');
    signal sig_lastByte : STD_LOGIC := '0';
    signal sig_currentState : state_type;
    signal sig_byte_to_read : STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0) := (others => '0');
    signal sig_writing_addr_state : WRITING_ADDR_TYPE_t := REG_I2C;
    signal sig_reading_data : STD_LOGIC := '0';
    begin

        i2c_master_controller_inst: entity work.i2c_master_controller
         port map(
            SCL => SCL,
            SDA => SDA,
            Start_sending => sig_start_sending,
            Byte_to_write => sig_byte_to_write,
            lastByte => sig_lastByte,

            byteCounter => sig_byte_counter,
            currentState => sig_currentState,
            Byte_to_read => sig_byte_to_read,
            readingData => sig_reading_data
        );
        --Register and controller logic
        sig_start_sending<= REG_I2C_CONTROL and sig_currentState = IDLE else '0';

        sig_byte_to_write<= REG_I2C_ADDRESS when sig_byte_counter=0 else
                            I2C_MEMORY_WRITTEN_ARRAY(sig_byte_counter-1)
                            when sig_byte_counter>0 and sig_byte_counter<=to_integer(unsigned(REG_I2C_NUMB_BYTES_TO_WRITE)) else
                            (others => '0');
        I2C_MEMORY_RED_ARRAY(sig_byte_counter)<=sig_byte_to_read when sig_reading_data='1';
        sig_lastByte<= '1' when (sig_reading_data='0' and sig_byte_counter=to_integer(unsigned(REG_I2C_NUMB_BYTES_TO_WRITE))) or
                             (sig_reading_data='1' and sig_byte_counter=to_integer(unsigned(REG_I2C_NUMB_BYTES_TO_READ)))
                            else '0';

        --Addressing logic
        sig_writing_addr_state<=REG_I2C when RegisterAddr=REG_I2C_ADDR else
                                REG_I2C_WRITE_DATA when RegisterAddr=REG_I2C_WRITE_DATA_ADDR else
                                REG_I2C_READ_DATA when RegisterAddr=REG_I2C_READ_DATA_ADDR else
                                REG_I2C;
        
        -- Asynchronous Register Read Command
        index<=to_integer(unsigned(RegisterAddr(3 downto 2)));
        DataOut(7 downto 0)<=I2C_MEMORY_RED_ARRAY(index) when sig_writing_addr_state=REG_I2C_READ_DATA else
            (others => '0');
        DataOut(15 downto 8)<=I2C_MEMORY_RED_ARRAY(index+1) when sig_writing_addr_state=REG_I2C_READ_DATA else
            (others => '0');
        DataOut(23 downto 16)<=I2C_MEMORY_RED_ARRAY(index+2) when sig_writing_addr_state=REG_I2C_READ_DATA else
            (others => '0');
        DataOut(31 downto 24)<=I2C_MEMORY_RED_ARRAY(index+3) when sig_writing_addr_state=REG_I2C_READ_DATA else
            (others => '0');

        --Register Write Process
        process(Clk, Reset)
        begin
            if Reset = '1' then
                REG_I2C_ADDRESS <= (others => '0');
                REG_I2C_NUMB_BYTES_TO_WRITE <= (others => '0');
                REG_I2C_NUMB_BYTES_TO_READ <= (others => '0');
                REG_I2C_CONTROL <= (others => '0');
                I2C_MEMORY_WRITTEN_ARRAY <= (others => (others => '0'));
            elsif rising_edge(Clk) then
                if WriteEnable = '1' then
                    case sig_writing_addr_state is
                        when REG_I2C =>
                            REG_I2C_ADDRESS <= DataIn(7 downto 0);
                            REG_I2C_NUMB_BYTES_TO_WRITE<= DataIn(15 downto 8);
                            REG_I2C_NUMB_BYTES_TO_READ<= DataIn(23 downto 16);
                            REG_I2C_CONTROL <= DataIn(31 downto 24);
                        when REG_I2C_WRITE_DATA =>
                            I2C_MEMORY_WRITTEN_ARRAY(index) <= DataIn(7 downto 0);
                            I2C_MEMORY_WRITTEN_ARRAY(index+1) <= DataIn(15 downto 8);
                            I2C_MEMORY_WRITTEN_ARRAY(index+2) <= DataIn(23 downto 16);
                            I2C_MEMORY_WRITTEN_ARRAY(index+3) <= DataIn(31 downto 24);
                        when others =>
                            null;
                    end case;
                end if;
                
            end if;
    end process;

    end Rtl;