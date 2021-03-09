----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: rotate_lr_par_load - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  An n-bit register (parallel in and out) with left and right shift
--  functionality (circular).
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

entity rotate_lr_par_load is
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
end rotate_lr_par_load;

architecture Behavioral of rotate_lr_par_load is

    signal reg_i : std_logic_vector(C_REG_WIDTH-1 downto 0) := (others=>'0');

begin

    -- TODO: Write a process that implements the correct behaviour for reg_i.
    --   This should be a good refresher of your knowledge of last year.
    
    par_out <= reg_i;

end Behavioral;
