library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity div is
port( clk50MHz: in std_logic;
		clk25MHz: out std_logic
);
end entity div;


architecture behavioral of div is
 signal reloj_pixel : std_logic := '0';
begin

relojpixel: process(clk50MHz) is
begin
	if rising_edge(clk50MHz) then
		reloj_pixel <= not reloj_pixel;
	end if;
end process relojpixel;

clk25MHz <= reloj_pixel;

end architecture behavioral;