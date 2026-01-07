----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Nizar K.
-- 
-- Create Date: 10/01/2025 07:44:47 PM
-- Design Name: 
-- Module Name: i2c_master_controller - Behavioral
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
use work.work_package.all;

--use IEEE.NUMERIC_STD.ALL;


entity i2c_master_controller is
    Port ( SCL : in STD_LOGIC;
           SDA : inout STD_LOGIC;
           Start_sending : in STD_LOGIC;
           Byte_to_write : in STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0);
           lastByte : in STD_LOGIC;

           byteCounter : out integer:= 0;
           currentState : out state_type;
           Byte_to_read : out STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0);
           readingData : out STD_LOGIC
           );
end i2c_master_controller;

architecture Behavioral of i2c_master_controller is

    signal state : state_type := IDLE;
    signal bit_cnt : integer range 0 to I2C_Adress_size := 0;
    signal data_reg_Signal : STD_LOGIC_VECTOR(I2C_Data_size-1 downto 0);

begin
currentState <= state;
process(SCL)
begin
    if rising_edge(SCL) then
        case state is
            when IDLE =>
                if Start_sending = '1' then
                    state <= START;
                    -- Addr_Byte_signal <= Addr_Byte;
                end if;

            when START =>
                state <= WRITING_BYTE;
                bit_cnt <= I2C_Data_size;
                SDA <= '0'; 

            when WRITING_BYTE =>
                if bit_cnt >= 0 then
                    SDA <= Byte_to_write(bit_cnt);
                    if bit_cnt = 0 then
                        state <= SLAVE_ACK;
                        byteCounter <= byteCounter + 1;
                    else
                        bit_cnt <= bit_cnt - 1;
                    end if;
                end if;

            when SLAVE_ACK =>
                if SDA = '0' then
                    bit_cnt <= I2C_Data_size - 1;
                    if lastByte = '0' then
                        state <= WRITING_BYTE;
                    else
                        state <= READING_BYTE;
                        readingData <= '1';
                        byteCounter<=0;
                    end if;
                else
                    state <= STOP;
                end if; 
            when MASTER_ACK =>
                SDA <= '0';
                if lastByte = '0' then
                    bit_cnt <= I2C_Data_size - 1;
                    state <= READING_BYTE;
                    byteCounter <= byteCounter + 1;
                else 
                    state <= STOP;
                end if;    
            when READING_BYTE =>
                if bit_cnt >= 0 then
                    data_reg_Signal(bit_cnt) <= SDA;
                    if bit_cnt = 0 then
                        Byte_to_read <= data_reg_Signal;
                        state <= MASTER_ACK;
                        
                    else
                        bit_cnt <= bit_cnt - 1;
                        state <= READING_BYTE;
                    end if;
                end if;

            when STOP =>
                SDA <= 'Z'; -- Release SDA
                state <= IDLE;
            when others =>
                state <= IDLE;
        end case;
    end if;
end process;

end Behavioral;
