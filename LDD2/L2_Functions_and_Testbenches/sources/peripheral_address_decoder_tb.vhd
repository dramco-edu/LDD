----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: peripheral_address_decoder_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Test the peripheral_address_decoder module.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity peripheral_address_decoder_tb is
end peripheral_address_decoder_tb;

architecture Behavioral of peripheral_address_decoder_tb is
    
    -- constants
    constant clk_period : time := 10 ns;

    
    -- system clock (not needed because DUT is a combinatorial circuit, but timing can be derived from it)
    signal clk : std_logic := '0';
    
    -- inputs

    
    -- outputs

    
    -- procedure is basically a function that doesn't return anything
    procedure sim_message(msg : string) is 
        variable s : line;
    begin
        write (s, msg);
        writeline (output, s);
    end procedure;
    
    -- convert number (0 to 15) to hex string representation
    function int_to_hex(num: natural) return string is
        variable lut : string(1 to 16) := "0123456789ABCDEF";
    begin
        if num > 15 then
            return "";
        else
            return string'("" & lut(num+1));
        end if;
    end function;
    
    -- convert std_logic_vector to hex string representation
    -- TODO: write function that converts a std_logic_vector to hex string representation
    --       this wil also be a recursive function
    
    -- convert std_logic_vector to binary string representation
    function to_bin_string(vector : std_logic_vector) return string is
    begin
        if vector(vector'high) = '0' then
            if vector'length = 1 then
                return "0";
            else
                return string'("0" & to_bin_string(vector(vector'high-1 downto 0)) ); -- recursive
            end if;
        else
            if vector'length = 1 then
                return "1";
            else
                return string'("1" & to_bin_string(vector(vector'high-1 downto 0)) ); -- recursive
            end if;
        end if;
    end function;
    
    -- component that will be tested
    component peripheral_address_decoder is
        generic(
                  C_BASE_ADDR : std_logic_vector := x"F0"; 
            C_PERI_ADDR_WIDTH : natural := 1
        );
        port(
                     addr : in  std_logic_vector(C_BASE_ADDR'range);
                  read_en : in  std_logic;
                 write_en : in  std_logic;
                addr_peri : out std_logic_vector(C_PERI_ADDR_WIDTH-1 downto 0);
             read_en_peri : out std_logic;
            write_en_peri : out std_logic
        );
    end component;

    --debug information
    type debug_t is (resetting, invalid_addr, peripheral_test, ended);
    signal debug : debug_t;
    
begin

    -- DUT
    -- TODO: instantiate DUT


    CLK_PROC: process
    begin
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
    end process CLK_PROC;

    STIM_PROC: process

    begin
        debug <= resetting;
        wait for clk_period;
        
	-- TODO: write stim process
        
        -- end simulation
        debug <= ended;
        assert false -- will always execute
                report "SIMULATION ENDED"
                severity NOTE;
        
        wait;
            
    end process STIM_PROC;
    
    
end Behavioral;

