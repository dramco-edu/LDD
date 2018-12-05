----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: ALU8bit - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  8-bit ALU that supports several logic and arithmetic operations
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library WORK;
use WORK.PROCESSOR_PKG.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU8bit is
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
end ALU8bit;

architecture Behavioral of ALU8bit is
    -- operations defined in processor_pkg
    -- ALU_OP_NOT  
    -- ALU_OP_AND  
    -- ALU_OP_OR   
    -- ALU_OP_XOR  
    -- ALU_OP_ADD  
    -- ALU_OP_CMP  
    -- ALU_OP_RR   
    -- ALU_OP_RL   
    -- ALU_OP_SWAP 

    -- operation results
    signal result_i      : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal not_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal and_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal or_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal xor_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal rr_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal rl_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal swap_result_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    -- help signals
    signal add_in2_i     : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_carry_in_i: std_logic := '0';
    signal add_carry_i   : std_logic := '0';
    signal rl_carry_i    : std_logic := '0';
    signal rr_carry_i    : std_logic := '0';
    
    component ADD is
    generic(
        C_DATA_WIDTH : natural := 4
    );
    port(
                    a : in std_logic_vector((C_DATA_WIDTH-1) downto 0);   -- input var 1
                    b : in std_logic_vector((C_DATA_WIDTH-1) downto 0);   -- input var 2
             carry_in : in std_logic;                                   -- input carry
               result : out std_logic_vector ((C_DATA_WIDTH-1) downto 0); -- alu operation result
            carry_out : out std_logic
        );
    end component;
begin
    
    -- implementation of some operations
    -- and
    and_result_i <= X and Y;
    -- or
    or_result_i <= X or Y;
    -- xor
    xor_result_i <= X xor Y;
    -- not
    not_result_i <= not X;
    -- rr
    rr_result_i <= '0' & X(C_DATA_WIDTH-1 downto 1);
    -- rl
    rl_result_i <= X(C_DATA_WIDTH-2 downto 0) & '0';
    -- swap
    swap_result_i <= X((C_DATA_WIDTH/2)-1 downto 0) & X(C_DATA_WIDTH-1 downto (C_DATA_WIDTH/2)); 
     
    -- adder and sub
    add_in2_i <= not Y when op = ALU_OP_SUB else Y;
    add_carry_in_i <= '1' when op = ALU_OP_SUB else '0';
    
    -- Ripple carry adder instantiation
    ADDER : ADD
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map(
                a => X,
                b => add_in2_i,
         carry_in => add_carry_in_i,
           result => add_result_i,
        carry_out => add_carry_i
    );
    
    -- output
    with op select
        result_i <= not_result_i  when ALU_OP_NOT,
                    and_result_i  when ALU_OP_AND,
                    or_result_i   when ALU_OP_OR,
                    xor_result_i  when ALU_OP_XOR,
                    add_result_i  when ALU_OP_ADD,
                    add_result_i  when ALU_OP_SUB,
                    rr_result_i   when ALU_OP_RR,
                    rl_result_i   when ALU_OP_RL,
                    swap_result_i when ALU_OP_SWAP,
                    X             when others;
    
    Z <= result_i;                    
    
    -- carry flag
    rl_carry_i <= X(C_DATA_WIDTH-1);
    rr_carry_i <= X(0);
    with op select
    cf <= add_carry_i when ALU_OP_ADD,
          not add_carry_i when ALU_OP_SUB,
          rl_carry_i  when ALU_OP_RL,
          rr_carry_i  when ALU_OP_RR,
          '0'         when others;

    -- zero flag
    zf <= '1' when result_i = (result_i'range=>'0') else '0';
    
    -- equal, smaller, greater flag
    ef <= '1' when X=Y else '0';
    sf <= '1' when X<Y else '0';
    gf <= '1' when X>Y else '0';

end Behavioral;
