----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: pulser - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  When the input signal goes high, the output signal will also go high, but only
--  for 1 clock cycle.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulser is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
            clk : in  STD_LOGIC;
         sig_in : in  STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        sig_out : out STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0)
    );
end pulser;

architecture Behavioral of pulser is
    signal sig_in_del_i : std_logic_vector(C_DATA_WIDTH-1 downto 0);
begin
    DELAY_1CYCLE: process(clk) is
    begin
        if rising_edge(clk) then
            sig_in_del_i <= sig_in;
        end if;
    end process DELAY_1CYCLE;

    sig_out <= sig_in and (not sig_in_del_i);
end Behavioral;
