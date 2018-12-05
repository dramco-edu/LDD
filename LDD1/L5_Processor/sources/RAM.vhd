----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: RAM - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor RAM
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RAM is
    generic(
           C_ADDR_WIDTH : natural := 6;
           C_DATA_WIDTH : natural := 8
    );
    port(
                    clk : in  std_logic;
            address_bus : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            data_bus_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
           data_bus_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
                read_en : in  std_logic;
               write_en : in  std_logic
    );
end RAM;

architecture Behavioral of RAM is
    signal re_i : std_logic := '0';
    signal we_i : std_logic := '0';
    
    signal do_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal di_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    signal a_i : std_logic_vector(5 downto 0) := (others=>'0');
begin

    DIST_RAM64_Word: for i in 0 to C_DATA_WIDTH-1 generate
    begin
        RAM64X1S_inst : RAM64X1S
        generic map (
            INIT => X"0000000000000000")
        port map (
            O => do_i(i),   -- 1-bit data output
            A0 => a_i(0),   -- Address[0] input bit
            A1 => a_i(1),   -- Address[1] input bit
            A2 => a_i(2),   -- Address[2] input bit
            A3 => a_i(3),   -- Address[3] input bit
            A4 => a_i(4),   -- Address[4] input bit
            A5 => a_i(5),   -- Address[5] input bit
            D => di_i(i),   -- 1-bit data input
            WCLK => clk,    -- Write clock input
            WE => we_i      -- Write enable input
        );
    end generate;
    
    A_LENGTH_MATCH_SHORTER: if C_ADDR_WIDTH < 6 generate
    begin
        a_i(5 downto address_bus'high+1) <= (others=>'0');
        a_i(address_bus'high downto 0) <= address_bus;
    end generate;
    
    A_LENGTH_MATCH_EQUAL: if C_ADDR_WIDTH = 6 generate
    begin
        a_i <= address_bus;
    end generate;
    
    A_LENGTH_MATCH_LONGER: if C_ADDR_WIDTH > 6 generate
    begin
        a_i <= address_bus(5 downto 0);
    end generate;
    
    we_i <= write_en;
    re_i <= read_en;
    di_i <= data_bus_in;
    
    DO_REG_PROC: process(clk) is
        variable do_reg : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    begin
        if rising_edge(clk) then
            if re_i = '1' then
                do_reg := do_i;
            end if; 
        end if;
        data_bus_out <= do_reg;
    end process;
    
end Behavioral;
