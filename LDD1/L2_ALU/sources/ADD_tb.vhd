----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri, Geoffrey Ottoy
-- 
-- Module Name: ADD_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the ripple carry adder.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Enables text output
use STD.textio.all;
use IEEE.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--contain alu opcode 
--library WORK;
--use WORK.PROCESSOR_PKG.ALL;   --can't be used for post-synthesis simulation due to a bug in vivado software

entity ADD_tb is
end ADD_tb;

architecture Behavioral of ADD_tb is
    constant C_DATA_WIDTH : natural := 4;
    
    -- inputs
    signal a : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal b : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal carry_in : std_logic := '0';
    
    -- outputs
    signal result : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    signal carry_out : std_logic;

    -- alu operation selection need to correspond by the one, in work pakage
    constant ALU_OP_NOT  : std_logic_vector(3 downto 0) := "0001";
    constant ALU_OP_AND  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OP_OR   : std_logic_vector(3 downto 0) := "0011";
    constant ALU_OP_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_OP_ADD  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_OP_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_OP_CMP  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_OP_RR   : std_logic_vector(3 downto 0) := "1000";
    constant ALU_OP_RL   : std_logic_vector(3 downto 0) := "1001";
    constant ALU_OP_SWAP : std_logic_vector(3 downto 0) := "1010";


    component ADD is
    generic(
        C_DATA_WIDTH : natural := 4
    );
    port(
                a : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);   -- input var 1
                b : in  std_logic_vector((C_DATA_WIDTH-1) downto 0);   -- input var 2
         carry_in : in  std_logic;                                   -- input carry
           result : out std_logic_vector ((C_DATA_WIDTH-1) downto 0); -- alu operation result
        carry_out : out std_logic
    );
    end component;
   
       --debug information
    type debug_t is (reseting, paused, ADD_NC, ADD_NC2, ADD_C, FULL, ended);
    signal debug : debug_t;
    
begin

    DUT : ADD
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                a => a,
                b => b,
         carry_in => carry_in,
           result => result,
        carry_out => carry_out
    );
    
    STIM_PROC: process
        variable s : line;
        variable result_v : std_logic_vector(C_DATA_WIDTH downto 0);
    begin
    
        -- addition (no carry)
        wait for 10 ns;
        debug <= ADD_NC;
        a <= x"3";
        b <= x"1";
        wait for 1 ns;
        assert result = x"4"
            report "ADD without carry failed (result)"
            severity FAILURE;
        assert carry_out = '0'
            report "ADD without carry failed (carry_out)"
            severity FAILURE;
        if (result = x"4") and (carry_out = '0') then
            write (s, string'("SUCCESS: ADD without carry."));
            writeline (output, s);
        end if;
    
        -- addition with carry in (no carry)
        wait for 10 ns;
        debug <= ADD_NC2;
        carry_in <= '1';
        wait for 1 ns;
        assert result = x"5"
            report "ADD+carry_in without carry failed (result)"
            severity FAILURE;
        assert carry_out = '0'
            report "ADD+carry_in without carry failed (carry_out)"
            severity FAILURE;
        if (result = x"5") and (carry_out = '0') then
            write (s, string'("SUCCESS: ADD+carry_in without carry."));
            writeline (output, s);
        end if;
            
        -- add (no carry)
        wait for 10 ns;
        debug <= ADD_C;
        a <= x"7";
        b <= x"8";
        wait for 1 ns;
        assert result = x"0"
            report "ADD with carry failed (result)"
            severity FAILURE;
        assert carry_out = '1'
            report "ADD with carry failed (carry_out)"
            severity FAILURE; 
        if (result = x"0") and (carry_out = '1') then
            write (s, string'("SUCCESS: ADD with carry."));
            writeline (output, s);
        end if;     
        
        -- full range test
        wait for 10 ns;
        debug <= FULL;
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                --  without carry in
                carry_in <= '0';
                a <= std_logic_vector(to_unsigned(i, C_DATA_WIDTH));
                b <= std_logic_vector(to_unsigned(j, C_DATA_WIDTH));
                result_v := std_logic_vector(to_unsigned((i+j), C_DATA_WIDTH+1));
                wait for 1 ns;
                assert result = result_v(C_DATA_WIDTH-1 downto 0)
                    report "Full test failed (result)"
                    severity FAILURE;
                assert carry_out = result_v(C_DATA_WIDTH)
                    report "Full test failed (carry_out)"
                    severity FAILURE; 
            
                --  with carry in
                carry_in <= '1';
                a <= std_logic_vector(to_unsigned(i, C_DATA_WIDTH));
                b <= std_logic_vector(to_unsigned(j, C_DATA_WIDTH));
                result_v := std_logic_vector(to_unsigned((i+j+1), C_DATA_WIDTH+1));
                wait for 1 ns;
                assert result = result_v(C_DATA_WIDTH-1 downto 0)
                    report "Full test failed (result)"
                    severity FAILURE;
                assert carry_out = result_v(C_DATA_WIDTH)
                    report "Full test failed (carry_out)"
                    severity FAILURE; 
            end loop;
        end loop; 
        
        -- end simulation           
        wait for 10 ns;
        debug <= ended;
        wait for 10 ns;
        assert false
            report "SIMULATION ENDED"
            severity NOTE;
        wait;
    end process;

end Behavioral;
