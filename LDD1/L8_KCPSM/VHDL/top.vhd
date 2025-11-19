----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: top - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Top design file for a kcpsm demonstration setup. This is based on the kcpsm
--  with uart reference design. See copyright by Xilinx, below.
--
-------------------------------------------------------------------------------------------
-- Copyright � 2011-2014, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--
library unisim;
use unisim.vcomponents.all;
--
-------------------------------------------------------------------------------------------
--
--

entity top is
    port(
                clk : in  std_logic;
        btnCpuReset : in  std_logic;
            uart_rx : in  std_logic;
            uart_tx : out std_logic;
               btnU : in  std_logic;
               btnR : in  std_logic;
               btnD : in  std_logic;
               btnL : in  std_logic;
               btnC : in  std_logic;
                 --an : out std_logic_vector(3 downto 0); -- basys3
                 an : out std_logic_vector(7 downto 0); -- nexys4
                seg : out std_logic_vector(6 downto 0)
                
    );
end top;

--
-------------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of top is
    --
    -------------------------------------------------------------------------------------------
    --
    -- Components
    --
    -------------------------------------------------------------------------------------------
    --

    --
    -- declaration of KCPSM6
    --
    component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
    end component;

    --
    -- Program Memory
    --
    component program is
    port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    clk : in std_logic);
    end component;

    --
    -- UART Transmitter with integral 16 byte FIFO buffer
    --
    component uart_tx6 
    port (             data_in : in std_logic_vector(7 downto 0);
                  en_16_x_baud : in std_logic;
                    serial_out : out std_logic;
                  buffer_write : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
    end component;
    
    --
    -- UART Receiver with integral 16 byte FIFO buffer
    --
    component uart_rx6 
    port (           serial_in : in std_logic;
                  en_16_x_baud : in std_logic;
                      data_out : out std_logic_vector(7 downto 0);
                   buffer_read : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
    end component;
    
    --
    -- 7 segment driver
    --
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
    
    --
    -- debouncer for the buttons
    --
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
    
    --
    -- creating single clock period signal
    --
    component pulser is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
            clk : in  STD_LOGIC;
         sig_in : in  STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        sig_out : out STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0)
    );
    end component;

    
    --
    --
    -------------------------------------------------------------------------------------------
    --
    -- Signals
    --
    -------------------------------------------------------------------------------------------
    --
    --
    
    constant C_F_CLK_HZ : natural := 50000000;
    
    -- Signals used to create 50MHz clock from 200MHz differential clock
    --
    signal            clk50_MHz : std_logic;
    --
    --
    -- Signals used to connect KCPSM6
    --
    signal              address : std_logic_vector(11 downto 0);
    signal          instruction : std_logic_vector(17 downto 0);
    signal          bram_enable : std_logic;
    signal              in_port : std_logic_vector(7 downto 0);
    signal             out_port : std_logic_vector(7 downto 0);
    signal              port_id : std_logic_vector(7 downto 0);
    signal         write_strobe : std_logic;
    signal       k_write_strobe : std_logic;
    signal          read_strobe : std_logic;
    signal            interrupt : std_logic;
    signal        interrupt_ack : std_logic;
    signal         kcpsm6_sleep : std_logic;
    signal         kcpsm6_reset : std_logic;
    --
    -- Signals used to connect UART_TX6
    --
    signal      uart_tx_data_in : std_logic_vector(7 downto 0);
    signal     write_to_uart_tx : std_logic;
    signal uart_tx_data_present : std_logic;
    signal    uart_tx_half_full : std_logic;
    signal         uart_tx_full : std_logic;
    signal         uart_tx_reset : std_logic;
    --
    -- Signals used to connect UART_RX6
    --
    signal     uart_rx_data_out : std_logic_vector(7 downto 0);
    signal    read_from_uart_rx : std_logic;
    signal uart_rx_data_present : std_logic;
    signal    uart_rx_half_full : std_logic;
    signal         uart_rx_full : std_logic;
    signal        uart_rx_reset : std_logic;
    --
    -- Signals used to define baud rate
    --
    signal           baud_count : integer range 0 to 26 := 0; 
    signal         en_16_x_baud : std_logic := '0';
    --
    -- Signals to connect the buttons
    --
    constant       C_NR_OF_BTNS : natural := 5;
    constant            C_BTN_U : natural := 4;
    constant            C_BTN_R : natural := 3;
    constant            C_BTN_D : natural := 2;
    constant            C_BTN_L : natural := 1;
    constant            C_BTN_C : natural := 0;
    signal               btns_i : std_logic_vector(C_NR_OF_BTNS-1 downto 0) := (others=>'0');
    signal     btns_debounced_i : std_logic_vector(C_NR_OF_BTNS-1 downto 0) := (others=>'0');
    signal        btns_pulsed_i : std_logic_vector(C_NR_OF_BTNS-1 downto 0) := (others=>'0');
    signal       btns_interrupt : std_logic := '0';
    --
    -- Signals to connect the 7-segment signal
    --
    signal                 an_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal                seg_i : std_logic_vector(6 downto 0) := (others=>'0');
    signal               bcd0_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal               bcd1_i :  std_logic_vector(3 downto 0) := (others=>'0');
    signal               bcd2_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal               bcd3_i : std_logic_vector(3 downto 0) := (others=>'0');

--
--
-------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
-------------------------------------------------------------------------------------------
--
begin
    
    -- connect inputs to internal signals
    btns_i(C_BTN_U) <= btnU;
    btns_i(C_BTN_R) <= btnR;
    btns_i(C_BTN_D) <= btnD;
    btns_i(C_BTN_L) <= btnL;
    btns_i(C_BTN_C) <= btnC;

    assert an'length = 4 or an'length = 8
    report "The 'an' output should be 4 or 8 bits wide"
    severity FAILURE; 

    -- connect internal signals to outputs
    FOUR_SEGMENTS_AN: if an'length = 4 generate
        an <= an_i;            -- for example basys3
    end generate;
    EIGHT_SEGMENTS_AN: if an'length = 8 generate -- but we only use 4
        an <= "1111" & an_i;   -- for example nexys4
    end generate;
    seg <= seg_i;

    --
    ------------------------------------------------------------------------------------------
    -- Debouncer for the buttons
    ------------------------------------------------------------------------------------------
    --
    debounce_btns: debounce_vector
    generic map(
             C_F_CLK => C_F_CLK_HZ,
          C_DELAY_MS => 20,
        C_DATA_WIDTH => C_NR_OF_BTNS
    )
    port map(
                 clk => clk50_MHz,
              vector => btns_i,
              result => btns_debounced_i
    );
    
    pulse_btns: pulser
    generic map(
        C_DATA_WIDTH => C_NR_OF_BTNS
    )
    port map(
            clk => clk50_MHz,
         sig_in => btns_debounced_i,
        sig_out => btns_pulsed_i
    );
    
    --
    -----------------------------------------------------------------------------------------
    -- 7 segment display driver
    -----------------------------------------------------------------------------------------
    --
    display: Driver_7seg_4 
    generic map(
         C_F_CLK => C_F_CLK_HZ -- system clock frequency
    )
    port map(
          clk => clk50_MHz,
        reset => '0',
         bcd0 => bcd0_i,
         bcd1 => bcd1_i,
         bcd2 => bcd2_i,
         bcd3 => bcd3_i,
          seg => seg_i,
           an => an_i
    );
    
    --
    -----------------------------------------------------------------------------------------
    -- Create 50MHz clock from 100MHz clock input
    -----------------------------------------------------------------------------------------
    --
    -- BUFR used to divide by 4 and create a regional clock 
    --
    
    clock_divide: BUFR
    generic map ( BUFR_DIVIDE => "2",
                  SIM_DEVICE => "7SERIES")
    port map (   I => clk,
                 O => clk50_MHz,
                CE => '1',
               CLR => '0');
    
    --
    -----------------------------------------------------------------------------------------
    -- Instantiate KCPSM6 and connect to program ROM
    -----------------------------------------------------------------------------------------
    --
    -- The generics can be defined as required. In this case the 'hwbuild' value is used to 
    -- define a version using the ASCII code for the desired letter. 
    --
    
    processor: kcpsm6
    generic map (       hwbuild => X"42",    -- 42 hex is ASCII Character "B"
               interrupt_vector => X"7F0",   
        scratch_pad_memory_size => 64
    )
    port map(      
                        address => address,
                    instruction => instruction,
                    bram_enable => bram_enable,
                        port_id => port_id,
                   write_strobe => write_strobe,
                 k_write_strobe => k_write_strobe,
                       out_port => out_port,
                    read_strobe => read_strobe,
                        in_port => in_port,
                      interrupt => interrupt,
                  interrupt_ack => interrupt_ack,
                          sleep => kcpsm6_sleep,
                          reset => kcpsm6_reset,
                            clk => clk50_MHz
    );

    --
    -- Reset connected to JTAG Loader enabled Program Memory 
    --
    
    kcpsm6_reset <= not btnCpuReset;

    --
    -- Unused signals tied off until required.
    --
    
    kcpsm6_sleep <= '0';
    interrupt <= btns_interrupt;

    btns_interrupt_ctrl: process (clk)
    begin
        if rising_edge(clk) then
            if not (btns_pulsed_i = (btns_pulsed_i'range=>'0')) then 
                btns_interrupt <= '1';
            elsif interrupt_ack = '1' then
                btns_interrupt <= '0';
            end if;
        end if;
    end process btns_interrupt_ctrl;

    --
    -- Development Program Memory 
    --
    program_rom: program
    port map(        address => address,      
                 instruction => instruction,
                      enable => bram_enable,
                         clk => clk50_MHz);

    --
    -----------------------------------------------------------------------------------------
    -- UART Transmitter with integral 16 byte FIFO buffer
    -----------------------------------------------------------------------------------------
    --
    -- Write to buffer in UART Transmitter at port address 01 hex
    -- 
    
    tx: uart_tx6 
    port map (              data_in => uart_tx_data_in,
                     en_16_x_baud => en_16_x_baud,
                       serial_out => uart_tx,
                     buffer_write => write_to_uart_tx,
              buffer_data_present => uart_tx_data_present,
                 buffer_half_full => uart_tx_half_full,
                      buffer_full => uart_tx_full,
                     buffer_reset => uart_tx_reset,              
                              clk => clk50_MHz);
    

    --
    -----------------------------------------------------------------------------------------
    -- UART Receiver with integral 16 byte FIFO buffer
    -----------------------------------------------------------------------------------------
    --
    -- Read from buffer in UART Receiver at port address 01 hex.
    --
    -- When KCPMS6 reads data from the receiver a pulse must be generated so that the 
    -- FIFO buffer presents the next character to be read and updates the buffer flags.
    -- 
    
    rx: uart_rx6 
    port map (            serial_in => uart_rx,
                     en_16_x_baud => en_16_x_baud,
                         data_out => uart_rx_data_out,
                      buffer_read => read_from_uart_rx,
              buffer_data_present => uart_rx_data_present,
                 buffer_half_full => uart_rx_half_full,
                      buffer_full => uart_rx_full,
                     buffer_reset => uart_rx_reset,              
                              clk => clk50_MHz);
    
    --
    -----------------------------------------------------------------------------------------
    -- RS232 (UART) baud rate 
    -----------------------------------------------------------------------------------------
    --
    -- To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
    -- High at 1,843,200Hz which is every 27.13 cycles at 50MHz. In this implementation 
    -- a pulse is generated every 27 cycles resulting is a baud rate of 115,741 baud which
    -- differs only by 0.5% (high and well within limits).
    --
    baud_rate: process(clk50_MHz)
    begin
        if rising_edge(clk50_MHz) then
            if baud_count = 26 then                    -- counts 27 states including zero
                baud_count <= 0;
                en_16_x_baud <= '1';                     -- single cycle enable pulse
            else
                baud_count <= baud_count + 1;
                en_16_x_baud <= '0';
            end if;
        end if;
    end process baud_rate;
    
    
    --
    -----------------------------------------------------------------------------------------
    -- General Purpose Input Ports. 
    -----------------------------------------------------------------------------------------
    --
    input_ports: process(clk50_MHz)
    begin
        if rising_edge(clk50_MHz) then      
            case port_id(7 downto 6) is
            
                -- UART at base address 80
                when "10" =>
                    -- Read UART status at port address 80 hex
                    if port_id(0) = '0' then
                        in_port(0) <= uart_tx_data_present;
                        in_port(1) <= uart_tx_half_full;
                        in_port(2) <= uart_tx_full; 
                        in_port(3) <= uart_rx_data_present;
                        in_port(4) <= uart_rx_half_full;
                        in_port(5) <= uart_rx_full;
                    else
                        in_port <= uart_rx_data_out;
                    end if;
                
                -- btns at base address 40
                when "01" =>
                    in_port <= "000" & btns_debounced_i;
                
                -- ignore other addresses
                when others =>    in_port <= "XXXXXXXX";  
            
            end case;
            
            -- Generate 'buffer_read' pulse following read from port address 81
            if (read_strobe = '1') and (port_id(0) = '1') and (port_id(7) = '1') then
                read_from_uart_rx <= '1';
            else
                read_from_uart_rx <= '0';
            end if;
        
        end if;
    end process input_ports;


    --
    -----------------------------------------------------------------------------------------
    -- General Purpose Output Ports 
    -----------------------------------------------------------------------------------------
    --
    
    -- derive control signals based on port_id and write_strobe or k_write_strobe
    write_to_uart_tx  <= '1' when (write_strobe = '1') and (port_id(7) = '1')
                           else '0';
                                            
    uart_rx_reset <= k_write_strobe and port_id(0);
    uart_tx_reset <= k_write_strobe and port_id(0);
    
    -- the uart data in is connected directly to the out_port
    uart_tx_data_in <= out_port;
    
    -- this process buffers the out_port into the corresponding registers (based on port_id) 
    output_ports: process(clk50_MHz)
    begin
        if rising_edge(clk50_MHz) then
            if write_strobe = '1' then
                if port_id(6) = '1' then
                    case port_id(1 downto 0) is
                        when "00"   => bcd0_i <= out_port(3 downto 0);
                        when "01"   => bcd1_i <= out_port(3 downto 0);
                        when "10"   => bcd2_i <= out_port(3 downto 0);
                        when others => bcd3_i <= out_port(3 downto 0);
                    end case;
                end if;
            end if;
        end if; 
    end process output_ports;

  --
  -----------------------------------------------------------------------------------------
  --

end Behavioral;

-------------------------------------------------------------------------------------------
--
-- END OF FILE top.vhd
--
-------------------------------------------------------------------------------------------