---------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: ring_oscillator - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  ring oscillator design
--  frequency can be tuned by changing the number of "TAPS"
--  increasing "TAPS" will reduce the output frequency
--  TODO: implement ring oscillator as in: https://www.researchgate.net/figure/Architecture-of-an-FPGA-ring-oscillator_fig1_265851044
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ring_oscillator is
    port(
         nEnable : in  std_logic;   -- oscillator enable (active 'low')
         clk_out : out std_logic    -- oscillator output
    );
end ring_oscillator;

architecture Behavioral of ring_oscillator is
    constant TAPS : natural := 35;
    
    -- add signals when needed
begin

    assert TAPS > 4 report "TAPS needs to be larger than 4." severity ERROR;
    
    --                 _____
    --  ring(i-1) ────|     \
    --                | AND |─── ring(i)
    --    nEnable ─>o─|_____/   
    --
    RING_GEN : for i in 1 to TAPS-1 generate
    begin
        -- TODO: force gate instance (by using FPGA primitive)
    end generate;
    
    --                 _____
    --  ring(END) ─>o─|     \
    --                | AND |─── ring(i)
    --    nEnable ─>o─|_____/   
    --

    -- TODO: force gate instance (by using FPGA primitive)
    
    -- TODO: don't forget the D-flipflop

end Behavioral;
