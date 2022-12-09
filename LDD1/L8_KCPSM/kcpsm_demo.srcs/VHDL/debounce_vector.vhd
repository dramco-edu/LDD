----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: pulser - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Debouncing a group of signals
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce_vector is
    generic(
             C_F_CLK : natural := 50000000; -- system clock frequency
          C_DELAY_MS : natural := 20;       -- debounce period
        C_DATA_WIDTH : natural := 8
    );
    port(
                 clk : in  std_logic;       -- input clock
              vector : in  std_logic_vector(C_DATA_WIDTH-1 downto 0); -- input signal to be debounced
              result : out std_logic_vector(C_DATA_WIDTH-1 downto 0)  -- debounced signal
    );
end entity;

architecture Behavioral of debounce_vector is

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

begin

    DEBOUNCED_VECTOR : for i in 0 to C_DATA_WIDTH-1 generate
    begin
        DEBOUNCERS : debounce
        generic map(
               C_F_CLK => C_F_CLK,            -- system clock frequency
            C_DELAY_MS => C_DELAY_MS          -- debounce period
        )
        port map(
                   clk => clk,                -- input clock
                button => vector(i),          -- input signal to be debounced
                result => result(i)           -- debounced signal
        );
    end generate;
    
end Behavioral;
