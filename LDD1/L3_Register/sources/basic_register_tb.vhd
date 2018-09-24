----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: basic_register_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the basic_register. Testing reset, load and data hold operation.
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

entity basic_register_tb is
end basic_register_tb;

architecture Behavioral of basic_register_tb is
    -- constants
    constant clk_period : time := 10 ns;
    constant C_DATA_WIDTH : integer := 16;
        
    -- inputs
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal le        : std_logic := '0';
    signal data_in   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    -- outputs
    signal data_out  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    
    -- DUT
    component basic_register is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
                  le : in  std_logic;
             data_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
    );
    end component;
    
    type debug_t is (resetting, paused ,load_data, hold_data, ended);
    signal debug : debug_t;
       
begin

    DUT : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
              clk => clk,
            reset => reset,
               le => le,
          data_in => data_in,
         data_out => data_out
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
        
        -- load data
        debug <= load_data;
        data_in <= x"BEEF";
        le<='1';
        
        write (s, string'("Test load..."));
        writeline (output, s); 
        wait for clk_period;
        assert data_out = x"BEEF"
            report "Loading data failed"
            severity error;
            
        -- immediatly load new data
        data_in <= x"DEAD";
        
        write (s, string'("Test load (2)..."));
        writeline (output, s); 
        wait for clk_period;
        assert data_out = x"DEAD"
            report "Loading data failed"
            severity error;
        
        --synchronise to falling edge
        debug <= paused;
        wait until falling_edge(clk);
        le <= '0';        
     
        -- check if data is hold
        debug <= hold_data;
        wait for clk_period;
        write (s, string'("Test hold..."));
        writeline (output, s); 
        assert data_out = x"DEAD"
            report "Holding data failed"
            severity error;
        wait for clk_period * 2;
        
        -- test reset
        debug <= resetting;
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        
        write (s, string'("Test (async) reset..."));
        writeline (output, s); 
        assert data_out = x"0000"
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
