--------------------------------------------
-- Module Name: tutorial
--------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Entity tutorial Is
port (
		swt : in STD_LOGIC_VECTOR(7 downto 0);
		led : out STD_LOGIC_VECTOR(7 downto 0)
	);
end tutorial;

Architecture behavior of tutorial Is

Signal led_int : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

begin
        led <= led_int;
        
		led_int(0) <= not(swt(0));
		led_int(1) <= swt(1) and not(swt(2));
		led_int(3) <= swt(2) and swt(3);
		led_int(2) <= led_int(1) or led_int(3);

		led_int(7 downto 4) <= swt(7 downto 4);

end behavior;
		

