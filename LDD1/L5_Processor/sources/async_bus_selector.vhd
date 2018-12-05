----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: RAM - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Async bus selector
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

entity async_bus_selector is
    generic(
       C_DATA_WIDTH : natural:= 8; 
       C_COUNT: natural := 4
    );
    Port ( 
    
        data_bus_all : in std_logic_vector (C_DATA_WIDTH*C_COUNT-1 downto 0);
        sel : in std_logic_vector(C_COUNT-1 downto 0);
        data_bus : out std_logic_vector (C_DATA_WIDTH-1 downto 0)
    );
end async_bus_selector;

architecture Behavioral of async_bus_selector is
    signal data_bus_i : std_logic_vector (C_DATA_WIDTH-1 downto 0);
begin

    PC_MUL: process(data_bus_all, sel)
    begin            
        data_bus_i <= (others => '0');
        for i in sel'range loop
            if sel(i) = '1' then
                data_bus_i <= data_bus_all((i+1) * C_DATA_WIDTH-1 downto i*C_DATA_WIDTH);
            end if;
        end loop;    

    end process PC_MUL;
    
    data_bus <= data_bus_i;
    
end Behavioral;

