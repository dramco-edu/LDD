----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: ALU_tb - Behavioral
-- Course Name: Lab Digital Design
-- Exercise: 2 -- ALU
-- Description: 
--  test the alu through the different opcode and flag output possible.
--  testing value only work for 8 bit width 
--
--  report error and terminate automatically at the end of the test time
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

entity ALU_tb is
end ALU_tb;

architecture Behavioral of ALU_tb is
    constant C_DATA_WIDTH : natural := 8;
    
    -- inputs
    signal  X : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal  Y : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal op : std_logic_vector(3 downto 0) := (others=>'0');
    
    -- outputs
    signal  Z : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    signal zf : std_logic;
    signal cf : std_logic;
    signal ef : std_logic;
    signal gf : std_logic;
    signal sf : std_logic;

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


    component ALU8bit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
         X : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Y : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Z : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
        -- operation select
        op : in std_logic_vector(3 downto 0);
        -- flags
        zf : out std_logic;
        cf : out std_logic;
        ef : out std_logic;
        gf : out std_logic;
        sf : out std_logic
    );
    end component;
   
       --debug information
    type debug_t is (resetting, paused, OP_NOT,  OP_AND , OP_OR   , OP_XOR, OP_ADD_NC, OP_ADD_NC2, OP_ADD_C , OP_SUB_NC, OP_SUB_C , OP_CMP_EQ, OP_CMP_ST, 
        OP_CMP_GT, OP_RR_C, OP_RR_NC, OP_RL_C, OP_RL_NC, OP_SWAP, ended);
    signal debug : debug_t;
    
begin

    DUT : ALU8bit
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
         X => X,
         Y => Y,
         Z => Z,
        op => op,
        zf => zf,
        cf => cf,
        ef => ef,
        gf => gf,
        sf => sf
    );
    
    STIM_PROC: process
    	variable s : line;
    begin  
        -- not 
        wait for 10 ns;
        debug <= OP_NOT;
        X <= x"65";
        Y <= x"56";
        op <= ALU_OP_NOT;
        wait for 1 ns;
        assert Z = x"9A"
            report "NOT failed (result)"
            severity ERROR;
        if (Z = x"9A") then
            write (s, string'("SUCCESS: NOT."));
            writeline (output, s);
        end if;
    
        -- and
        wait for 10 ns;
        debug <= OP_AND;
        X <= x"65";
        Y <= x"56";
        op <= ALU_OP_AND;
        wait for 1 ns;
        assert Z = x"44"
            report "AND failed (result)"
            severity ERROR;
        if (Z = x"44") then
            write (s, string'("SUCCESS: AND."));
            writeline (output, s);
        end if;
                
        -- or
        wait for 10 ns;
        debug <= OP_OR;
        X <= x"65";
        Y <= x"56";
        op <= ALU_OP_OR;
        wait for 1 ns;
        assert Z = x"77"
            report "OR failed (result)"
            severity ERROR;
        if (Z = x"77") then
            write (s, string'("SUCCESS: OR."));
            writeline (output, s);
        end if;
        
        -- xor
        wait for 10 ns;
        debug <= OP_XOR;
        X <= x"65";
        Y <= x"56";
        op <= ALU_OP_XOR;
        wait for 1 ns;
        assert Z = x"33"
            report "XOR failed (result)"
            severity ERROR;
        if (Z = x"33") then
            write (s, string'("SUCCESS: XOR."));
            writeline (output, s);
        end if;
        
        -- add (no carry)
        wait for 10 ns;
        debug <= OP_ADD_NC;
        X <= x"65";
        Y <= x"56";
        op <= ALU_OP_ADD;
        wait for 1 ns;
        assert Z = x"BB"
            report "ADD without carry failed (result)"
            severity ERROR;
        assert cf = '0'
            report "ADD without carry failed (cf)"
            severity ERROR;
        assert zf = '0'
            report "ADD without carry failed (zf)"
            severity ERROR;
        if (Z = x"BB") and (cf = '0') and (zf = '0') then
            write (s, string'("SUCCESS: ADD 1."));
            writeline (output, s);
        end if;
                
        -- add (no carry)
        wait for 10 ns;
        debug <= OP_ADD_NC2;
        X <= x"01";
        Y <= x"01";
        op <= ALU_OP_ADD;
        wait for 1 ns;
        assert Z = x"02"
            report "ADD without carry 2 failed (result)"
            severity ERROR;
        assert cf = '0'
            report "ADD without carry 2 failed (cf)"
            severity ERROR;
        assert zf = '0'
            report "ADD without carry 2 failed (zf)"
            severity ERROR;
        if (Z = x"02") and (cf = '0') and (zf = '0') then
            write (s, string'("SUCCESS: ADD 2."));
            writeline (output, s);
        end if;
        
        -- add (carry)
        wait for 10 ns;
        debug <= OP_ADD_C;
        X <= x"01";
        Y <= x"FF";
        op<= ALU_OP_ADD;
        wait for 1 ns;
        assert Z = x"00"
            report "ADD with carry failed (result)"
            severity ERROR;
        assert cf = '1'
            report "ADD with carry failed (cf)"
            severity ERROR;
        assert zf = '1'
            report "ADD with carry failed (zf)"
            severity ERROR;
         if (Z = x"00") and (cf = '1') and (zf = '1') then
            write (s, string'("SUCCESS: ADD 3."));
            writeline (output, s);
        end if;
        
        -- sub (carry)   
        wait for 10 ns;
        debug <= OP_SUB_C;
        X <= x"14";
        Y <= x"1D";
        op<= ALU_OP_SUB;
        wait for 1 ns;
        assert Z = x"F7"
            report "SUB with carry failed (result)"
            severity ERROR;
        assert cf = '1'
            report "SUB with carry failed (cf)"
            severity ERROR;
        assert zf = '0'
            report "SUB with carry failed (zf)"
            severity ERROR;
        if (Z = x"F7") and (cf = '1') and (zf = '0') then
            write (s, string'("SUCCESS: SUB 1."));
            writeline (output, s);
        end if;
            
       -- sub (no carry)
        wait for 10 ns;
        debug <= OP_SUB_NC;
        X <= x"07";
        Y <= x"07";
        op <= ALU_OP_SUB;
        wait for 1 ns;
        assert Z = x"00"
            report "SUB without carry failed (result)"
            severity ERROR;
        assert cf = '0'
            report "SUB without carry failed (cf)"
            severity ERROR;
        assert zf = '1'
            report "SUB without carry failed (zf)"
            severity ERROR;
         if (Z = x"00") and (cf = '0') and (zf = '1') then
            write (s, string'("SUCCESS: SUB 2."));
            writeline (output, s);
        end if;   
                        
        -- cmp (equal)
        wait for 10 ns;
        debug <= OP_CMP_EQ;
        X <= x"56";
        Y <= x"56";
        op <= ALU_OP_CMP;
        wait for 1 ns;
        assert ef = '1'
            report "CMP equal failed (ef)"
            severity ERROR;
        assert sf = '0'
            report "CMP equal failed (sf)"
            severity ERROR;   
        assert gf = '0'
            report "CMP equal failed (gf)"
            severity ERROR;  
        if (ef = '1') and (sf = '0') and (gf = '0') then
            write (s, string'("SUCCESS: CMP equal."));
            writeline (output, s);
        end if; 
                                 
        -- cmp (smaller)
        wait for 10 ns;
        debug <= OP_CMP_ST;
        X <= x"53";
        Y <= x"56";
        op <= ALU_OP_CMP;
        wait for 1 ns;
        assert ef = '0'
            report "CMP lower failed (ef)"
            severity ERROR;
        assert sf = '1'
            report "CMP lower failed (sf)"
            severity ERROR;   
        assert gf = '0'
            report "CMP lower failed (gf)"
            severity ERROR;
        if (ef = '0') and (sf = '1') and (gf = '0') then
            write (s, string'("SUCCESS: CMP smaller."));
            writeline (output, s);
        end if;
                                 
        -- cmp (greater)
        wait for 10 ns;
        debug <= OP_CMP_GT;
        X <= x"56";
        Y <= x"53";
        op <= ALU_OP_CMP;
        wait for 1 ns;
        assert ef = '0'
            report "CMP greater failed (ef)"
            severity ERROR;
        assert sf = '0'
            report "CMP greater failed (sf)"
            severity ERROR;   
        assert gf = '1'
            report "CMP greater failed (gf)"
            severity ERROR;
        if (ef = '0') and (sf = '0') and (gf = '1') then
            write (s, string'("SUCCESS: CMP greater."));
            writeline (output, s);
        end if;
        
        -- rr carry
        wait for 10 ns;
        debug <= OP_RR_C;
        X <= x"D7";
        Y <= x"FF";
        op <= ALU_OP_RR;
        wait for 1 ns;
        assert Z = x"6B"
           report "RR with carry failed (result)"
           severity ERROR;
        assert cf = '1'
            report "RR with carry failed (cf)"
            severity ERROR;
        if (Z = x"6B") and (zf = '0') and (cf = '1') then
            write (s, string'("SUCCESS: RR 1."));
            writeline (output, s);
        end if;
                    
        -- rr no carry
        wait for 10 ns;
        debug <= OP_RR_NC;
        X <= x"D6";
        Y <= x"FF";
        op <= ALU_OP_RR;
        wait for 1 ns;
        assert Z = x"6B"
           report "RR without carry failed (result)"
           severity ERROR; 
        assert cf = '0'
            report "RR without carry failed (cf)"
            severity ERROR;
        if (Z = x"6B") and (zf = '0') and (cf = '0') then
            write (s, string'("SUCCESS: RR 2."));
            writeline (output, s);
        end if;
                    
        -- rl carry
        wait for 10 ns;
        debug <= OP_Rl_C;
        X <= x"D7";
        Y <= x"FF";
        op <= ALU_OP_RL;
        wait for 1 ns;
        assert Z = x"AE"
           report "RL with carry failed (result)"
           severity ERROR;
        assert cf = '1'
            report "RL with carry failed (cf)"
            severity ERROR;
        if (Z = x"AE") and (zf = '0') and (cf = '1') then
            write (s, string'("SUCCESS: RL 1."));
            writeline (output, s);
        end if;
                   
        -- rl no carry
        wait for 10 ns;
        debug <= OP_RL_NC;
        X <= x"57";
        Y <= x"FF";
        op <= ALU_OP_RL;
        wait for 1 ns;
        assert Z = x"AE"
           report "RL without carry failed (result)"
           severity ERROR;
        assert cf = '0'
            report "RL without carry failed (cf)"
            severity ERROR;
        if (Z = x"AE") and (zf = '0') and (cf = '0') then
            write (s, string'("SUCCESS: RL 2."));
            writeline (output, s);
        end if;
                    
        -- Swap
        wait for 10 ns;
        debug <= OP_SWAP;
        X <= x"D7";
        Y <= x"FF";
        op <= ALU_OP_SWAP;
        wait for 1 ns;
        assert Z = x"7D"
           report "SWAP failed (result)"
           severity ERROR;
        if (Z = x"7D") and (zf = '0') then
            write (s, string'("SUCCESS: SWAP."));
            writeline (output, s);
        end if;
        
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

