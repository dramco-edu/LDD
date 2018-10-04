----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: top - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  Top entity for the Digital Design 2 lab exercise on manual control
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
                clk : in  std_logic;
        btnCpuReset : in  std_logic;
        
                 sw : in  std_logic_vector(15 downto 0);
               btnC : in  std_logic; -- lr_shift_par_load le
               btnL : in  std_logic; -- lr_shift_par_load left
         bouncy_btn : in  std_logic; -- lr_shift_par_load right

                led : out std_logic_vector(15 downto 0)
    );
end top;

architecture Behavioral of top is
    constant C_NR_BTNS    : natural := 3;
    constant C_NR_SW      : natural := 16;
    constant C_NR_LEDS    : natural := 16;
    constant C_F_CLK      : natural := 100000000; -- Hz

    signal clk_i : std_logic := '0';
    signal reset_i : std_logic := '0';
    
    signal leds_i : std_logic_vector(C_NR_LEDS-1 downto 0) := (others=>'0');
    signal sw_i : std_logic_vector(C_NR_SW-1 downto 0) := (others=>'0');
    
    signal left_i : std_logic := '0';
    signal right_i : std_logic := '0';
    signal le_i : std_logic := '0';
    
    component lr_shift_par_load is
    generic(
        C_REG_WIDTH : natural := 8
    );
    port(
          reset : in  STD_LOGIC;
            clk : in  STD_LOGIC;
           left : in  STD_LOGIC;
          right : in  STD_LOGIC;
             le : in  STD_LOGIC;
         par_in : in  STD_LOGIC_VECTOR(C_REG_WIDTH-1 downto 0);
        par_out : out STD_LOGIC_VECTOR(C_REG_WIDTH-1 downto 0)
    );
    end component;
    
begin
    -- connections with external pins
    sw_i <= sw; -- dip switches
    led <= leds_i; -- leds
  
    -- processor reset
    reset_i <= not btnCpuReset;

    -- map manual inputs to lr_shift_par_load control inputs    
    left_i <= btnL;
    right_i <= bouncy_btn;
    le_i <= btnC;

    -- clock (no buffer or divider for now)
    CLOCK_DIV : BUFR
    generic map (
       BUFR_DIVIDE => "BYPASS",      -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
       SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
    )
    port map (
       O => clk_i,     -- 1-bit output: Clock output port
       CE => '1',      -- 1-bit input: Active high, clock enable (Divided modes only)
       CLR => '0',     -- 1-bit input: Active high, asynchronous clear (Divided modes only)
       I => clk        -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
    );

    -- Shift register
    SR_INST : lr_shift_par_load
    generic map(
           C_REG_WIDTH => C_NR_LEDS
    )
    port map(
              reset => reset_i,
                clk => clk_i,
               left => left_i,
              right => right_i,
                 le => le_i,
             par_in => sw_i,
            par_out => leds_i
    ); 

end Behavioral;
