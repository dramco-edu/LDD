----------------------------------------------------------------------------------
-- Institution: KU Leuven
--  Engineer: Geoffrey Ottoy
-- 
-- Module Name: bcd_ctr - Behavioral
-- Course Name: Lab Digital Design
--
--
-- Description: 
--  BCD counter with 'count enable' and overflow indication
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_ctr is
    port(
          clk : in  std_logic;
        reset : in  std_logic;
          cnt : in  std_logic;
          ovf : out std_logic;
          bcd : out std_logic_vector(3 downto 0)
    );
end bcd_ctr;

architecture Behavioral of bcd_ctr is

    signal cntr     : std_logic_vector(3 downto 0) := (others=>'0');
    signal overflow : std_logic := '0';

begin

    CNT_PROC: process (clk, reset) is
    begin
        if reset = '1' then
            cntr <= (others=>'0');
            overflow <= '0';
        elsif rising_edge(clk) then
            overflow <= '0'; -- default value
            if cnt = '1' then
                if cntr = "1001" then
                    cntr <= (others=>'0');
                    overflow <= '1';
                else
                    cntr <= cntr + '1';
                end if;
            end if;
        end if;
    end process CNT_PROC;

    bcd <= cntr;
    ovf <= overflow;

end Behavioral;
