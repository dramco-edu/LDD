----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2021 11:36:11 AM
-- Design Name: 
-- Module Name: driver_pwm_rgb_single_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

library STD;
use STD.TEXTIO.ALL;

entity driver_pwm_rgb_single_tb is
end driver_pwm_rgb_single_tb;

architecture Behavioral of driver_pwm_rgb_single_tb is
    -- signal declarations
    -- constants
    constant C_CLK_PERIOD : time := 20 ns;
    constant C_F_CLK : natural := 50000000;
    constant C_F_COUNT : natural := 250000;
    
    -- inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal regR : std_logic_vector(7 downto 0) := (others=>'0');
    signal regG : std_logic_vector(7 downto 0) := (others=>'0');
    signal regB : std_logic_vector(7 downto 0) := (others=>'0');
    
    -- outputs
    signal rgb : std_logic_vector(2 downto 0) := (others=>'0');
    
    -- dut
    component driver_pwm_rgb_single is
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
    end component;
    
    -- procedure for debug messages
    procedure sim_message(msg : string) is 
        variable s : line;
    begin
        write (s, msg);
        writeline (output, s);
    end procedure;
    
begin

    -- DUT instantiation
    DUT: driver_pwm_rgb_single
    generic map(
          C_F_CLK => C_F_CLK,
        C_F_COUNT => C_F_COUNT
    )
    port map(
          clk => clk,
        reset => reset,
         regR => regR,
         regG => regG,
         regB => regB,
          rgb => rgb
    );

    CLK_PROC: process is
    begin
        clk <= '0';
        wait for C_CLK_PERIOD/2;
        clk <= '1';
        wait for C_CLK_PERIOD/2;
    end process CLK_PROC;

    STIM_PROC: process is
    begin
        wait for C_CLK_PERIOD;
        
        sim_message("SIMULATION START");
        sim_message("Make sure to run for approx. 10 ms");
        sim_message("Testing start-up value... ");
        assert rgb = (rgb'range=>'0')
            report "RGB output not LOW"
            severity ERROR;
        
        if rgb = (rgb'range=>'0') then
            sim_message("TEST PASSED");
        end if;
        
        sim_message("Setting R to < 1% , G to ~50% , B to 100%");
        
        regR <= x"01";
        regG <= x"80";
        regB <= x"FF";
        
        reset <= '1';
        wait for C_CLK_PERIOD;
        reset <= '0';
        
        sim_message("Waiting until red goes LOW");
        wait until rgb(0) = '0';
        sim_message("Waiting until red goes HIGH");
        wait until rgb(0) = '1';
        
        wait for (C_F_CLK / C_F_COUNT) * C_CLK_PERIOD*2 + C_CLK_PERIOD;
        sim_message("Test at >1% ... ");
        assert rgb = "110"
            report "Expected RGB = 110"
            severity WARNING;
        
        if rgb = "110" then
            sim_message("TEST PASSED");
        end if;
        
        wait for (C_F_CLK / C_F_COUNT) * C_CLK_PERIOD * 128;
        sim_message("Test at >50% ... ");
        assert rgb = "100"
            report "Expected RGB = 100"
            severity WARNING;
        
        if rgb = "100" then
            sim_message("TEST PASSED");
        end if;
        
        wait for (C_F_CLK / C_F_COUNT) * C_CLK_PERIOD * 126 - (2 * C_CLK_PERIOD);
        sim_message("Test at <100% ... ");
        assert rgb = "100"
            report "Expected RGB = 100"
            severity WARNING;
        
        if rgb = "100" then
            sim_message("TEST PASSED");
        end if;
        
        wait for (C_F_CLK / C_F_COUNT) * C_CLK_PERIOD;
        sim_message("Test at <1% (new period)... ");
        assert rgb = "111"
            report "Expected RGB = 111"
            severity WARNING;
        
        if rgb = "111" then
            sim_message("TEST PASSED");
        end if;
        
        assert FALSE
            report "SIMULATION ENDED"
            severity NOTE;
        
        wait;
        
    end process STIM_PROC; 

end Behavioral;
