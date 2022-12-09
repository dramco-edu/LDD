----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: pulser - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Debounce a digital input (e.g. a button).
--
-- Additional Comments:
--   this file is a modification of debounce.vhd found on:
--   https://www.eewiki.net/display/LOGIC/Debounce+Logic+Circuit+(with+VHDL+example)
--   new link: https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4980758
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is
    generic(
           C_F_CLK : natural := 50000000; -- system clock frequency
        C_DELAY_MS : natural := 20        -- debounce period
    );
    port(
               clk : in  std_logic;       -- input clock
            button : in  std_logic;       -- input signal to be debounced
            result : out std_logic        -- debounced signal
    );
end entity;

architecture Behavioral of debounce is
    -- compute how many clock cycles we need for the debouncing delay
    constant delay_cycles : integer := integer(real(C_F_CLK) * (real(C_DELAY_MS) / 1000.0))-2;  --takes cycles used 
    
    signal flipflops      : std_logic_vector(1 downto 0) := (others=>'0');   -- 2 input flip flops
    signal reset_counter  : std_logic := '0';                    -- synchronous reset to zero
    signal debug          : integer; 

begin

    reset_counter <= flipflops(0) xor flipflops(1);   -- reset counter when two flip flops differ
    
    DEBOUNCE_PROC : process(clk)
        variable counter : integer range 0 to delay_cycles := 0;
        variable result_temp : std_logic := '0'; -- for simulation purposes
    begin
        if rising_edge(clk) then
            flipflops(0) <= button;
            flipflops(1) <= flipflops(0);
            if(reset_counter = '1') then       --reset counter because input is changing
                counter := 0;
            elsif(counter = delay_cycles) then --stable input time is met
                result_temp := flipflops(1);
                counter := counter;
            else                               --stable input time is not yet met
                counter := counter + 1;
            end if;
        end if;
        debug <= counter;
        result <= result_temp;
    end process DEBOUNCE_PROC;
end Behavioral;
