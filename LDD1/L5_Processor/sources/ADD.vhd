----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: ADD - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  n-bit ripple carry adder
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity ADD is
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
end entity;

architecture LDO_I of ADD is
	-- signals
	signal carry_sig : std_logic_vector(C_DATA_WIDTH downto 0) := (others=>'0');
	
	-- components
	COMPONENT FA1B 
      PORT(
          a      : IN STD_LOGIC;
          b      : IN STD_LOGIC;
          c_in   : IN STD_LOGIC;
          sum    : OUT STD_LOGIC;
          c_out  : OUT STD_LOGIC);
   END COMPONENT;

begin
	carry_sig(0) <= carry_in;

	RIPPLE_CARRY_ADDER: for i in 0 to (C_DATA_WIDTH-1) generate
		-- Instantiating a 1-bit full adder
		full_adder : FA1B
			port map(
				a => a(i),
				b => b(i),
				c_in => carry_sig(i),
				sum => result(i),
				c_out => carry_sig(i+1)
			);
	end generate;

	carry_out <= carry_sig(C_DATA_WIDTH);
end LDO_I;
