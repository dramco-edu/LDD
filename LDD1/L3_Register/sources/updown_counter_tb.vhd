----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: updown_counter_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the updown_counter. Testing up and down counting, both with
--  and without overflow (underflow resp.).
--
--  Report any errors and terminate automatically at the end of the test.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity updown_counter_tb is
end updown_counter_tb;

architecture Behavioral of updown_counter_tb is
    -- constants
    constant clk_period : time := 10 ns;
    constant C_NR_BITS : integer :=2;
    
    constant MAX_VALUE : std_logic_vector(C_NR_BITS-1 downto 0) := (others => '1');
    constant FULL_COUNT_TIME: time := (2**C_NR_BITS-1)*clk_period;
    
    
    -- inputs
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal up        : std_logic := '0';
    signal down      : std_logic := '0';
    
    -- outputs
    signal underflow : std_logic;
    signal overflow  : std_logic;
    signal count     : std_logic_vector(C_NR_BITS-1 downto 0);
    
    -- DUT
    component updown_counter is
    generic(
        C_NR_BITS : integer := 4
    );
    port(
              clk : in  std_logic;
            reset : in  std_logic;
               up : in  std_logic;
             down : in  std_logic;
        underflow : out std_logic;
         overflow : out std_logic;
            count : out std_logic_vector(C_NR_BITS-1 downto 0)
    );
    end component;
    
    type debug_t is (resetting, paused ,up_nof, down_nuf, up_of, down_uf, ended);
    signal debug : debug_t;
       
begin

    DUT : updown_counter
    generic map(
        C_NR_BITS => C_NR_BITS
    )
    port map(
              clk => clk,
            reset => reset,
               up => up,
             down => down,
        underflow => underflow,
         overflow => overflow,
            count => count
    );
    
    CLK_PROC: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process CLK_PROC;
    
    STIM_PROC: process
        variable t : time;
        variable s : line;
    begin
        wait for clk_period*2;
        
        --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count up no overflow
        debug <= up_nof;
        t := now;
        up <= '1';
        wait until count=MAX_VALUE;
        up <= '0';
        
        write (s, string'("Testing count up to maximum ..."));
        writeline (output, s); 
        assert (now-t = FULL_COUNT_TIME-clk_period/2)
            report "Time to count to max value incorrect, check sequences " & cr & time'image(now-t)
            severity error;
        assert overflow='0'
            report "Overflow should not be set."
            severity error;
        assert underflow='0'
            report "Underflow should not be set."
            severity error;
        
        wait for clk_period;
        
        --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
         -- count down no underflow
        debug <= down_nuf;
        t := now;
        down <= '1';
        wait until count=x"0";
        down <= '0';

        write (s, string'("Testing count down to minimum ..."));
        writeline (output, s); 
        assert now-t = FULL_COUNT_TIME-clk_period/2
            report "Time to count down to 0 incorrect, check sequences " & cr & time'image(now-t)
            severity error;
        assert overflow='0'
            report "Overflow should not be set."
            severity error;
        assert underflow='0'
            report "Underflow should not be set."
            severity error;
            
        wait for clk_period;
        
        --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count up with overflow
        debug <= up_of;
        up <= '1';
        t := now;
        write (s, string'("Testing count up with overflow ..."));
        writeline (output, s); 
        wait until overflow='1';
        assert now-t = FULL_COUNT_TIME+clk_period/2
          report "Time to count past max value (overflow) incorrect, check sequences " & cr & time'image(now-t)
          severity error;
        assert underflow='0'
          report "Underflow should not be set."
          severity error;
        wait for clk_period;
        up <= '0';
        wait for clk_period;
        
        --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count down with underflow
        debug <= down_uf;
        down <= '1';
        t := now;
        write (s, string'("Testing count down with underflow ..."));
        writeline (output, s); 
        wait until underflow='1';
        assert now-t = FULL_COUNT_TIME+clk_period/2
            report "Time to count down to underflow incorrect, check sequences " & cr & time'image(now-t)
            severity error;
        assert overflow='0'
            report "Overflow should not be set."
            severity error;
        wait for clk_period;
        down <= '0';
        wait for clk_period;
        
         --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count 1 up so we get rid of underflow
        debug <= up_nof;
        up <= '1';
        wait for clk_period;
        up <= '0';
        assert underflow='0'
            report "Underflow/overflow should not be set."
            severity error;
        assert overflow='0'
            report "Overflow should not be set."
            severity error;
               
        -- end simulation
        debug <= ended;
        wait for clk_period*4;
        assert false
            report "SIMULATION ENDED"
            severity NOTE;
        wait;
            
    end process STIM_PROC;
    
end Behavioral;
