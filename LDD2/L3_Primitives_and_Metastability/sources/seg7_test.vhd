----------------------------------------------------------------------------------
-- Institution: KU Leuven
--  Engineer: Geoffrey Ottoy
-- 
-- Module Name: seg7_test - Behavioral
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

entity seg7_test is
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
end seg7_test;

architecture Behavioral of seg7_test is

    signal clk_25MHz    : std_logic := '0';
    signal ring_clk_i   : std_logic := '0'; -- approx. 25,4 MHz
    signal reset_i      : std_logic := '0';
    
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

begin

    an <= "1111" & an_i;
    seg <= seg_i;
    
    reset_i <= not btnCpuReset;

    SYS_CLK : BUFR
    generic map(
        BUFR_DIVIDE => "4",       -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
         SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
    )
    port map(
          O => clk_25MHz, -- 1-bit output: Clock output port
         CE => '1',       -- 1-bit input: Active high, clock enable (Divided modes only)
        CLR => '0',       -- 1-bit input: Active high, asynchronous clear (Divided modes only)
          I => clk        -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
    );
    
    SEG_DRV: driver_7seg_4
    generic map(
         C_F_CLK => 25000000
    )
    port map(
          clk => clk_25MHz,
        reset => reset_i,
         bcd0 => bcd0,
         bcd1 => bcd1,
         bcd2 => bcd2,
         bcd3 => bcd3,
          seg => seg_i,
           an => an_i
    );

    CNT_PROC : process (clk_25MHz) is
        variable cntr : integer range 0 to 99999999 := 0; 
    begin
        if rising_edge(clk_25MHz) then -- (cntr overflow every 4 seconds)
            if cntr = 99999999 then
                cntr := 0;
            else 
                cntr := cntr + 1;
            end if;
        end if;
        -- change bcd inputs every 0.5 seconds
        case cntr is
            when 24999999 =>
                bcd0 <= x"0";
                bcd1 <= x"1";
                bcd2 <= x"2";
                bcd3 <= x"3";
            when 49999999 =>
                bcd0 <= x"4";
                bcd1 <= x"5";
                bcd2 <= x"6";
                bcd3 <= x"7";
            when 74999999 =>
                bcd0 <= x"8";
                bcd1 <= x"9";
                bcd2 <= x"a";
                bcd3 <= x"b";
            when 99999999 =>
                bcd0 <= x"c";
                bcd1 <= x"d";
                bcd2 <= x"e";
                bcd3 <= x"f";
            when others =>
                bcd0 <= bcd0;
                bcd1 <= bcd1;
                bcd2 <= bcd2;
                bcd3 <= bcd3;
        end case;
    end process;

end Behavioral;
