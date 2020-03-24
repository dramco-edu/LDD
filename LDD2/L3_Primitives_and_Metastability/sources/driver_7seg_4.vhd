----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: driver_7seg_4 - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  The driver_7seg_4 can be used to drive 4 7-segment displays.
--  TODO (students): check the TODO below
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity driver_7seg_4 is
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
end driver_7seg_4;

architecture Behavioral of driver_7seg_4 is
    constant C_F_REFRESH         : natural := 400;
    constant C_REFRESH_COUNT_MAX : integer := (C_F_CLK / C_F_REFRESH) - 1;
   
    signal pulse_refresh_i  : std_logic := '0';
    signal select_cntr_i    : std_logic_vector(1 downto 0) := "00";
    signal an_i             : std_logic_vector(3 downto 0) := "0000";
    signal bcd_i            : std_logic_vector(3 downto 0) := "0000";
    signal seg_i            : std_logic_vector(6 downto 0) := "0000000";
begin

    REFRESH_CLK_PROC: process(clk, reset) is
        variable cntr_i : integer range 0 to C_REFRESH_COUNT_MAX := 0;
    begin
        if reset='1' then
            cntr_i := 0;
            pulse_refresh_i <= '0';
        elsif rising_edge(clk) then
            if cntr_i=C_REFRESH_COUNT_MAX then
                cntr_i := 0;
                pulse_refresh_i <= '1';
            else
                cntr_i := cntr_i + 1;
                pulse_refresh_i <= '0';
            end if;
        end if;
    end process REFRESH_CLK_PROC;
    
    SELECT_CNT_PROC : process(clk, reset) is
    begin
        if reset='1' then
            select_cntr_i <= "00";
        elsif rising_edge(clk) then
            if pulse_refresh_i = '1' then
                select_cntr_i <= select_cntr_i + '1';
            end if;
        end if;
    end process SELECT_CNT_PROC;
    
    an <= an_i;
    with select_cntr_i select
        an_i <= "1110" when "00",
                "1101" when "01",
                "1011" when "10",
                "0111" when "11",
                "1111" when others;
    
    with select_cntr_i select
        bcd_i <= bcd0 when "00",
                 bcd1 when "01",
                 bcd2 when "10",
                 bcd3 when "11",
                 "1111" when others;
    
    seg <= not seg_i;
    
    -- TODO: set INIT string for each of the 7 LUT4's

    SEG_A : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(0), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );
    
    SEG_B : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(1), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );

    SEG_C : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(2), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );

    SEG_D : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(3), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );

    SEG_E : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(4), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );
    
    SEG_F : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(5), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );
    
    SEG_G : LUT4
    generic map (
       INIT => X"")
    port map (
        O => seg_i(6), -- LUT general output
       I0 => bcd_i(0), -- LUT input
       I1 => bcd_i(1), -- LUT input
       I2 => bcd_i(2), -- LUT input
       I3 => bcd_i(3)  -- LUT input
    );
end Behavioral;
