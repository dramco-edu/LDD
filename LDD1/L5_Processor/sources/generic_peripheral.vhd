----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: generic_peripheral - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  generic_peripheral
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.processor_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generic_peripheral is
 generic(
       C_ADDR_BASE : std_logic_vector := x"F0"; 
       
       C_DATA_BUS_WIDTH : natural := 8;
       C_DATA_REG_WIDTH : natural :=8;
       C_REGISTER_COUNT : natural := 8;
       
       ENABLE_DIRECT_INPUT : natural:= 1 -- 1 for input
   );
   port(

        clk : in  std_logic;
        reset : in  std_logic;
        
        direct_in : in std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
        direct_out : out std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
        
        --bus access
        addr : in std_logic_vector (C_ADDR_BASE'range);
        data_in : in  std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
        data_out : out std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
        read_en : in std_logic;
        write_en : in std_logic;
        ready : out std_logic;
        read_en_peri : out std_logic;
        write_en_peri : out std_logic
   );
   
end generic_peripheral;

architecture Behavioral of generic_peripheral is
    constant C_ADDR_PERI_WIDTH : natural := nb_bit_req(C_REGISTER_COUNT);


    signal addr_peri_i : std_logic_vector(C_ADDR_PERI_WIDTH-1 downto 0);
    signal write_en_i :std_logic;
    signal read_en_i :std_logic;

    component peripheral_address_decoder is
    generic(
        C_ADDR_BASE : std_logic_vector := x"F0"; 
        C_ADDR_PERI_WIDTH : natural := 1
    );
    Port (
        addr : in std_logic_vector (C_ADDR_BASE'range);
        read_en : in std_logic;
        write_en : in std_logic;
        addr_peri: out std_logic_vector (C_ADDR_PERI_WIDTH-1 downto 0);
        read_en_peri :out std_logic;
        write_en_peri :out std_logic
    );
  end component;
  
  component peripheral_registers is

       generic(
            C_DATA_BUS_WIDTH : natural := 8;
            C_DATA_REG_WIDTH : natural := 8;
            C_REGISTER_COUNT : natural := 8;
          
            ENABLE_DIRECT_INPUT : natural:= 1 -- 1 for input
      );
      port(
          clk : in  std_logic;
          reset : in  std_logic;
          le : in  std_logic;
          
          direct_in : in std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
          direct_out : out std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
          
          --bus access
          addr : in std_logic_vector(nb_bit_req(C_REGISTER_COUNT)-1 downto 0);
          data_in : in  std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
          data_out : out std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0)
      );
  end component;
begin

     DECODER : peripheral_address_decoder
        generic map(
            C_ADDR_BASE => C_ADDR_BASE,
            C_ADDR_PERI_WIDTH => C_ADDR_PERI_WIDTH
        )
        port map(
            addr => addr,
            read_en => read_en,
            write_en => write_en,
           
            addr_peri => addr_peri_i,
            read_en_peri => read_en_i,
            write_en_peri => write_en_i
        );
    
    --register
    PERIPHERAL : peripheral_registers
        generic map(
            C_DATA_REG_WIDTH => C_DATA_REG_WIDTH,
            C_DATA_BUS_WIDTH => C_DATA_BUS_WIDTH,
            C_REGISTER_COUNT => C_REGISTER_COUNT,
            
            ENABLE_DIRECT_INPUT => ENABLE_DIRECT_INPUT -- input is made from the bus
        )
        port map(
                                           
            clk => clk,                    
            reset => reset,                
            le => write_en_i,              
                                           
            direct_in => direct_in,        
            direct_out => direct_out,      
                                           
            --bus access                   
            addr => addr_peri_i,           
            data_in => data_in,            
            data_out => data_out           
        );                                 
                                           
    read_en_peri <= read_en_i;             
    write_en_peri <= write_en_i;           
                                           
    --no delay on read so ready always active
    ready <= '1';

end Behavioral;
