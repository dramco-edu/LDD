----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: lr_shift_par_load - Behavioral
-- Course Name: Lab Digital Design
--
--
-- Description: 
--  Debounce a digital input (e.g. a button).
--
-- Additional Comments:
--   have a look at this link:
--   https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4980758
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is
    generic(
           C_F_CLK : natural := 50000000; -- system clock frequency
        C_DELAY_MS : natural := 20        -- debounce period in ms
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

    -- TODO: complete architecture to implement the design mentioned in the header
    -- The counter can be an integer counter. Use the constant delay_cycles to limit the counter.

end Behavioral;
