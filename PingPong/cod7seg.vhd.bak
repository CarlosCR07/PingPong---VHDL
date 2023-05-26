library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity cod7seg is
	Port (
		num	: in integer range 0 to 9;
		cod	: out std_logic_vector (7 downto 0)
	);
End cod7seg;

Architecture Behavioral of cod7seg is
	
begin

	with num select
		cod <="11000000" when 0,
				"11111001" when 1,
				"10100100" when 2,
				"10110000" when 3,
				"10011001" when 4,
				"10010010" when 5,
				"10000010" when 6,
				"11111000" when 7,
				"10000000" when 8,
				"10010000" when 9,
				"11111111" when others;
end Behavioral;