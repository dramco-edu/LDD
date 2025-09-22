----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
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

-- TODO: use processor_pkg from the work library

entity ALU8bit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
         X : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Y : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
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
    -- ALU_OP_SR   
    -- ALU_OP_SL   
    -- ALU_OP_SWAP 

    -- operation results
    signal result_i      : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal not_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal and_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal or_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal xor_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal sr_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal sl_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal swap_result_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    -- help signals
    signal add_secondary_input_i     : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_carry_in_i: std_logic := '0';
    signal add_carry_i   : std_logic := '0';

    
    -- we use a separate module for the addition/subtraction
    component ADD is
    generic(
        C_DATA_WIDTH : natural := 4
    );
    port(
                    a : in  std_logic_vector((C_DATA_WIDTH-1) downto 0); -- input var 1
                    b : in  std_logic_vector((C_DATA_WIDTH-1) downto 0); -- input var 2
             carry_in : in  std_logic;                                   -- input carry
               result : out std_logic_vector((C_DATA_WIDTH-1) downto 0); -- alu operation result
            carry_out : out std_logic                                    -- carry
        );
    end component;
begin
    
    -- TODO: complete the following lines to perform logical operations
    -- implementation of some operations
    -- and
    and_result_i <= ... ;
    -- or
    or_result_i <= ... ;
    -- xor
    xor_result_i <= ... ;
    -- not
    not_result_i <= ... ;
    -- sr
    sr_result_i <= ... ;
    -- sl
    sl_result_i <= ... ;
    -- swap
    swap_result_i <= ; 
    
    -- TODO: have a look at how this module is instantiated
    -- Ripple carry adder instantiation
    ADDER : ADD
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH -- this will change the default width of the adder to the width specified here
    )
    port map(
                a => X,
                b => add_secondary_input_i,
         carry_in => add_carry_in_i,
           result => add_result_i,
        carry_out => add_carry_i
    );

    -- TODO: change the adder's secondary input and carry in, based on the operation (addition/subtraction)
    -- addition and subtraction
    add_secondary_input_i <= ... ;
    add_carry_in_i <= ... ;
    
    -- TODO: set 'result_i' to a specific operation result based on the selected operation 'op'
    -- result mux:
    
    Z <= result_i;                    
    
    -- TODO: control the flags
    -- carry flag: 1 carry flag for SUB, ADD, RR and RL (based on op)
    --   don't forget that rotate left/right can also produce a carry
    --   you might need some extra signals
    cf <= ... ;

    -- zero flag
    zf <= ... ;
    
    -- equal, smaller, greater flag
    ef <= ... ;
    gf <= ... ;
    sf <= ... ;

end Behavioral;
