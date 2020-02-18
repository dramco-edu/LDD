----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: debounce_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the debounce module.
--
--  Report any errors and terminate automatically at the end of the test.
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

entity debounce_tb is
end debounce_tb;

architecture Behavioral of debounce_tb is
        
    constant C_F_CLK : natural := 2000000;
    constant clk_period : time := (1000000000/C_F_CLK) *1ns;
    constant C_DELAY_MS : natural := 2;        -- debounce period
    constant C_DELAY : time := 2 ms;        -- debounce period
    
    signal clk : std_logic;       -- input clock
    signal button : std_logic;       -- input signal to be debounced
    signal result : std_logic;        -- debounced signal
        
    component debounce is
        generic(
               C_F_CLK : natural := 50000000; -- system clock frequency
            C_DELAY_MS : natural := 20        -- debounce period
        );
        port(
                   clk : in  std_logic;       -- input clock
                button : in  std_logic;       -- input signal to be debounced
                result : out std_logic        -- debounced signal
        );
    end component;
    
     --check if the correct output is given print an error otherwise
    procedure check_output(
        expecting_output: boolean 
    ) is
    begin
        if expecting_output = true then
            --if interrupt is expected test if it's here
            assert result = '1'      
                report "result incorrect should be 'high'"
                severity ERROR;
        else
            --no interrupt should have happen, meaning timeout should have been reached.
            assert result = '0'
                report "result incorrect should be 'low'"
                 severity ERROR;
        end if;
    end procedure check_output;

begin

    UUT : debounce
    generic map(
           C_F_CLK => C_F_CLK,            -- system clock frequency
        C_DELAY_MS => C_DELAY_MS          -- debounce period
    )
    port map(
            clk => clk,                   -- input clock
            button => button,             -- input signal to be debounced
            result => result              -- debounced signal
    );

    CLK_PROC: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process CLK_PROC;
    
    STIM_PROC: process
    begin
        button <= '0';
        wait for C_DELAY;
        check_output(false);
        
        button <= '1';
        wait for clk_period;
        check_output(false);
        
        button <= '0';
        wait for C_DELAY/8;
        check_output(false);
        
        button <= '1';
        wait for C_DELAY/8;
        check_output(false);
        
        button <= '0';
        wait for C_DELAY/4;
        check_output(false);
        
        button <= '1';
        wait for C_DELAY/2;
        check_output(false);
        
        button <= '0';
        wait for clk_period;
        check_output(false);
        
        button <= '1';
        wait for  C_DELAY-clk_period;
        check_output(false);
        
        button <= '0';
        wait for clk_period;
        check_output(false);
        
        button <= '1';
        wait for C_DELAY+clk_period;
        check_output(true);
        
        button <= '0';
        wait for C_DELAY/2;
        check_output(true);
        
        button <= '1';
        wait for clk_period;
        check_output(true);
        
        button <= '0';
        wait for  C_DELAY+clk_period;
        check_output(false);
        
        wait for C_DELAY+ C_DELAY/2;
        assert false
            report "SIMULATION ENDED"
            severity NOTE;
        wait;

            
    end process STIM_PROC;
end Behavioral;
