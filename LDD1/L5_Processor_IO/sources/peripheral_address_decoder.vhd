----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Sylvain Ieri
-- 
-- Module Name: peripheral_address_decoder - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  peripheral_address_decoder
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


    
entity peripheral_address_decoder is
    generic(
       C_ADDR_BASE : std_logic_vector := x"F0"; 
       C_ADDR_PERI_WIDTH : natural := 1
    );
    Port ( addr : in std_logic_vector (C_ADDR_BASE'range);
           read_en : in std_logic;
           write_en : in std_logic;
           addr_peri : out std_logic_vector (C_ADDR_PERI_WIDTH-1 downto 0);
           read_en_peri : out std_logic;
           write_en_peri : out std_logic
    );
end peripheral_address_decoder;

architecture Behavioral of peripheral_address_decoder is
    
    function mask(number : natural; len : natural) return std_logic_vector is
      variable m : std_logic_vector(len-1 downto 0);
    begin
        if number = 0 then 
            m := (others => '1');
        else
            m := (C_ADDR_PERI_WIDTH-1 downto 0 => '0', others => '1');
        end if;
      return m;
    end function;
    
    --mask isolating the peripheral base address from the input address
    constant C_ADDR_MASK : std_logic_vector(addr'range) := mask(C_ADDR_PERI_WIDTH, addr'length); 
    
    --1 if address inputed is the address space of the peripheral
    signal in_address_range_i :std_logic;
    
begin
    
    --check the address
    in_address_range_i <= '1' when (addr AND C_ADDR_MASK) = C_ADDR_BASE else '0';

    --build the output
    read_en_peri <= read_en and in_address_range_i;
    write_en_peri <= write_en and in_address_range_i;
    addr_peri <= addr(addr_peri'range);

end Behavioral;
