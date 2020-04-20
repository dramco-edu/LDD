----------------------------------------------------------------------------------
-- Institution: KU Leuven
--  Engineer: Geoffrey Ottoy
-- 
-- Module Name: top - Behavioral
-- Course Name: Lab Digital Design
--
--
-- Description: 
--  Top design for the project
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port(
	-- clock input (100 MHz crystal)
                clk : in  std_logic;
    	-- ring oscillator output
           ring_clk : out std_logic;
        -- reset button
        btnCpuReset : in  std_logic;
        -- ring oscillator enable
                 sw : in  std_logic_vector(0 downto 0);
        -- 7 segment pins
                seg : out std_logic_vector(6 downto 0);
                 an : out std_logic_vector(7 downto 0)
    );
end top;

architecture Behavioral of top is

    signal clk_50MHz    : std_logic := '0';
    signal ring_clk_i   : std_logic := '0'; -- approx. 25,4 MHz
    signal reset_i      : std_logic := '0';
    
    signal cnt_i        : std_logic := '0';
    signal ovf1_a       : std_logic := '0';
    signal ovf1_b       : std_logic := '0';
    signal ovf2_a       : std_logic := '0';
    signal ovf2_b       : std_logic := '0';
    signal ovf3         : std_logic := '0';
    
    signal bcd0         : std_logic_vector(3 downto 0) := (others=>'0');
    signal bcd1         : std_logic_vector(3 downto 0) := (others=>'0');
    signal bcd2         : std_logic_vector(3 downto 0) := (others=>'0');
    signal bcd3         : std_logic_vector(3 downto 0) := (others=>'0');

    signal an_i         : std_logic_vector(3 downto 0) := (others=>'0');
    signal seg_i        : std_logic_vector(6 downto 0) := (others=>'0');

    component driver_7seg_4 is
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
    end component driver_7seg_4;

    component bcd_ctr is
    port(
          clk : in  std_logic;
        reset : in  std_logic;
          cnt : in  std_logic;
          ovf : out std_logic;
          bcd : out std_logic_vector(3 downto 0)
    );
    end component bcd_ctr;

    component ring_oscillator is
    port(
         nEnable : in  std_logic;
         clk_out : out std_logic
    );
    end component ring_oscillator;

    component sync_fast2slow is
    port(
           reset : in  std_logic;
        clk_fast : in  std_logic;
        clk_slow : in  std_logic; -- slow clk
         data_in : in  std_logic;
        data_out : out std_logic
    );
    end component sync_fast2slow;
    
    component sync_slow2fast is
    port(
           reset : in  std_logic;
        clk_fast : in  std_logic;
         data_in : in  std_logic;
        data_out : out std_logic
    );
    end component sync_slow2fast;

begin

    an <= "1111" & an_i;
    seg <= seg_i;
    
    reset_i <= not btnCpuReset;

    ASYNC_CLK : ring_oscillator
    port map(
         nEnable => sw(0),
         clk_out => ring_clk_i
    );

    ring_clk <= ring_clk_i;

    SYS_CLK : BUFR
    generic map(
        BUFR_DIVIDE => "2",       -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
         SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
    )
    port map(
          O => clk_50MHz, -- 1-bit output: Clock output port
         CE => '1',       -- 1-bit input: Active high, clock enable (Divided modes only)
        CLR => '0',       -- 1-bit input: Active high, asynchronous clear (Divided modes only)
          I => clk        -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
    );
    
    SEG_DRV: driver_7seg_4
    generic map(
         C_F_CLK => 50000000 -- ring oscillator clock frequency
    )
    port map(
          clk => clk_50MHz,
        reset => reset_i,
         bcd0 => bcd0,
         bcd1 => bcd1,
         bcd2 => bcd2,
         bcd3 => bcd3,
          seg => seg_i,
           an => an_i
    );

    CNT_PROC : process (clk_50MHz) is
        variable cntr : integer range 0 to 24999999 := 0; 
    begin
        if rising_edge(clk_50MHz) then
            if cntr = 24999999 then
                cntr := 0;
                cnt_i <= '1';
            else
                cntr := cntr + 1;
                cnt_i <= '0';
            end if;
        end if;
    end process;

    CTR0: bcd_ctr
    port map(
          clk => clk_50MHz,
        reset => reset_i,
          cnt => cnt_i,
          ovf => ovf1_a,
          bcd => bcd0
    );
    
    -- 50 MHz to approx 25.4 MHz
    SYNC1: sync_fast2slow
    port map(
           reset => reset_i,
        clk_fast => clk_50MHz,
        clk_slow => ring_clk_i,
         data_in => ovf1_a,
        data_out => ovf1_b
    );
    
    CTR1: bcd_ctr
    port map(
          clk => ring_clk_i,
        reset => reset_i,
          cnt => ovf1_b,
          ovf => ovf2_a,
          bcd => bcd1
    );
    
    -- approx 25.4 MHz to 50 MHz
    SYNC2: sync_slow2fast
    port map(
           reset => reset_i,
        clk_fast => clk_50MHz,
         data_in => ovf2_a,
        data_out => ovf2_b
    );
    
    CTR2: bcd_ctr
    port map(
          clk => clk_50MHz,
        reset => reset_i,
          cnt => ovf2_b,
          ovf => ovf3,
          bcd => bcd2
    );
    
    CTR3: bcd_ctr
    port map(
          clk => clk_50MHz,
        reset => reset_i,
          cnt => ovf3,
          ovf => open,
          bcd => bcd3
    );


end Behavioral;
