----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: FA1B - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Full adder (1-bit)
--
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FA1B IS 
	PORT(   a : IN    STD_LOGIC;
		    b : IN    STD_LOGIC;
         c_in : IN    STD_LOGIC;
          sum : OUT   STD_LOGIC;
        c_out : OUT   STD_LOGIC
	);
END entity;

ARCHITECTURE LDO_I OF FA1B IS
BEGIN
    sum <= a XOR b XOR c_in;
    c_out <= (a AND b) OR (c_in AND (a OR b));
END LDO_I;

