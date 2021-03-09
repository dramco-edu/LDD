----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: rotate_lr_par_load_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the lr_shift_par_load module.
--
--  Report any errors and terminate automatically at the end of the test.
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

library STD;
use STD.TEXTIO.ALL;

entity rotate_lr_par_load_tb is
end rotate_lr_par_load_tb;

architecture Behavioral of rotate_lr_par_load_tb is
        
    constant C_F_CLK : natural := 100000000; -- 100 MHz
    constant clk_period : time := (1000000000/C_F_CLK) *1ns;
    constant C_REG_WIDTH : natural := 4;     -- nr of bits in the register
    
    -- uut inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal left : std_logic := '0';
    signal right : std_logic := '0';
    signal le : std_logic := '0';
    signal par_in : std_logic_vector(C_REG_WIDTH-1 downto 0) := (others=>'0');

    -- uut outputs
    signal par_out : std_logic_vector(C_REG_WIDTH-1 downto 0);
        
    component rotate_lr_par_load is
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

    procedure sim_message(msg : string) is 
        variable s : line;
    begin
        write (s, msg);
        writeline (output, s);
    end procedure;

begin

    UUT : rotate_lr_par_load
    generic map(
       C_REG_WIDTH => C_REG_WIDTH
    )
    port map(
          reset => reset,
            clk => clk,
           left => left,
          right => right,
             le => le,
         par_in => par_in,
        par_out => par_out
    );

    CLK_PROC: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process CLK_PROC;
    
    STIM_PROC: process
        variable sim_error : boolean := false;
    begin
    
        sim_message("Power-on reset.");
        
        wait for clk_period;
        assert par_out = x"0"
            report "wrong output value (power-on)"
            severity WARNING;
        if par_out = x"0" then
            sim_message("SUCCESS");
        end if;
        sim_message("");
        
        -- test load
        sim_message("Parallel load test.");
        par_in <= x"3";
        wait until falling_edge(clk);
        le <= '1';
        wait for clk_period;
        le <= '0';
        assert par_out = x"3"
            report "wrong output value (load)"
            severity ERROR;
        if par_out = x"3" then
            sim_message("SUCCESS");
        end if;
        sim_message("");
        
        wait for clk_period;
        wait until falling_edge(clk);
        
        -- test left shift
        sim_message("Shift left test.");
        left <= '1';
        wait for clk_period;
        assert par_out = x"6"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"6") then
            sim_error := true;
        end if;
        wait for clk_period;
        assert par_out = x"C"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"C") then
            sim_error := true;
        end if;
        wait for clk_period;
        left <= '0';
        assert par_out = x"9"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"9") then
            sim_error := true;
        end if;
        if not sim_error then
            sim_message("SUCCESS");
        end if;
        sim_message("");
        sim_error := false;
        
        wait for clk_period;
        wait until falling_edge(clk);
       
        -- test right shift
        sim_message("Shift right test.");
        right <= '1';
        wait for clk_period;
        assert par_out = x"C"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"C") then
            sim_error := true;
        end if;
        wait for clk_period;
        assert par_out = x"6"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"6") then
            sim_error := true;
        end if;
        wait for clk_period;
        assert par_out = x"3"
            report "wrong output value (shift left)"
            severity ERROR;
        if not(par_out = x"3") then
            sim_error := true;
        end if;
        if not sim_error then
            sim_message("SUCCESS");
        end if;
        sim_message("");
        sim_error := false;
        
        -- test priority
        sim_message("Priority test.");
        le <= '1';
        par_in <= x"5";
        wait for clk_period;
        assert par_out = x"5"
            report "wrong output value (load has priority)"
            severity ERROR;
        if par_out = x"5" then
            sim_message("SUCCESS");
        end if;
        sim_message("");
                    
        -- test async reset
        sim_message("Async reset test.");
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        assert par_out = x"0"
            report "Reset failed"
            severity error;
       if par_out = x"0" then
            sim_message("SUCCESS");
        end if;
        sim_message("");
         
        -- the end
        assert false
            report "SIMULATION ENDED"
            severity NOTE;
        wait;

            
    end process STIM_PROC;
end Behavioral;

