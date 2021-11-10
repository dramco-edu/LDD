----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: top - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  top design with the LDD processor, RAM, program ROM and peripherals
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

entity top is
    port(
                clk : in    std_logic;
        btnCpuReset : in    std_logic;
        
                 sw : in    std_logic_vector(15 downto 0);
               btnC : in    std_logic;
               btnU : in    std_logic;
               btnL : in    std_logic;
               btnR : in    std_logic;
               btnD : in    std_logic;
                led : out   std_logic_vector(15 downto 0);
                seg : out   std_logic_vector(6 downto 0);
                 an : out   std_logic_vector(7 downto 0)
    );
end top;

architecture Behavioral of top is
    constant C_ADDR_WIDTH : natural := 8;
    constant C_DATA_WIDTH : natural := 8;
    constant C_NR_BTNS    : natural := 5;
    constant C_NR_SW      : natural := 16;
    constant C_NR_LEDS    : natural := 16;
    constant C_F_CLK      : natural := 12500000;
    constant C_DELAY_MS   : natural := 1;
    
    signal clk_i : std_logic := '0';
    signal reset_i : std_logic := '0';
    
    signal leds_i : std_logic_vector(C_NR_LEDS-1 downto 0) := (others=>'0');
    signal btns_i : std_logic_vector(C_NR_BTNS-1 downto 0) := (others=>'0');
    signal sw_i : std_logic_vector(C_NR_SW-1 downto 0) := (others=>'0');
    signal seg_i : std_logic_vector(6 downto 0) := (others=>'0');
    signal an_i : std_logic_vector(3 downto 0) := (others=>'0');
    
    signal address_bus_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others=>'0');
    signal data_bus_processor_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal data_bus_processor_in_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal data_bus_rom_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal data_bus_ram_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal data_bus_io_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    signal ready_io_i : std_logic := '0';
    signal ready_processor_i : std_logic := '0';
    signal read_en_i : std_logic := '0';
    signal write_en_i : std_logic := '0';
    signal read_en_rom_i : std_logic := '0';
    signal read_en_ram_i : std_logic := '0';
    signal write_en_ram_i : std_logic := '0';
    signal read_en_io_i : std_logic := '0';
    signal write_en_io_i : std_logic := '0';
    signal irq_i : std_logic := '0';
    
    signal rom_sel_i : std_logic := '0';
    signal ram_sel_i : std_logic := '0';
    signal io_sel_i : std_logic := '0';
    
    component Processor is
    generic(
           C_ADDR_WIDTH : natural := 8;
           C_DATA_WIDTH : natural := 8
    );
    port(
                    clk : in  std_logic;
                  reset : in  std_logic;
            address_bus : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            data_bus_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
           data_bus_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
                read_en : out std_logic;
               write_en : out std_logic;
                    irq : in  std_logic;
                  ready : in  std_logic
    );
    end component;
    
    -- 128 byte rom
    component ROM is
    generic( -- do not change these values
           C_ADDR_WIDTH : natural := 7;
           C_DATA_WIDTH : natural := 8
    );
    port(
                    clk : in  std_logic;
                read_en : in  std_logic;
            address_bus : in  std_logic_vector((C_ADDR_WIDTH -1) downto 0);
           data_bus_out : out std_logic_vector((C_DATA_WIDTH -1) downto 0)
    );
    end component;
    
    -- 64 byte ram
    component RAM is
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
    end component;
    
    -- IO interface
    component IO is
    generic(
                C_F_CLK : natural := 100000000;
             C_DELAY_MS : natural := 20;
           C_ADDR_WIDTH : natural := 6;
           C_DATA_WIDTH : natural := 8;
              C_NR_BTNS : natural := 5;
                C_NR_SW : natural := 16;
              C_NR_LEDS : natural := 16
    );
    port(
                    clk : in  std_logic;
                  reset : in  std_logic;

            address_bus : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            data_bus_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
           data_bus_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
                read_en : in  std_logic;
               write_en : in  std_logic;
                    irq : out std_logic;
                  ready : out std_logic;
                                    
                     sw : in  std_logic_vector(C_NR_SW-1 downto 0);
                   btns : in  std_logic_vector(C_NR_BTNS-1 downto 0);
                   leds : out std_logic_vector(C_NR_LEDS-1 downto 0);
                    seg : out std_logic_vector(6 downto 0);
                     an : out std_logic_vector(3 downto 0)
    );
    end component;
begin
    -- connections with external pins
    sw_i <= sw; -- dip switches
    btns_i <= btnC & btnU & btnL & btnR & btnD; -- push buttons grouped in a vector
    led <= leds_i; -- leds
    
    an <= "1111" & an_i;
    seg <= seg_i;
   
    -- processor reset
    reset_i <= not btnCpuReset;
    
    -- clock (no buffer or divider for now)
    CLOCK_DIV : BUFR
    generic map (
       BUFR_DIVIDE => "8",      -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
       SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
    )
    port map (
       O => clk_i,     -- 1-bit output: Clock output port
       CE => '1',      -- 1-bit input: Active high, clock enable (Divided modes only)
       CLR => '0',     -- 1-bit input: Active high, asynchronous clear (Divided modes only)
       I => clk        -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
    );
    --clk_i <= clk;

    -- Peripheral selection
    rom_sel_i <= not address_bus_i(C_ADDR_WIDTH-1);
    ram_sel_i <= address_bus_i(C_ADDR_WIDTH-1) and not address_bus_i(C_ADDR_WIDTH-2);
    io_sel_i <= address_bus_i(C_ADDR_WIDTH-1) and address_bus_i(C_ADDR_WIDTH-2);
    
    -- control signals
    read_en_rom_i  <= read_en_i  and rom_sel_i;
    read_en_ram_i  <= read_en_i  and ram_sel_i;
    write_en_ram_i <= write_en_i and ram_sel_i;
    read_en_io_i   <= read_en_i  and io_sel_i;
    write_en_io_i  <= write_en_i and io_sel_i;
    
    -- processor data in bus 
    data_bus_processor_in_i <= data_bus_rom_out_i when rom_sel_i='1' else 
                               data_bus_ram_out_i when ram_sel_i='1' else
                               data_bus_io_out_i;

    --generate processor ready signal, only used by the IO
    ready_processor_i <= ready_io_i when io_sel_i = '1' else '1';  

    -- processor instance
    PROCESSOR_INST : Processor
    generic map(
           C_ADDR_WIDTH => C_ADDR_WIDTH,
           C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                    clk => clk_i,
                  reset => reset_i,
            address_bus => address_bus_i,
            data_bus_in => data_bus_processor_in_i,
           data_bus_out => data_bus_processor_out_i,
                read_en => read_en_i,
               write_en => write_en_i,
                    irq => irq_i,
                  ready => ready_processor_i
    );
    

    
    -- program ROM instance
    ROM_INST : ROM
    generic map(
           C_ADDR_WIDTH => C_ADDR_WIDTH-1,
           C_DATA_WIDTH => 8
    )
    port map(
                    clk => clk_i,
                read_en => read_en_rom_i,
            address_bus => address_bus_i(C_ADDR_WIDTH-2 downto 0),
           data_bus_out => data_bus_rom_out_i(7 downto 0)
    );

    
    -- RAM instance
    RAM_INST : RAM
    generic map(
           C_ADDR_WIDTH => C_ADDR_WIDTH-2,
           C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                    clk => clk_i,
            address_bus => address_bus_i(C_ADDR_WIDTH-3 downto 0),
            data_bus_in => data_bus_processor_out_i,
           data_bus_out => data_bus_ram_out_i,
                read_en => read_en_ram_i,
               write_en => write_en_ram_i
    );
    
    -- IO instance
    IO_INST : IO
    generic map(
                C_F_CLK => C_F_CLK,
             C_DELAY_MS => C_DELAY_MS,
           C_ADDR_WIDTH => C_ADDR_WIDTH-2,
           C_DATA_WIDTH => C_ADDR_WIDTH,
              C_NR_BTNS => C_NR_BTNS,
                C_NR_SW => C_NR_SW,
              C_NR_LEDS => C_NR_LEDS
    )
    port map(
                    clk => clk_i,
                  reset => reset_i,
            address_bus => address_bus_i(C_ADDR_WIDTH-3 downto 0),
            data_bus_in => data_bus_processor_out_i,
           data_bus_out => data_bus_io_out_i,
                read_en => read_en_io_i,
               write_en => write_en_io_i,
                    irq => irq_i,
                  ready => ready_io_i,
                     sw => sw_i,
                   btns => btns_i,
                   leds => leds_i,
                    seg => seg_i,
                     an => an_i
    );

end Behavioral;
