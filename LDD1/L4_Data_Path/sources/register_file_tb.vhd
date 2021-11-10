----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: register_file_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the Register_File module.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file_tb is
end register_file_tb;

architecture Behavioral of register_file_tb is
    -- constants
    constant clk_period : time := 10 ns;
    
    constant C_DATA_WIDTH : natural := 8;
    constant C_NR_REGS : natural := 4;
    
    -- inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal le : std_logic := '0';
    signal data_in : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal in_sel : std_logic_vector(C_NR_REGS-1 downto 0) := (others=>'0');
    signal out_sel : std_logic_vector(C_NR_REGS-1 downto 0) := (others=>'0');
     
    -- outputs
    signal data_out :  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    
    -- DUT
    component register_file is
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

begin

    DUT : register_file
    generic map(
       C_DATA_WIDTH => C_DATA_WIDTH,
          C_NR_REGS => C_NR_REGS
    )
    port map(
                clk => clk,
              reset => reset,

                 le => le,
             in_sel => in_sel,
            data_in => data_in,

            out_sel => out_sel,
           data_out => data_out
    );
    
    CLK_PROC: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process CLK_PROC;
    
    STIM_PROC: process
        variable s: line;
    begin
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        
        -- write to register 0
        in_sel <= "0001";
        out_sel <= "0001";
        data_in <= x"DE";
        le <= '1';
        wait for clk_period;
        le <= '0';
        wait until falling_edge(clk);
        assert data_out = x"DE"
            report "Write/read failed (in_sel=out_sel=0001)"
            severity ERROR;
        if data_out = x"DE" then
            write (s, string'("SUCCESS: write register 0."));
            writeline (output, s);
        end if;
        
        -- write to register 1
        in_sel <= "0010";
        out_sel <= "0010";
        data_in <= x"AD";
        le <= '1';
        wait for clk_period;
        le <= '0';
        wait until falling_edge(clk);
        assert data_out = x"AD"
            report "Write/read failed (in_sel=out_sel=0010)"
            severity ERROR;
        if data_out = x"AD" then
            write (s, string'("SUCCESS: write register 1."));
            writeline (output, s);
        end if;
        
        -- write to register 2
        in_sel <= "0100";
        out_sel <= "0100";
        data_in <= x"BE";
        le <= '1';
        wait for clk_period;
        le <= '0';
        wait until falling_edge(clk);
        assert data_out = x"BE"
            report "Write/read failed (in_sel=out_sel=0100)"
            severity ERROR;
        if data_out = x"BE" then
            write (s, string'("SUCCESS: write register 2."));
            writeline (output, s);
        end if;
        
        -- write to register 3
        in_sel <= "1000";
        out_sel <= "1000";
        data_in <= x"EF";
        le <= '1';
        wait for clk_period;
        le <= '0';
        wait until falling_edge(clk);
        assert data_out = x"EF"
            report "Write/read failed (in_sel=out_sel=1000)"
            severity ERROR;
        if data_out = x"EF" then
            write (s, string'("SUCCESS: write register 3."));
            writeline (output, s);
        end if;
        
        -- read register 0
        in_sel <= "0000";
        out_sel <= "0001";
        wait for 2 ns;
        assert data_out = x"DE"
            report "Read failed (out_sel=0001)"
            severity ERROR;
        if data_out = x"DE" then
            write (s, string'("SUCCESS: read register 0."));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        -- read register 1
        out_sel <= "0010";
        wait for 2 ns;
        assert data_out = x"AD"
            report "Read failed (out_sel=0010)"
            severity ERROR;
        if data_out = x"AD" then
            write (s, string'("SUCCESS: read register 1."));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
 
        -- read register 2
        out_sel <= "0100";
        wait for 2 ns;
        assert data_out = x"BE"
            report "Read failed (out_sel=0100)"
            severity ERROR;
        if data_out = x"BE" then
            write (s, string'("SUCCESS: read register 2."));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        -- read register 3
        out_sel <= "1000";
        wait for 2 ns;
        assert data_out = x"EF"
            report "Read failed (out_sel=1000)"
            severity ERROR;
        if data_out = x"EF" then
            write (s, string'("SUCCESS: read register 3."));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        
        -- read register 3
        wait for 2 ns;
        assert data_out = x"00"
            report "Reset failed."
            severity ERROR;
        if data_out = x"00" then
            write (s, string'("SUCCESS: reset."));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
               
        -- End simulation       
        assert false
            report "Simulation ended."
            severity NOTE;
        
        wait;
    end process STIM_PROC;
    
end Behavioral;
