library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity rel is
	Generic	( lim : integer := 25000000);
	Port (
		clk		: in std_logic;
		clk_esc	: out std_logic
	);
End rel;

Architecture Behavioral of rel is

	signal count : integer range 0 to (lim * 2) := 0;
	
begin

	process(clk, count)
	begin
		if rising_edge(clk) then
		
			if count < (lim * 2) then
				count <= count + 1;
				if count < lim then
					clk_esc <= '1';
				else
					clk_esc <= '0';
				end if;
			else
				count <= 0;
			end if;
		end if;
	end process;
end Behavioral;