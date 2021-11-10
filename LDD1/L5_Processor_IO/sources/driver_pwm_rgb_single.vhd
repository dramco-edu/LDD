----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: driver_pwm_rgb_single - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  PWM RGB LED driver
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

entity driver_pwm_rgb_single is
    generic(
          C_F_CLK : natural := 50000000;  -- system clock frequency
        C_F_COUNT : natural := 250000     -- count pulse frequency
    );
    port(
          clk : in  std_logic;                     -- system clock input
        reset : in  std_logic;                     -- async. system reset
         regR : in  std_logic_vector(7 downto 0);  -- PWM red value
         regG : in  std_logic_vector(7 downto 0);  -- PWM green value
         regB : in  std_logic_vector(7 downto 0);  -- PWM blue value
          rgb : out std_logic_vector(2 downto 0)   -- rgb output
    );
end driver_pwm_rgb_single;

architecture Behavioral of driver_pwm_rgb_single is
    constant C_REFRESH_COUNT_MAX : integer := (C_F_CLK / C_F_COUNT) - 1;
    constant C_BIT_RED : natural := 0;
    constant C_BIT_GREEN : natural := 1;
    constant C_BIT_BLUE : natural := 2;

    signal pulse_count_i : std_logic := '0';
    signal rgb_count_i : std_logic_vector(7 downto 0) := (others=>'0');

begin

    -- TODO: write process to generate a count pulse
    
    -- TODO: write a process to increase rgb_count_i on every count pulse

    -- TODO: generate pwm output signals based on rgb_count_i and regR/G/B inputs (no process!)

end Behavioral;
