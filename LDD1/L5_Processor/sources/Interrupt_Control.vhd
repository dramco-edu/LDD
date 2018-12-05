----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy, Sylvain Ieri
-- 
-- Module Name: Interrupt_Control - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor Interrupt_Control
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

entity Interrupt_Control is
    port(
               clk : in  std_logic;
             reset : in  std_logic;
          start_ic : in  std_logic;
            end_ic : in  std_logic;
               irq : in  std_logic;
        handle_irq : out std_logic;
         int_cycle : out std_logic
    );
end Interrupt_Control;

architecture Behavioral of Interrupt_Control is
    signal interrupt_cycle_i : std_logic := '0';
    signal start_ic_i : std_logic := '0';
    signal end_ic_i : std_logic := '0';
    signal handle_irq_i : std_logic := '0';
    signal irq_i : std_logic := '0';
begin
    
    start_ic_i <= start_ic;
    end_ic_i <= end_ic;
    irq_i <= irq;

    -- interrupt_cycle_i is '1' between start en end
    IC_PROC : process (reset, clk)
        variable irq_stored : std_logic := '0';
    begin
        if reset = '1' then
            interrupt_cycle_i <= '0';
        elsif rising_edge(clk) then
            if start_ic_i = '1' then
                interrupt_cycle_i <= '1';
            elsif end_ic_i = '1' then
                interrupt_cycle_i <= '0';
            end if;
        end if;
    end process IC_PROC;
    
    -- when an irq comes during the interrupt cycle it is delayed until the next instruction cycle
    HANDLE_INTERRUPT_PROC : process (reset, clk)
        variable irq_stored : std_logic := '0';
    begin
        if reset = '1' then
            handle_irq_i <= '0';
        elsif rising_edge(clk) then
            if interrupt_cycle_i = '0' then
                if irq = '1' then
                    handle_irq_i <= '1';
                elsif irq_stored = '1' then
                    handle_irq_i <= '1';
                    irq_stored := '0';
                end if;
            else -- we are in the interrupt cycle -> 'remember' IRQ until next instruction fetch
                if irq = '1' then
                    irq_stored := '1';
                elsif end_ic_i = '1' then -- going to next instruction fetch
                    handle_irq_i <= '0'; -- interrupt is handled
                end if;
            end if; 
        end if;
    end process HANDLE_INTERRUPT_PROC;
    
    handle_irq <= handle_irq_i;
    int_cycle <= interrupt_cycle_i;

end Behavioral;
