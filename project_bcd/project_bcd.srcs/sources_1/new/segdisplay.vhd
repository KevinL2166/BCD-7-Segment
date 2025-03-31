----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2025 11:21:48 PM
-- Design Name: 
-- Module Name: segdisplay - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity segdisplay_multi is
    Port (
        -- 16 switches (4 groups of 4)
        sw0_3  : IN STD_LOGIC_VECTOR(3 downto 0);  -- First digit (switches 0-3)
        sw4_7  : IN STD_LOGIC_VECTOR(3 downto 0);  -- Second digit (switches 4-7)
        sw8_11 : IN STD_LOGIC_VECTOR(3 downto 0);  -- Third digit (switches 8-11)
        sw12_15: IN STD_LOGIC_VECTOR(3 downto 0);  -- Fourth digit (switches 12-15)
        
        -- Common 7-segment outputs
        seg : OUT STD_LOGIC_VECTOR(6 downto 0);  -- a to g
        
        -- Digit select (common cathode/anode control)
        dig_sel : OUT STD_LOGIC_VECTOR(3 downto 0);
        
        -- Clock for scanning
        clk : IN STD_LOGIC
    );
end segdisplay_multi;

architecture Behavioral of segdisplay_multi is
    signal counter : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal current_digit : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal digit_data : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- Clock divider for scanning
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = 0 then
                current_digit <= current_digit + 1;
            end if;
        end if;
    end process;

    -- Digit multiplexer
    with current_digit select
        digit_data <= sw0_3   when "00",
                      sw4_7   when "01",
                      sw8_11  when "10",
                      sw12_15 when others;

    -- Digit select decoder
    with current_digit select
        dig_sel <= "1110" when "00",  -- Activate first digit
                   "1101" when "01",  -- Activate second digit
                   "1011" when "10",  -- Activate third digit
                   "0111" when others; -- Activate fourth digit

    -- Your original 7-segment decoder (modified for vector output)
    seg(0) <= NOT (digit_data(3) OR digit_data(1) OR (digit_data(2) XNOR digit_data(0)));  -- a
    seg(1) <= NOT ((NOT digit_data(2)) OR NOT (digit_data(1) XOR digit_data(0)));         -- b
    seg(2) <= NOT (digit_data(2) OR (NOT digit_data(1)) OR digit_data(0));                 -- c
    seg(3) <= NOT ((digit_data(1) AND NOT digit_data(0)) OR 
                  (NOT digit_data(2) AND NOT digit_data(0)) OR 
                  (NOT digit_data(2) AND digit_data(1)) OR 
                  (digit_data(2) AND NOT digit_data(1) AND digit_data(0)));               -- d
    seg(4) <= NOT ((digit_data(1) AND NOT digit_data(0)) OR (NOT digit_data(2) AND NOT digit_data(0)));                            -- e
    seg(5) <= NOT (digit_data(3) OR (digit_data(2) AND NOT digit_data(1)) OR 
                  (digit_data(2) AND NOT digit_data(0)) OR 
                  (NOT digit_data(1) AND NOT digit_data(0)));                            -- f
    seg(6) <= NOT (digit_data(3) OR (digit_data(2) XOR digit_data(1)) OR 
                  (digit_data(1) AND NOT digit_data(0)));                                 -- g
end Behavioral;
