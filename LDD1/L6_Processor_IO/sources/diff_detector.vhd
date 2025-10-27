----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: diff_detector - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor diff_detector
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

entity diff_detector is
    Generic(
        C_DATA_WIDTH : natural := 8
    );
    Port ( 
        clk : in std_logic;
        reset: in std_logic;     
        
        a : in std_logic_vector (C_DATA_WIDTH-1 downto 0);
        b : in std_logic_vector (C_DATA_WIDTH-1 downto 0);
        diff : out std_logic
    );
end diff_detector;

architecture Behavioral of diff_detector is
    signal diff_i : std_logic;
    
begin
 SW_CHANGE_DETECT_PROC : process(clk, reset)
   begin
        if reset = '1' then
            diff_i <= '0';
        elsif  rising_edge(clk) then
           if (a xor b) /= (a'range => '0') then
                diff_i <= '1';
           else
                diff_i <= '0';
           end if;
        end if;
   end process SW_CHANGE_DETECT_PROC;
    
   --build output
   diff <= diff_i;
end Behavioral;
