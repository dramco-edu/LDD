----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: sync_fast2slow - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Pass pulse (1 clock period) from fast clock domain to slow clock domain
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sync_fast2slow is
    port(
           reset : in  std_logic;
        clk_fast : in  std_logic;
        clk_slow : in  std_logic; -- slow clk
         data_in : in  std_logic;
        data_out : out std_logic
    );
end sync_fast2slow;

architecture Behavioral of sync_fast2slow is
      

begin
    -- TODO: replace this line by synchronizing circuit
    data_out <= data_in;

end Behavioral;
