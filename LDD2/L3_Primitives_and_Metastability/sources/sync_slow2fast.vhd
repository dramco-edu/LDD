----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: sync_slow2fast - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Pass pulse (1 clock period) from slow clock domain to fast clock domain
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

entity sync_slow2fast is
    port(
           reset : in  std_logic;
        clk_fast : in  std_logic;
         data_in : in  std_logic;
        data_out : out std_logic
    );
end sync_slow2fast;

architecture Behavioral of sync_slow2fast is

    
begin
    -- TODO: replace this line by synchronizing circuit
    data_out <= data_in;

end Behavioral;
