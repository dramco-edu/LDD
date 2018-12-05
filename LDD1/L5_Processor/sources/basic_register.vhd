----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: basic_register - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  A "standard" n-bit register with asycnhronous reset and synchronous load,
--  using a "load enable" signal (le).
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

entity basic_register is
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
end basic_register;

architecture Behavioral of basic_register is

begin

    REGISTER_PROC : process(clk,reset)
        variable reg : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    begin
        if reset = '1' then
            reg := (others=>'0');
        elsif rising_edge(clk) then
            if le = '1' then
                reg := data_in;
            end if;
        end if;
        data_out <= reg;
    end process REGISTER_PROC;

end Behavioral;
