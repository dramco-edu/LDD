----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: basic_register - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  An n-bit program counter module. The count step is set during instantiation.
--  A new count value can be loaded synchronously (le). Reset is asynchronous.
--  For a synchronous reset -> load "00..0"
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter is
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
end Program_Counter;

architecture Behavioral of Program_Counter is

begin
    
    -- implementation of the Program Counter functionality
    PC_PROC : process(reset,clk)
        variable pc_reg : std_logic_vector(C_PC_WIDTH-1 downto 0) :=  (others=>'0');
    begin
        if reset='1' then
            pc_reg := (others=>'0');
        elsif rising_edge(clk) then
            if up='1' then
                pc_reg := pc_reg + std_logic_vector(to_unsigned(C_PC_STEP, pc_reg'length));
                --pc_reg := pc_reg + std_logic_vector(to_unsigned(C_PC_STEP, C_PC_WIDTH));
            elsif le = '1' then
                pc_reg := pc_in;
            end if;
        end if;
        pc_out <= pc_reg;
    end process PC_PROC;

end Behavioral;
