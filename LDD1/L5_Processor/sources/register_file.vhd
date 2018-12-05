----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: register_file - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Generic register file description. The number of registers and the data width
--  can be set with C_NR_REGS and C_DATA_WIDTH respectively.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
    generic(
        C_DATA_WIDTH : natural := 8;
           C_NR_REGS : natural := 8
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
                  le : in  std_logic;
              in_sel : in  std_logic_vector(C_NR_REGS-1 downto 0);
             out_sel : in  std_logic_vector(C_NR_REGS-1 downto 0);
             data_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
    );
end register_file;

architecture Behavioral of register_file is

    type d_bus_t is array(C_NR_REGS-1 downto 0) of std_logic_vector(C_DATA_WIDTH-1 downto 0); 
    signal d_out_bus1 : d_bus_t;
    signal d_out_bus2 : d_bus_t;
    signal d_out_bus3 : d_bus_t;
    
    signal le_i : std_logic_vector(C_NR_REGS-1 downto 0);

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
begin

    le_i <= in_sel when le='1' else (others=>'0');

    REG_FILE : for i in 0 to C_NR_REGS-1 generate
    begin
        REG_INST : basic_register
        generic map(
            C_DATA_WIDTH => C_DATA_WIDTH
        )
        port map(
                     clk => clk,
                   reset => reset,
                      le => le_i(i),
                 data_in => data_in,
                data_out => d_out_bus1(i)
        );
        
        d_out_bus2(i) <= d_out_bus1(i) when out_sel(i) = '1' else (others=>'0');
    end generate;
    
    d_out_bus3(C_NR_REGS-1) <= d_out_bus2(C_NR_REGS-1);
    
    OUT_MUX : for i in 1 to C_NR_REGS-1 generate
    begin
        d_out_bus3(i-1) <= d_out_bus2(i-1) or d_out_bus3(i);
    end generate;
    
    data_out <= d_out_bus3(0);
    
end Behavioral;
