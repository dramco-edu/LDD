----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: top - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Top entity for connecting the ALU8bit module to the NEXYS 4 peripherals.
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

entity top is
    port(
        
                 sw : in    std_logic_vector(15 downto 0);
                led : out   std_logic_vector(15 downto 0)
    );
end top;

architecture LDD1 of top is

    -- constants
    constant C_DATA_WIDTH : natural := 8;

    -- inputs and outputs
    signal leds_i : std_logic_vector(15 downto 0) := (others=>'0');
    signal sw_i : std_logic_vector(15 downto 0) := (others=>'0');

    -- ALU flags
    signal zero_flag_i : std_logic := '0';
    signal carry_flag_i : std_logic := '0';
    signal equal_flag_i : std_logic := '0';
    signal greater_flag_i : std_logic := '0';
    signal smaller_flag_i : std_logic := '0';
    
    -- ALU operands
    signal x_operand_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal y_operand_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    --ALU result
    signal z_result_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    
    -- ALU operation select
    signal operation_i : std_logic_vector(3 downto 0) := (others=>'0');

    
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

begin

    -- Connections with external pins
    sw_i <= sw; -- dip switches
    led <= leds_i; -- leds
    
    -- Connect switches with ALU inputs
    x_operand_i <= sw_i(3 downto 0) & "0000";
    y_operand_i <= sw_i(7 downto 4) & "0000";
    operation_i <= sw_i(15 downto 12);
    
    -- Connect ALU outputs to LEDs
    leds_i <= zero_flag_i & carry_flag_i & equal_flag_i & greater_flag_i & smaller_flag_i & "000" & z_result_i;

    -- ALU instance
    ALU_INST : ALU8bit
    generic map(
           C_DATA_WIDTH => 8
    )
    port map(
             X => x_operand_i,
             Y => y_operand_i,
             Z => z_result_i,
            -- operation select
            op => operation_i,
            -- flags
            zf => zero_flag_i,
            cf => carry_flag_i,
            ef => equal_flag_i,
            gf => greater_flag_i,
            sf => smaller_flag_i
    );

end LDD1;
