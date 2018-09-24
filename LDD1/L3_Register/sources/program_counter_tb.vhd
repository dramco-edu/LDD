----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: program_counter_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the Program_Counter module. Testing reset, load and count 
--  operation.
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

entity program_counter_tb is
end program_counter_tb;

architecture Behavioral of program_counter_tb is
    -- constants
    constant clk_period : time := 10 ns;
    constant C_NR_BITS : natural := 12;
    constant C_PC_STEP : natural := 4;
    
    -- inputs
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal up        : std_logic := '0';
    signal le        : std_logic := '0';
    signal pc_in     : std_logic_vector(C_NR_BITS-1 downto 0) := (others=>'0');
    
    -- outputs
    signal pc_out    : std_logic_vector(C_NR_BITS-1 downto 0);
    
    -- DUT
    component program_counter is
    generic(
        C_PC_WIDTH : natural := 8;
         C_PC_STEP : natural := 2
    );
    port(
               clk : in  std_logic;
             reset : in  std_logic;
                up : in  std_logic;
                le : in  std_logic;
             pc_in : in  std_logic_vector(C_PC_WIDTH-1 downto 0);
            pc_out : out std_logic_vector(C_PC_WIDTH-1 downto 0)
    );
    end component;
    
    type debug_t is (resetting, paused ,count, load, ended);
    signal debug : debug_t;
       
begin

    DUT : program_counter
    generic map(
       C_PC_WIDTH => C_NR_BITS,
        C_PC_STEP => C_PC_STEP
    )
    port map(
              clk => clk,
            reset => reset,
               up => up,
               le => le,
            pc_in => pc_in,
           pc_out => pc_out
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
        
        -- synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count up
        debug <= count;
        up <= '1';
        wait for clk_period * 2;
        up <= '0';
        
        write (s, string'("Test count..."));
        writeline (output, s);    
        assert pc_out = x"008"
            report "Count up failed, check step size."
            severity error;
        wait for clk_period;
        
        -- synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- load PC
        debug <= load;
        pc_in <= x"A55";
        le <= '1';
        wait for clk_period;
        le <= '0';
        
        write (s, string'("Test load..."));
        writeline (output, s); 
        assert pc_out = x"A55"
          report "Load PC failed"
          severity error;
        wait for clk_period;
        
        -- synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- count up
        debug <= count;
        up <= '1';
        wait for clk_period * 2;
        up <= '0';
        
        write (s, string'("Test count..."));
        writeline (output, s); 
        assert pc_out = x"A5D"
            report "Count up failed, check step size."
            severity error;
        wait for clk_period;
        
        -- synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        
        -- test
        debug <= resetting;
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        
        write (s, string'("Test async reset..."));
        writeline (output, s); 
        assert pc_out = x"000"
            report "Reset failed"
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
