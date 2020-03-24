----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: bcd_ctr_2_clocks_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for a design with bcd_ctr modules clocked on different frequencies
--
--  Report any errors and terminate automatically at the end of the test.
--
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_ctr_2_clocks_tb is
end bcd_ctr_2_clocks_tb;

architecture Behavioral of bcd_ctr_2_clocks_tb is
    
    constant USE_SYNCHRONIZERS : boolean := true; -- set to false and watch the mayhem unfold
	
	constant C_F_FAST_CLK : natural := 50000000;  -- 50.000 MHz
	constant C_F_SLOW_CLK : natural := 18780000;  -- 18.780 MHz
    constant clk_fast_period : time := (1000000000/C_F_FAST_CLK) *1ns;
    constant clk_slow_period : time := (1000000000/C_F_SLOW_CLK) *1ns;
    
    signal reset        : std_logic := '0';
    signal cnt_enable   : std_logic_vector(2 downto 0) := (others=>'0');
    signal clk_fast     : std_logic;
    signal clk_slow     : std_logic;
    
    signal ovf          : std_logic_vector(2 downto 0) := (others=>'0');
    
    signal bcd0         : std_logic_vector(3 downto 0);
    signal bcd1         : std_logic_vector(3 downto 0);
    signal bcd2         : std_logic_vector(3 downto 0);
    
    component bcd_ctr is
    port(
          clk : in  std_logic;
        reset : in  std_logic;
          cnt : in  std_logic;
          ovf : out std_logic;
          bcd : out std_logic_vector(3 downto 0)
    );
    end component bcd_ctr;

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

    CTR0: bcd_ctr
    port map(
          clk => clk_fast,
        reset => reset,
          cnt => cnt_enable(0),
          ovf => ovf(0),
          bcd => bcd0
    );
    
    GEN_SYNC1 : if USE_SYNCHRONIZERS generate
    begin
        S1: sync_fast2slow
        port map(
               reset => reset, 
            clk_fast => clk_fast, 
            clk_slow => clk_slow,
             data_in => ovf(0), 
            data_out => cnt_enable(1)
        );
    end generate;
    
    GEN_NOSYNC1 : if not USE_SYNCHRONIZERS generate
    begin
        cnt_enable(1) <= ovf(0);
    end generate;
    
    CTR1: bcd_ctr
    port map(
          clk => clk_slow,
        reset => reset,
          cnt => cnt_enable(1),
          ovf => ovf(1),
          bcd => bcd1
    );
    
    GEN_SYNC2 : if USE_SYNCHRONIZERS generate
    begin
        S2: sync_slow2fast
        port map(
               reset => reset,
            clk_fast => clk_fast,
             data_in => ovf(1),
            data_out => cnt_enable(2)
        );
    end generate;
    
    GEN_NOSYNC2 : if not USE_SYNCHRONIZERS generate
    begin
        cnt_enable(2) <= ovf(1);
    end generate;
    
    
    CTR2: bcd_ctr
    port map(
          clk => clk_fast,
        reset => reset,
          cnt => cnt_enable(2),
          ovf => open,
          bcd => bcd2
    );

    CLK_FAST_PROC: process
    begin
        clk_fast <= '0';
        wait for clk_fast_period/2;
        clk_fast <= '1';
        wait for clk_fast_period/2;
    end process CLK_FAST_PROC;
    
    CLK_SLOW_PROC: process
    begin
        clk_slow <= '0';
        wait for clk_slow_period/2;
        clk_slow <= '1';
        wait for clk_slow_period/2;
    end process CLK_SLOW_PROC;

    COUNT_PROC: process (clk_fast) is
        variable cntr : integer range 0 to 19 := 0;
    begin
        if rising_edge(clk_fast) then
            if cntr = 19 then
                cntr := 0;
                cnt_enable(0) <= '1';
            else
                cntr := cntr + 1;
                cnt_enable(0) <= '0';
            end if;
        end if;
    end process COUNT_PROC;    
    
    STIM_PROC: process
        variable check_count : integer := 0;
        variable bcd0_i : integer := 0;
        variable bcd1_i : integer := 0;
        variable bcd2_i : integer := 0;
        variable val : integer := 0;
    begin
    
        assert USE_SYNCHRONIZERS report "Simulation start (no synchronizers)" severity NOTE;
        assert not USE_SYNCHRONIZERS report "Simulation start (with synchronizers)" severity NOTE;
    
        while check_count < 200 loop
            wait until cnt_enable(0) = '1';
            check_count := check_count + 1;
            wait until cnt_enable(0) = '0';
            
            if (check_count rem 100) = 0 then
                wait until cnt_enable(2) = '1';
                wait until cnt_enable(2) = '0';
            elsif (check_count rem 10) = 0 then
                wait until cnt_enable(1) = '1';
                wait until cnt_enable(1) = '0';
            end if;
            
            wait for 1 ns;
            
            -- check counter output value
            bcd0_i := to_integer(unsigned(bcd0));
            bcd1_i := to_integer(unsigned(bcd1));
            bcd2_i := to_integer(unsigned(bcd2));
            
            val := bcd2_i * 100 + bcd1_i * 10 + bcd0_i;
            
            assert val = check_count report "Count fail - got " & integer'image(val) & " - expected " & integer'image(check_count) severity WARNING;
        end loop;
        
        assert false report "Simulation ended" severity NOTE;
        
        wait;      
    end process STIM_PROC;
    
end Behavioral;