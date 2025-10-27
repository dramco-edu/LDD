----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: Timer_1s - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Timer 1 with 1 second period
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

entity Timer_1s is
    generic(
         C_F_CLK : natural := 500000 -- system clock frequency
    );
    port(
          clk : in  std_logic;
        reset : in  std_logic;
          run : in  std_logic;
        pulse : out std_logic
    );
end Timer_1s;

architecture Behavioral of Timer_1s is

    constant C_MAX_VAL : integer := C_F_CLK - 1;
    
    signal pulse_i : std_logic := '0';
    
begin

    CNT_PROC: process(clk, reset) is
        variable cntr_i : integer range 0 to C_MAX_VAL := 0;
    begin
        if reset='1' then
            cntr_i := 0;
            pulse_i <= '0';
        elsif rising_edge(clk) then
            if run='1' then
                if cntr_i=C_MAX_VAL then
                    cntr_i := 0;
                    pulse_i <= '1';
                else
                    cntr_i := cntr_i + 1;
                    pulse_i <= '0';
                end if;
            end if;
        end if;
    end process CNT_PROC;

    pulse <= pulse_i;

end Behavioral;
