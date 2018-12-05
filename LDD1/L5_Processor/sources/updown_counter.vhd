----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: updown_counter - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  n-bit up and down counter with asynchronous reset and overflow/underflow
--  indication. The count value is not further incremented/decremented when an
--  overflow/underflow occurs. 
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

entity updown_counter is
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
end updown_counter;

architecture Behavioral of updown_counter is

begin
    COUNT_PROC : process (clk, reset) is
        variable c_reg : std_logic_vector(C_NR_BITS-1 downto 0) := (others=>'0');
    begin
        if reset='1' then
            c_reg := (others=>'0');
            overflow <= '0';
            underflow <= '0';
        elsif rising_edge(clk) then
            -- default values
            underflow <= '0';
            overflow <= '0';
            if up = '1' then
                if c_reg = (c_reg'range => '1') then
                    overflow <= '1';
                else
                    c_reg := c_reg + '1';
                end if;
            elsif down = '1' then
                if c_reg = (c_reg'range => '0') then
                    underflow <= '1';
                else
                    c_reg := c_reg - '1';
                end if; 
            end if;
        end if;
        count <= c_reg;
    end process COUNT_PROC;

end Behavioral;
