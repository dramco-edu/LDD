----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy, Sylvain Ieri
-- 
-- Module Name: IO - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor I/O and peripheral sub-system
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

entity IO is
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
            -- global system clock and reset
                    clk : in  std_logic;
                  reset : in  std_logic;
            -- connections to system bus
            address_bus : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            data_bus_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
           data_bus_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
                read_en : in  std_logic;
               write_en : in  std_logic;
                    irq : out std_logic;
                  ready : out std_logic;
            -- connections to FPGA pins       
                     sw : in  std_logic_vector(C_NR_SW-1 downto 0);
                   btns : in  std_logic_vector(C_NR_BTNS-1 downto 0);
                   leds : out std_logic_vector(C_NR_LEDS-1 downto 0);
                    seg : out std_logic_vector(6 downto 0);
                     an : out std_logic_vector(3 downto 0);
                    rgb : out std_logic_vector(2 downto 0)
    );
end IO;

architecture Behavioral of IO is
    constant C_PERIPHERAL_COUNT : natural := 10;
    
    constant C_7SEG_INDEX   : natural := 0;
    constant C_LEDS_INDEX   : natural := 1;
    constant C_BTNS_INDEX   : natural := 2;
    constant C_SW_INDEX     : natural := 3;
    constant C_TIMER_INDEX  : natural := 4;
    constant C_IRQ_E_INDEX  : natural := 5;
    constant C_IRQ_F_INDEX  : natural := 6;
    constant C_UART_INDEX   : natural := 7;
    constant C_CRCC_INDEX   : natural := 8;
    constant C_PWM_INDEX    : natural := 9;

    constant C_LEDS_REGISTER_COUNT : natural := 2;
    constant C_7SEG_REGISTER_COUNT : natural := 4;
    constant C_SW_REGISTER_COUNT   : natural := 2;
    constant C_PWM_REGISTER_COUNT  : natural := 4; -- only 3 used?
    
   -- constant C_LEDS_ADDR_WIDTH : natural := nb_bit_req(C_LEDS_REGISTER_COUNT);
   -- constant C_7SEG_ADDR_WIDTH : natural := nb_bit_req(C_7SEG_REGISTER_COUNT);
    
    signal read_en_all  : std_logic_vector(C_PERIPHERAL_COUNT-1 downto 0);
    signal write_en_all : std_logic_vector(C_PERIPHERAL_COUNT-1 downto 0);
    signal rw_en_all : std_logic_vector(C_PERIPHERAL_COUNT-1 downto 0);
    
    signal ready_all : std_logic_vector(C_PERIPHERAL_COUNT-1 downto 0);
    signal ready_i   : std_logic_vector(0 downto 0);

    signal data_bus_out_all : std_logic_vector((C_PERIPHERAL_COUNT*C_DATA_WIDTH)-1 downto 0);
    
    constant C_IRQ_COUNT : natural := 4;
    -- irq bit numbers
    constant C_IRQ_BTNS  : natural := 0;
    constant C_IRQ_SW    : natural := 1;
    constant C_IRQ_TMR1S : natural := 2;
    constant C_IRQ_UART  : natural := 3;
    
    signal irq_e_reg_i   : std_logic_vector(C_IRQ_COUNT-1 downto 0);
    signal irq_f_reg_i   : std_logic_vector(C_IRQ_COUNT-1 downto 0);
    signal irq_f_i       : std_logic_vector(C_IRQ_COUNT-1 downto 0);
    signal irq_f_2_i     : std_logic_vector(C_IRQ_COUNT-1 downto 0); --used to maintain the flag

    signal sw_reg_i      : std_logic_vector(C_SW_REGISTER_COUNT*C_DATA_WIDTH-1 downto 0) := (others => '0');
    signal sw_reg_in_i   : std_logic_vector(C_SW_REGISTER_COUNT*C_DATA_WIDTH-1 downto 0) := (others => '0');
    signal btns_reg_i    : std_logic_vector(C_NR_BTNS-1 downto 0) := (others => '0');
    signal btns_reg_in_i : std_logic_vector(C_NR_BTNS-1 downto 0) := (others => '0');
    
   
    -- IO module adresses
    constant C_ADDR_PREFI : std_logic_vector(address_bus'length-7 downto 0) := (others => '0');
    constant C_7SEG_ADDR  : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "111000";
    constant C_LEDS_ADDR  : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "110000";
    constant C_BTNS_ADDR  : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "101000";
    constant C_SW_ADDR    : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "100000";
    constant C_TMR1S_ADDR : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "011000";
    constant C_PWM_ADDR   : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "010000";
    constant C_IRQ_E_ADDR : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "000000";
    constant C_IRQ_F_ADDR : std_logic_vector(address_bus'range) := C_ADDR_PREFI & "000001";
    
    signal leds_reg_i      : std_logic_vector(C_LEDS_REGISTER_COUNT*C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal bcd_reg_i       : std_logic_vector(15 downto 0) := (others=>'0');
    signal tmr1s_ctrl_reg_i: std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal pwm_reg_i       : std_logic_vector(31 downto 0) := (others=>'0');
  
    component Driver_7seg_4 is
    generic(
         C_F_CLK : natural := 50000000 -- system clock frequency
    );
    port(
          clk : in  std_logic;
        reset : in  std_logic;
         bcd0 : in  std_logic_vector(3 downto 0);
         bcd1 : in  std_logic_vector(3 downto 0);
         bcd2 : in  std_logic_vector(3 downto 0);
         bcd3 : in  std_logic_vector(3 downto 0);
          seg : out std_logic_vector(6 downto 0);
           an : out std_logic_vector(3 downto 0)
    );
    end component;
    
    component driver_pwm_rgb_single is
    generic(
         C_F_CLK : natural := 50000000 -- system clock frequency
    );
    port(
          clk : in  std_logic;
        reset : in  std_logic;
         regR : in  std_logic_vector(7 downto 0);
         regG : in  std_logic_vector(7 downto 0);
         regB : in  std_logic_vector(7 downto 0);
          rgb : out std_logic_vector(2 downto 0)
    );
    end component;
    
    component Timer_1s is
    generic(
         C_F_CLK : natural := 50000000 -- system clock frequency
    );
    port(
          clk : in  std_logic;
        reset : in  std_logic;
          run : in  std_logic;
        pulse : out std_logic
    );
    end component;
    
    component bus_selector is
        generic(
           C_DATA_WIDTH : natural:= 8; 
           C_COUNT: natural := 4
        );
        Port ( 
                     clk : in  std_logic;
                   reset : in  std_logic;
            data_bus_all : in std_logic_vector (C_DATA_WIDTH*C_COUNT-1 downto 0);
                     sel : in std_logic_vector (C_COUNT-1 downto 0);
                data_bus : out std_logic_vector (C_DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component async_bus_selector is
        generic(
           C_DATA_WIDTH : natural:= 8; 
           C_COUNT: natural := 4
        );
        Port ( 
            data_bus_all : in std_logic_vector (C_DATA_WIDTH*C_COUNT-1 downto 0);
                     sel : in std_logic_vector (C_COUNT-1 downto 0);
                data_bus : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component generic_peripheral is
     generic(
           C_ADDR_BASE : std_logic_vector := x"F0"; 
           
           C_DATA_BUS_WIDTH : natural := 8;
           C_DATA_REG_WIDTH : natural := 8;
           C_REGISTER_COUNT : natural := 8;
           
           ENABLE_DIRECT_INPUT : natural:= 1 -- 1 for input
       );
       port(
                    clk : in  std_logic;
                  reset : in  std_logic;
                
              direct_in : in  std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
             direct_out : out std_logic_vector(C_REGISTER_COUNT*C_DATA_REG_WIDTH-1 downto 0);
                
                --bus access
                   addr : in  std_logic_vector(C_ADDR_BASE'range);
                data_in : in  std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
               data_out : out std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
                read_en : in  std_logic;
               write_en : in  std_logic;
                
                  ready : out std_logic;
           read_en_peri : out std_logic;
          write_en_peri : out std_logic
       );
    end component;
    
    component debounced_input_peripheral is
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
    end component;

--    component uart_peripheral IS
--        GENERIC( 
--            C_ADDR_BASE : std_logic_vector := x"F0"; 
--            C_DATA_BUS_WIDTH : natural := 8;
--            
--            txFifoDepth : positive := 8;
--            rxFifoDepth : positive := 1
--        );
--        PORT( 
--            
--            clk : in  std_logic;
--            reset : in  std_logic;
--            
--            --bus access
--            addr : in std_logic_vector (C_ADDR_BASE'range);
--            data_in : in  std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
--            data_out : out std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
--            read_en : in std_logic;
--            write_en : in std_logic;
--            
--            ready : out std_logic;
--            read_en_peri : out std_logic;
--            write_en_peri : out std_logic;
--            
--            irq : out std_logic;
--            
--            --extenral
--            TxD : out std_logic;
--            RxD : in std_logic
--    );
--    end component ;
    
--    component crc_calculator is
--        generic(
--            C_ADDR_BASE : std_logic_vector := x"F0"; 
--            
--            C_DATA_BUS_WIDTH : natural := 8;
--            C_CRC_BIT_COUNT : natural := 8
--    
--        );
--        port(
--        
--            clk : in  std_logic;
--            reset : in  std_logic;
--            
--            --bus access
--            addr : in std_logic_vector (C_ADDR_BASE'range);
--            data_in : in  std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
--            data_out : out std_logic_vector(C_DATA_BUS_WIDTH-1 downto 0);
--            read_en : in std_logic;
--            write_en : in std_logic;
--            ready : out std_logic;
--            
--            read_en_peri : out std_logic;
--            write_en_peri : out std_logic
--        );
--    end component;

begin

    
    -- LEDs IO module --------------------------------------------------------------  
    LED_REGISTERS : generic_peripheral
          generic map(
             C_ADDR_BASE => C_LEDS_ADDR,
             
             C_DATA_BUS_WIDTH => C_DATA_WIDTH,
             C_DATA_REG_WIDTH => C_DATA_WIDTH,
             C_REGISTER_COUNT => C_LEDS_REGISTER_COUNT,
             
             ENABLE_DIRECT_INPUT => 0
         )
         port map(
            clk => clk,
            reset => reset,
              
            direct_in => (others => '0'),
            direct_out => leds_reg_i, 
              
              --bus accessi
              data_in => data_bus_in,
              data_out => data_bus_out_all(((C_LEDS_INDEX+1)*C_DATA_WIDTH)-1 downto C_LEDS_INDEX*C_DATA_WIDTH),
              
              addr => address_bus,
              read_en => read_en,
              write_en => write_en,
              
              ready => ready_all(C_LEDS_INDEX),
                              
              read_en_peri => read_en_all(C_LEDS_INDEX),
              write_en_peri => write_en_all(C_LEDS_INDEX)
         );
    leds <= leds_reg_i(leds'range);--connect the register to the external leds
    
    -- 7 segment IO module -----------------------------------------------------
    SEG7_REGISTERS: generic_peripheral
          generic map(
             C_ADDR_BASE => C_7SEG_ADDR,
             
             C_DATA_BUS_WIDTH => C_DATA_WIDTH,
             C_DATA_REG_WIDTH => 4,
             C_REGISTER_COUNT => 4,
             
             ENABLE_DIRECT_INPUT => 0
         )
         port map(
            clk => clk,
            reset => reset,
              
            direct_in => (others => '0'),
            direct_out => bcd_reg_i, --bcd_register
              
              --bus accessi
              data_in => data_bus_in,
              data_out => data_bus_out_all(((C_7SEG_INDEX+1) * C_DATA_WIDTH)-1 downto C_7SEG_INDEX*C_DATA_WIDTH),
              
              addr => address_bus,
              read_en => read_en,
              write_en => write_en,
              
              ready => ready_all(C_7SEG_INDEX),
                              
              read_en_peri => read_en_all(C_7SEG_INDEX),
              write_en_peri => write_en_all(C_7SEG_INDEX)
         );
    
    -- 7 segment driver module
    DISP_SEG_DRIVER : Driver_7seg_4
    generic map(
        C_F_CLK => C_F_CLK
    )
    port map(
         clk => clk,
       reset => reset,
        bcd0 => bcd_reg_i(3 downto 0),
        bcd1 => bcd_reg_i(7 downto 4),
        bcd2 => bcd_reg_i(11 downto 8),
        bcd3 => bcd_reg_i(15 downto 12),
         seg => seg,
          an => an
    );    
    
    -- PWM IO module -----------------------------------------------------
    PWM_REGISTERS: generic_peripheral
      generic map(
         C_ADDR_BASE => C_PWM_ADDR,
         
         C_DATA_BUS_WIDTH => C_DATA_WIDTH,
         C_DATA_REG_WIDTH => C_DATA_WIDTH,
         C_REGISTER_COUNT => C_PWM_REGISTER_COUNT,
         
         ENABLE_DIRECT_INPUT => 0
     )
     port map(
        clk => clk,
        reset => reset,
          
        direct_in => (others => '0'),
        direct_out => pwm_reg_i, --bcd_register
          
        --bus accessi
        data_in => data_bus_in,
        data_out => data_bus_out_all(((C_PWM_INDEX+1) * C_DATA_WIDTH)-1 downto C_PWM_INDEX*C_DATA_WIDTH),
        
        addr => address_bus,
        read_en => read_en,
        write_en => write_en,
        
        ready => ready_all(C_PWM_INDEX),
                      
        read_en_peri => read_en_all(C_PWM_INDEX),
        write_en_peri => write_en_all(C_PWM_INDEX)
     );

    
    -- PWM driver module
        -- TODO: add the module

    -- BTNs IO module --------------------------------------------------------------
       BTNS_REGISTERS: debounced_input_peripheral
          generic map(
             C_ADDR_BASE => C_BTNS_ADDR,
             
             C_DATA_BUS_WIDTH => C_DATA_WIDTH,
             C_DATA_REG_WIDTH => C_NR_BTNS,
             C_REGISTER_COUNT => 1,
             
             C_F_CLK => C_F_CLK,    -- system clock frequency
            C_DELAY_MS => C_DELAY_MS -- debounce period
         )
         port map(
            clk => clk,
            reset => reset,
              
            direct_in => btns_reg_in_i,
            direct_out => btns_reg_i,
              
            --bus access
            data_in => data_bus_in,
            data_out => data_bus_out_all(((C_BTNS_INDEX+1)*C_DATA_WIDTH)-1 downto C_BTNS_INDEX*C_DATA_WIDTH),
            
            addr => address_bus,
            read_en => read_en,
            write_en => write_en,
            
            ready => ready_all(C_BTNS_INDEX),
            
            read_en_peri => read_en_all(C_BTNS_INDEX),
            write_en_peri => write_en_all(C_BTNS_INDEX),
            
            irq => irq_f_i(C_IRQ_BTNS)
         );
    btns_reg_in_i(btns'range) <= btns;
         
    -- SWs IO module ---------------------------------------------------------------
   SW_REGISTERS: debounced_input_peripheral
       generic map(
          C_ADDR_BASE => C_SW_ADDR,
          
          C_DATA_BUS_WIDTH => C_DATA_WIDTH,
          C_DATA_REG_WIDTH => C_DATA_WIDTH,
          C_REGISTER_COUNT => C_SW_REGISTER_COUNT,
          
          C_F_CLK => C_F_CLK,    -- system clock frequency
          C_DELAY_MS => C_DELAY_MS -- debounce period
          
      )
      port map(
         clk => clk,
         reset => reset,
           
         direct_in => sw_reg_in_i,
         direct_out => sw_reg_i, --bcd_register
           
         --bus access
         data_in => data_bus_in,
         data_out => data_bus_out_all(((C_SW_INDEX+1)*C_DATA_WIDTH)-1 downto C_SW_INDEX*C_DATA_WIDTH),
         
         addr => address_bus,
         read_en => read_en,
         write_en => write_en,
         
         ready => ready_all(C_SW_INDEX),
                         
         read_en_peri => read_en_all(C_SW_INDEX),
         write_en_peri => write_en_all(C_SW_INDEX),
         irq => irq_f_i(C_IRQ_SW)
      );
   sw_reg_in_i(sw'range) <= sw;
   
    -- Timer 1 second -------------------------------------------------------------
   TIMER_REG: generic_peripheral
        generic map(
           C_ADDR_BASE => C_TMR1S_ADDR,
           
           C_DATA_BUS_WIDTH => C_DATA_WIDTH,
           C_DATA_REG_WIDTH => tmr1s_ctrl_reg_i'length,
           C_REGISTER_COUNT => 1,
           
           ENABLE_DIRECT_INPUT => 0
       )
       port map(
          clk => clk,
          reset => reset,
            
          direct_in => (others=>'0'),
          direct_out => tmr1s_ctrl_reg_i, --bcd_register
            
          --bus access
          data_in => data_bus_in,
          data_out => data_bus_out_all(((C_TIMER_INDEX+1)*C_DATA_WIDTH)-1 downto C_TIMER_INDEX*C_DATA_WIDTH),
          
          addr => address_bus,
          read_en => read_en,
          write_en => write_en,
          
          ready => ready_all(C_TIMER_INDEX),
                          
          read_en_peri => read_en_all(C_TIMER_INDEX),
          write_en_peri => write_en_all(C_TIMER_INDEX)
       );
      
    TMR1S: Timer_1s
    generic map(
        C_F_CLK => C_F_CLK
    )
    port map(
          clk => clk,
        reset => reset,
          run => tmr1s_ctrl_reg_i(0),
        pulse => irq_f_i(C_IRQ_TMR1S)
    );
    
    -- IRQ handling ----------------------------------------------------------------
    -- address decoding
    IRQ_E_REGISTER: generic_peripheral
        generic map(
            C_ADDR_BASE => C_IRQ_E_ADDR,
            
            C_DATA_BUS_WIDTH => C_DATA_WIDTH,
            C_DATA_REG_WIDTH => C_IRQ_COUNT,
            C_REGISTER_COUNT => 1,
            
            ENABLE_DIRECT_INPUT => 0
        )
        port map(
            clk => clk,
            reset => reset,
            
            direct_in => (others => '0'),
            direct_out => irq_e_reg_i, --bcd_register
            
            --bus accessi
            data_in => data_bus_in,
            data_out => data_bus_out_all(((C_IRQ_E_INDEX+1)*C_DATA_WIDTH)-1 downto C_IRQ_E_INDEX*C_DATA_WIDTH),
            
            addr => address_bus,
            read_en => read_en,
            write_en => write_en,
            
            ready => ready_all(C_IRQ_E_INDEX),
                            
            
            read_en_peri => read_en_all(C_IRQ_E_INDEX),
            write_en_peri => write_en_all(C_IRQ_E_INDEX)
        );
        
    IRQ_F_REGISTER: generic_peripheral
        generic map(
            C_ADDR_BASE => C_IRQ_F_ADDR,
            
            C_DATA_BUS_WIDTH => C_DATA_WIDTH,
            C_DATA_REG_WIDTH => C_IRQ_COUNT,
            C_REGISTER_COUNT => 1,
            
            ENABLE_DIRECT_INPUT => 1
        )
        port map(
            clk => clk,
            reset => reset,
            
            direct_in => irq_f_2_i,
            direct_out => irq_f_reg_i, -- irq flag
            
            --bus access
            data_in => data_bus_in,
            data_out => data_bus_out_all(((C_IRQ_F_INDEX+1)*C_DATA_WIDTH)-1 downto C_IRQ_F_INDEX*C_DATA_WIDTH),
            
            addr => address_bus,
            read_en => read_en,
            write_en => write_en,
            
            ready => ready_all(C_IRQ_F_INDEX),
                            
            read_en_peri => read_en_all(C_IRQ_F_INDEX),
            write_en_peri => write_en_all(C_IRQ_F_INDEX)
        );
    
    -- hold the irqs until read
    irq_f_2_i <= irq_f_reg_i or irq_f_i when read_en_all(C_IRQ_F_INDEX) = '0' else (others => '0');
    
    GEN_IRQ: process(clk, reset)   
    begin
        if reset = '1' then
        
            irq <= '0';
        elsif rising_edge(clk) then
            irq <= '0';
            
            for i in irq_f_reg_i'range loop
                if (irq_f_i(i) and not irq_f_reg_i(i) and irq_e_reg_i(i)) = '1' then    --if new flag entered in the register, pulse irq signal
                    irq <= '1';
                end if;
            end loop;
        end if;
    end process GEN_IRQ;
   

    -- BUS read operations ---------------------------------------------------------  
    DATA_OUT_SELECTOR : bus_selector 
        generic map(
           C_DATA_WIDTH => C_DATA_WIDTH, 
           C_COUNT => C_PERIPHERAL_COUNT
        )
        port map( 
            clk => clk,
            reset => reset,
            data_bus_all => data_bus_out_all,
            sel => read_en_all,
            data_bus => data_bus_out
        );
        
        
    rw_en_all <= read_en_all or write_en_all;
    
    -- ready
    

    
    READY_SELECTOR : async_bus_selector 
      generic map(
         C_DATA_WIDTH => 1, 
         C_COUNT => C_PERIPHERAL_COUNT
      )
      port map( 
          data_bus_all => ready_all,
          sel => rw_en_all,
          data_bus => ready_i
      );
    
        ready <= ready_i(0);
        
end Behavioral;
