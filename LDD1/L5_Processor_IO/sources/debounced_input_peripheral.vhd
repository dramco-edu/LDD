----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy, Sylvain Ieri
-- 
-- Module Name: debounced_input_peripheral - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  An input peripheral with debounced inputs
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

entity debounced_input_peripheral is
generic(
       C_ADDR_BASE : std_logic_vector := x"F0"; 
       
       C_DATA_BUS_WIDTH : natural := 8;
       C_DATA_REG_WIDTH : natural := 8;
       C_REGISTER_COUNT : natural := 8;
       
        C_F_CLK : natural := 50000000; -- system clock frequency
        C_DELAY_MS : natural := 20      -- debounce period
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
        write_en_peri : out std_logic;
        
        irq : out std_logic
   );
end debounced_input_peripheral;

architecture Behavioral of debounced_input_peripheral is


    signal register_out_i : std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);

    signal debounced_i : std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
    signal irq_i : std_logic;

     component generic_peripheral is
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
    end component;
    
    component debounce_vector is
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
    end component;

    component diff_detector is
    Generic(
        C_DATA_WIDTH : natural := 8
    );
    Port ( 
        clk : in std_logic;
        reset: in std_logic;     
        
        a : in std_logic_vector (C_DATA_WIDTH-1 downto 0);
        b : in std_logic_vector (C_DATA_WIDTH-1 downto 0);

        diff : out std_logic
    );
    end component;
    
    begin
         REGISTERS: generic_peripheral
          generic map(
             C_ADDR_BASE => C_ADDR_BASE,
             
             C_DATA_BUS_WIDTH => C_DATA_BUS_WIDTH,
             C_DATA_REG_WIDTH => C_DATA_REG_WIDTH,
             C_REGISTER_COUNT => C_REGISTER_COUNT,
             
             ENABLE_DIRECT_INPUT => 1
         )
         port map(
            clk => clk,
            reset => reset,
              
            direct_in => debounced_i,
            direct_out => register_out_i,
              
            --bus access
            data_in => data_in,
            data_out => data_out,
            
            addr => addr,
            read_en => read_en,
            write_en => write_en,
            ready => ready,
            read_en_peri => read_en_peri,
            write_en_peri => write_en_peri
         );

    -- debouncer for the buttons 
    BTNS_DEBOUNCING : debounce_vector
        generic map(
                 C_F_CLK => C_F_CLK,    -- system clock frequency
              C_DELAY_MS => C_DELAY_MS, -- debounce period
            C_DATA_WIDTH => C_DATA_REG_WIDTH*C_REGISTER_COUNT
        )
        port map(
                     clk => clk,        -- input clock
                  vector => direct_in,       -- input signal to be debounced
                  result => debounced_i  -- debounced signal
        );
        
    --generate irq
    IRQ_DETECT : diff_detector
    generic map(
        C_DATA_WIDTH => C_DATA_REG_WIDTH*C_REGISTER_COUNT
    )
    port map(
        clk => clk,
        reset => reset, 
        
        a => register_out_i,
        b => debounced_i,
        diff => irq
    );

    direct_out <= register_out_i;

end Behavioral;
