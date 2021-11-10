----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: peripheral_registers - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor peripheral_registers
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.processor_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity peripheral_registers is
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
end peripheral_registers;

architecture Behavioral of peripheral_registers is
    
    type d_bus_t is array((C_REGISTER_COUNT)-1 downto 0) of std_logic_vector(C_DATA_REG_WIDTH-1 downto 0); 
    
    signal data_in_i : std_logic_vector(C_DATA_REG_WIDTH-1 downto 0);
    signal data_in_placeholder : std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
    signal input_bus : d_bus_t;
    signal output_bus : d_bus_t;
    signal output_bus_filtered : d_bus_t;
    signal output_bus_mux : d_bus_t;
       
    signal le_i : std_logic_vector(C_REGISTER_COUNT-1 downto 0);
    
    
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

    --resize the input
    data_in_i <= data_in(data_in_i'range);
    data_in_placeholder <= data_in;
    --TOOD: check if greater
    
    --register file
    REG_FILE : for i in output_bus'range generate
    begin
        REG_INST : basic_register
        generic map(
            C_DATA_WIDTH => C_DATA_REG_WIDTH
        )
        port map(
                     clk => clk,
                   reset => reset,
                      le => le_i(i),
                 data_in => input_bus(i),
                data_out => output_bus(i)
        );
    end generate;
        
    --connect the register input to the direct input, and active writing in permance
    direct_input_acces: if ENABLE_DIRECT_INPUT = 1 generate
        --put the port in high impedence to allow access inside
        input_direct_connection: for i in input_bus'range generate  
            input_bus(i) <= direct_in((i+1)*C_DATA_REG_WIDTH-1 downto i*C_DATA_REG_WIDTH);
        end generate;
        
        le_i <= (others =>'1');
    end generate;

    --connect the register input to the bus
    bus_input_access: if ENABLE_DIRECT_INPUT = 0 generate
        bus_direct_connection: for i in input_bus'range generate 
            input_bus(i) <= data_in_i;
        end generate;
        
        address_decoding: for i in le_i'range generate
            le_i(i) <= '1' when addr = std_logic_vector(to_unsigned(i, addr'length)) and le = '1' else '0';
        end generate;
    end generate;
    
    --connect the register output to the direct output
    output_direct_connection: for i in input_bus'range generate  
        direct_out((i+1)*C_DATA_REG_WIDTH-1 downto i*C_DATA_REG_WIDTH) <= output_bus(i);
    end generate;
    
    --filter the output to keep only the one corresponding to the address
    address_output_decoding: for i in le_i'range generate
        output_bus_filtered(i) <= output_bus(i) when addr = std_logic_vector(to_unsigned(i, addr'length)) else (others=>'0');
    end generate;
    
    --combine the outputs to one signal
    output_bus_mux(output_bus_mux'high) <= output_bus_filtered(output_bus_filtered'high);
    OUT_MUX : for i in 1 to output_bus_mux'high generate
    begin   
        output_bus_mux(i-1) <= output_bus_filtered(i-1) or output_bus_mux(i);
    end generate;
    
    --connect the output
    data_out <= std_logic_vector(resize(unsigned(output_bus_mux(0)), data_out'length));
    
  
 

end Behavioral;
