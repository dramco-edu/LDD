----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: updown_counter - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  n-bit up and down counter with asynchronous reset and overflow/underflow
--  indication. The count value is not further incremented/decremented when an
--  overflow/underflow occurs. 
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity updown_counter is
    generic(
        C_NR_BITS : integer := 4
    );
    port(
              clk : in  std_logic;
            reset : in  std_logic; -- async. reset
               up : in  std_logic; -- synch. count up
             down : in  std_logic; -- synch. count donw
        underflow : out std_logic; -- '1' on underflow
         overflow : out std_logic; -- '1' on overflow
            count : out std_logic_vector(C_NR_BITS-1 downto 0) -- count value
    );
end updown_counter;

architecture Behavioral of updown_counter is
    -- TODO: (optionally) declare signals
begin

    -- TODO: write VHDL process

end Behavioral;
