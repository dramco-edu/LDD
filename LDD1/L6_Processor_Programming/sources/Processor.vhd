----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2017 01:43:20 PM
-- Design Name: 
-- Module Name: Processor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

entity Processor is
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
end Processor;

architecture Behavioral of Processor is
    constant C_PC_STEP : natural := 1;
    
    constant C_NR_REGS : natural := 8;
    constant C_UPC_WIDTH : natural := 6;
    constant C_UCODE_WIDTH : natural := 20;
    constant C_NR_FLAGS : natural := 5;
    constant C_ZF : natural := 4;
    constant C_CF : natural := 3;
    constant C_EF : natural := 2;
    constant C_GF : natural := 1;
    constant C_SF : natural := 0;
    constant IV : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := std_logic_vector( RESIZE(to_unsigned(2,3), C_ADDR_WIDTH)); --"0010" for the cpu bus
   
    -- ALU and flags
    signal alu_op_i    : std_logic_vector(3 downto 0) := (others=>'0');
    signal alu_out_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal alu_flags_i : std_logic_vector(C_NR_FLAGS-1 downto 0);
    
    -- CPU control registers
    signal mar_i  : std_logic_vector(C_ADDR_WIDTH-1 downto 0)  := (others=>'0');
    signal dibr_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0)  := (others=>'0');
    signal dobr_i : std_logic_vector(C_ADDR_WIDTH-1 downto 0)  := (others=>'0');
    signal pc_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0)  := (others=>'0');
    signal ir_i   : std_logic_vector(2*C_DATA_WIDTH-1 downto 0):= (others=>'0');
    signal y_i    : std_logic_vector(C_DATA_WIDTH-1 downto 0)  := (others=>'0');
    signal z_i    : std_logic_vector(C_DATA_WIDTH-1 downto 0)  := (others=>'0');
    signal flags_i: std_logic_vector(C_NR_FLAGS-1 downto 0)    := (others=>'0');

    -- Signals related to register file
    signal reg_file_out_i    : std_logic_vector(C_DATA_WIDTH-1 downto 0):= (others=>'0');
    signal reg_file_in_sel_i : std_logic_vector(C_NR_REGS-1 downto 0)   := (others=>'0');
    signal reg_file_out_sel_i: std_logic_vector(C_NR_REGS-1 downto 0)   := (others=>'0');
    signal reg_file_le_i     : std_logic := '0';
    
    -- Instruction decoding
    signal Rd_i : std_logic_vector(2 downto 0) := (others=>'0');
    signal Rs_i : std_logic_vector(2 downto 0) := (others=>'0');
    signal reg_swap_i : std_logic := '0'; -- swap source and destination field
    alias destination_reg_field_i : std_logic_vector(2 downto 0) is ir_i(10 downto 8);
    alias source_reg_field_i : std_logic_vector(2 downto 0) is ir_i(7 downto 5);
    alias IR_lo_i : std_logic_vector(7 downto 0) is ir_i(7 downto 0);
    
    -- CPU bus
    signal cpu_bus_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    -- interrupt
    signal global_interrupt_enable_i : std_logic := '1';
    signal irq_i : std_logic := '0';

    -- Signals from control unit
    signal cpu_bus_sel_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal flags_le_i : std_logic := '0'; -- same as z_le_i
    signal z_le_i : std_logic := '0'; -- same as flags_le_i
    signal y_le_i : std_logic := '0';
    signal write_en_i : std_logic := '0';
    signal read_en_i : std_logic := '0';
    signal ready_i : std_logic := '0';
    signal ir_hi_le_i : std_logic := '0';
    signal ir_lo_le_i : std_logic := '0';
    signal pc_le_i : std_logic := '0';
    signal pc_up_i : std_logic := '0';
    signal dobr_le_i : std_logic := '0';
    signal dibr_le_i : std_logic := '0';
    signal mar_le_i : std_logic := '0';
    signal sp_i : std_logic_vector(7 downto 0) := (others=>'0');
    signal sp_offset_i : std_logic_vector(4 downto 0) := (others=>'0');
    signal sp_up_i : std_logic := '0';
    signal sp_down_i : std_logic := '0';
    
    -- Counter with parallel load
    component Program_Counter is
    generic(
        C_PC_WIDTH : natural := 8;
         C_PC_STEP : natural := 1
    );
    port(
               clk : in  std_logic;
             reset : in  std_logic;
                up : in  std_logic;
                le : in  std_logic;
             pc_in : in  std_logic_vector(C_PC_WIDTH-1 downto 0);
            pc_out : out std_logic_vector(C_PC_WIDTH-1 downto 0)
    );
    end component;
    
    -- Basic 8-bit register
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
    
    -- Counter that can count up and down
    component updown_counter is
    generic(
        C_NR_BITS : integer := 4
    );
    port(
              clk : in  std_logic;
            reset : in  std_logic;
               up : in  std_logic;
             down : in  std_logic;
        underflow : out std_logic;
         overflow : out std_logic;
            count : out std_logic_vector(C_NR_BITS-1 downto 0)
    );
    end component;
    
    -- Register file
    component Register_File is
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
    end component;
    
    -- Arithmetic and Logic Unit
    component ALU8bit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
         X : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Y : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Z : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
        -- operation select
        op : in std_logic_vector(3 downto 0);
        -- flags
        zf : out std_logic;
        cf : out std_logic;
        ef : out std_logic;
        gf : out std_logic;
        sf : out std_logic
    );
    end component;
    
    -- control unit specifically designed for this processor
    component ControlUnit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
             clk : in  std_logic;
           reset : in  std_logic;
             irq : in  std_logic;
          ir_msb : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
           flags : in  std_logic_vector(4 downto 0);
           ready : in std_logic;          
        controls : out std_logic_vector(31 downto 0);
           error : out std_logic
    );
    end component;
    
    signal control_lines_i : std_logic_vector(31 downto 0);
    
begin
    -- current implementation does not support different widths for data & address bus
    assert C_ADDR_WIDTH = C_DATA_WIDTH
    report "'C_ADDR_WIDTH' width should equal 'C_DATA_WIDTH'."
    severity FAILURE;

    read_en <= read_en_i;
    write_en <= write_en_i;
    ready_i <= ready;


    -- Program Counter
    PC : Program_Counter
    generic map(
        C_PC_WIDTH => C_ADDR_WIDTH,
         C_PC_STEP => 1
    )
    port map(
               clk => clk,
             reset => reset,
                up => pc_up_i,
                le => pc_le_i,
             pc_in => cpu_bus_i,
            pc_out => pc_i
    );
    
    -- Control Unit
    CU : ControlUnit
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
               clk => clk,
             reset => reset,
               irq => irq_i,
            ir_msb => ir_i(2*C_DATA_WIDTH-1 downto C_DATA_WIDTH),
             ready => ready_i,
             flags => flags_i,
          controls => control_lines_i,
             error => open
    );
    
    irq_i <= irq and global_interrupt_enable_i;
    
    sp_down_i     <= control_lines_i(23);
    sp_up_i       <= control_lines_i(22);
    alu_op_i      <= control_lines_i(21 downto 18);
    reg_swap_i    <= control_lines_i(17);
    cpu_bus_sel_i <= control_lines_i(16 downto 13);
    flags_le_i    <= control_lines_i(12);
    z_le_i        <= control_lines_i(11);
    y_le_i        <= control_lines_i(10);
    reg_file_le_i <= control_lines_i(9);
    mar_le_i     <= control_lines_i(8);
    dobr_le_i    <= control_lines_i(7);
    dibr_le_i    <= control_lines_i(6);
    pc_up_i      <= control_lines_i(5);
    pc_le_i      <= control_lines_i(4);
    ir_hi_le_i   <= control_lines_i(3);
    ir_lo_le_i   <= control_lines_i(2);
    write_en_i   <= control_lines_i(1);
    read_en_i    <= control_lines_i(0);
        
    -- CPU bus control
    with cpu_bus_sel_i select
        cpu_bus_i <=         dibr_i when SFR_DBR,
                                z_i when SFR_Z,
                               pc_i when SFR_PC,
                                 IV when SFR_IV,
                     reg_file_out_i when GP_REG,
                               sp_i when SFR_SP,
      ir_i(C_DATA_WIDTH-1 downto 0) when SFR_IR_L,
                      (others=>'0') when others;

    -- Data In buffer
    DIBR : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => dibr_le_i,
             data_in => data_bus_in,
            data_out => dibr_i
    );
    
    -- Data Out Buffer)
    DOBR : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => dobr_le_i,
             data_in => cpu_bus_i,
            data_out => dobr_i
    );
    data_bus_out <= dobr_i;
    
    -- Memory Address Buffer
    MAR : basic_register
    generic map(
        C_DATA_WIDTH => C_ADDR_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => mar_le_i,
             data_in => cpu_bus_i,
            data_out => mar_i
    );
    address_bus <= mar_i;
    
    -- Instruction Register (16-bit)
    -- Most-significant byte
    IR_MSB : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => ir_hi_le_i,
             data_in => cpu_bus_i,
            data_out => ir_i(2*C_DATA_WIDTH-1 downto C_DATA_WIDTH)
    );
    -- Least-significant byte
    IR_LSB : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => ir_lo_le_i,
             data_in => cpu_bus_i,
            data_out => ir_i(C_DATA_WIDTH-1 downto 0)
    );

    -- ALU Y input
    ALU_Y : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => y_le_i,
             data_in => cpu_bus_i,
            data_out => y_i
    );
    
    -- ALU output (Z register)
    ALU_Z : basic_register
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => z_le_i,
             data_in => alu_out_i,
            data_out => z_i
    );
    
    -- ALU flags register
    ALU_FLAGS : basic_register
    generic map(
        C_DATA_WIDTH => C_NR_FLAGS
    )
    port map(
                 clk => clk,
               reset => reset,
                  le => flags_le_i,
             data_in => alu_flags_i,
            data_out => flags_i
    );
    
    -- ALU
    ALU : ALU8bit
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
         X => cpu_bus_i,
         Y => y_i,
         Z => alu_out_i,
        -- operation select
        op => alu_op_i,
        -- flags
        zf => alu_flags_i(C_ZF),
        cf => alu_flags_i(C_CF),
        ef => alu_flags_i(C_EF),
        gf => alu_flags_i(C_GF),
        sf => alu_flags_i(C_SF)
    );
    
    -- register file register selection decoding
    Rd_i <= destination_reg_field_i;
    with Rd_i select
        reg_file_in_sel_i <= "00000001" when "000",
                             "00000010" when "001",
                             "00000100" when "010",
                             "00001000" when "011",
                             "00010000" when "100",
                             "00100000" when "101",
                             "01000000" when "110",
                             "10000000" when others;
                             
    Rs_i <= destination_reg_field_i when reg_swap_i = '1' else source_reg_field_i;
    with Rs_i select
        reg_file_out_sel_i <= "00000001" when "000",
                              "00000010" when "001",
                              "00000100" when "010",
                              "00001000" when "011",
                              "00010000" when "100",
                              "00100000" when "101",
                              "01000000" when "110",
                              "10000000" when others;
    
    -- register file
    REG_FILE : Register_File
    generic map(
      C_DATA_WIDTH => C_DATA_WIDTH,
         C_NR_REGS => C_NR_REGS
    )
    port map(
               clk => clk,
             reset => reset,
                le => reg_file_le_i,
            in_sel => reg_file_in_sel_i,
           out_sel => reg_file_out_sel_i,
           data_in => cpu_bus_i,
          data_out => reg_file_out_i
    );

    -- Stack pointer
    SP_OFFSET : updown_counter
    generic map(
        C_NR_BITS => 5
    )
    port map(
              clk => clk,
            reset => reset,
               up => sp_up_i,
             down => sp_down_i,
        underflow => open,
         overflow => open,
            count => sp_offset_i
    );
    sp_i <= "101" & sp_offset_i;
    
end Behavioral;
