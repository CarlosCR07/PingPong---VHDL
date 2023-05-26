library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity pong is
	Port (
		clk	: in std_logic;
		bds	: in std_logic;
		bdb	: in std_logic;
		bis	: in std_logic;
		bib	: in std_logic;
		start	: in std_logic;
		hs		: out std_logic;
		vs		: out std_logic;
		disp1	: out std_logic_vector(7 downto 0);
		disp2	: out std_logic_vector(7 downto 0);
		disp3	: out std_logic_vector(7 downto 0);
		disp4	: out std_logic_vector(7 downto 0);
		disp5	: out std_logic_vector(7 downto 0);
		disp6	: out std_logic_vector(7 downto 0);
		red	: out std_logic_vector(3 downto 0);
		green	: out std_logic_vector(3 downto 0);
		blue	: out std_logic_vector(3 downto 0)
	);
End pong;

Architecture Behavioral of pong is

	component div is
	port(
		clk50MHz: in std_logic;
		clk25MHz: out std_logic
	);
	end component;

	component rel is
		Generic	( lim : integer := 25000000);
		Port (
			clk		: in std_logic;
			clk_esc	: out std_logic
		);
	end component;
	
	component cod7seg is
		Port (
			num	: in integer range 0 to 9;
			cod	: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component vga is
		generic(
			constant h_pulse	: integer := 96;
			constant h_bp		: integer := 48;
			constant h_pixels	: integer := 640;
			constant h_fp		: integer := 16;
			constant v_pulse	: integer := 2;
			constant v_bp		: integer := 33;
			constant v_pixels	: integer := 480;
			constant v_fp		: integer := 10
		);

		port(
			reloj_pixel	: in std_logic;
			display_ena	: out std_logic;
			column		: out integer range 0 to 96 + 48 + 640 + 16 - 1;
			row			: out integer range 0 to 2 + 33 + 480 + 10 - 1;
			h_sync		: out std_logic;
			v_sync		: out std_logic
		);
	end component;

	signal clk_vga	: std_logic := '0';
	signal de		: std_logic := '0';
	signal col		: integer range 0 to (96 + 48 + 640 + 16 - 1);
	signal row		: integer range 0 to (2 + 33 + 480 + 10 - 1);
	
	signal mid, miu, mdd, mdu		: integer range 0 to 9;
	
	signal bils: integer range 0 to 420 := 210;
	signal bili: integer range 60 to 480 := 270;
	signal bdls: integer range 0 to 420 := 210;
	signal bdli: integer range 60 to 480 := 270;
	
	signal pls: integer range 0 to 470 := 0;
	signal plb: integer range 10 to 480 := 10;
	signal pli: integer range 20 to 610 := 315;
	signal pld: integer range 30 to 620 := 325;

	signal tim_bot	: std_logic := '0';
	signal tim_bal	: std_logic := '0';
	signal tim_rel	: std_logic := '0';
	
	signal duclk, ddclk : integer range 0 to 9;

	type state is (bd, bi, sd, si, ei, ed, pi, pd);
	signal ballst : state := ED;
	
begin
	
	R1: div port map(clk, clk_vga);
	R2: rel generic map(100000) port map(clk, tim_bot);
	R3: rel generic map(90000) port map(clk, tim_bal);
	R4: rel generic map(25000000) port map(clk, tim_rel);
	C1: cod7seg port map(mid, disp6);
	C2: cod7seg port map(miu, disp5);
	C3: cod7seg port map(mdd, disp2);
	C4: cod7seg port map(mdu, disp1);
	C5: cod7seg port map(ddclk, disp4);
	C6: cod7seg port map(duclk, disp3);
	V1: vga port map(clk_vga, de, col, row, hs, vs);

	process(tim_rel, duclk, ddclk)
	begin
		if rising_edge(tim_rel) then
			if start = '0' then
				duclk <= 0;
				ddclk <= 0;
			else
				case ballst is
					when pd =>
						duclk <= 0;
						ddclk <= 0;
					when pi =>
						duclk <= 0;
						ddclk <= 0;
					when others =>
						if duclk < 9 then
							duclk <= duclk + 1;
						else
							duclk <= 0;
							if ddclk < 9 then
								ddclk <= ddclk + 1;
							else
								ddclk <= 0;
							end if;
						end if;
				end case;
			end if;
		end if;
	end process;

	process(tim_bot, start, bds, bdb, bis, bib)
	begin
		if rising_edge(tim_bot) then
			if start = '0' then
				bdls <= 210;
				bdli <= 270;
				bdls <= 210;
				bdli <= 270;
			else
				if bds = '0' and bdls > 0 then
					bdls <= bdls - 1;
					bdli <= bdli - 1;
				elsif bdb = '0' and bdli < 480 then
					bdls <= bdls + 1;
					bdli <= bdli + 1;
				else
					bdls <= bdls;
					bdli <= bdli;
				end if;
				
				if bis = '0' and bils > 0 then
					bils <= bils - 1;
					bili <= bili - 1;
				elsif bib = '0' and bili < 480 then
					bils <= bils + 1;
					bili <= bili + 1;
				else
					bils <= bils;
					bili <= bili;
				end if;
			end if;
		end if;
	end process;
	
	process (tim_bal, start, ballst)
	begin
		if rising_edge(tim_bal) then
			if start = '0' then
				pls <= 0;
				plb <= 10;
				pli <= 315;
				pld <= 325;
			else
				case ballst is
					when bd =>
						pls <= pls + 1;
						plb <= plb + 1;
						pli <= pli + 1;
						pld <= pld + 1;
					when bi =>
						pls <= pls + 1;
						plb <= plb + 1;
						pli <= pli - 1;
						pld <= pld - 1;
					when sd =>
						pls <= pls - 1;
						plb <= plb - 1;
						pli <= pli + 1;
						pld <= pld + 1;
					when si =>
						pls <= pls - 1;
						plb <= plb - 1;
						pli <= pli - 1;
						pld <= pld - 1;
					when others =>
						pls <= 0;
						plb <= 10;
						pli <= 315;
						pld <= 325;
				end case;
			end if;
		end if;
	end process;
	
	process (tim_bal, start, ballst, pls, plb, pli, pld, bils, bili, bdls, bdli)
	begin
		if rising_edge(tim_bal) then
			if start = '0' then
				ballst <= ed;
			else
				case ballst is
					when ed =>
						ballst <= bd;
					when ei =>
						ballst <= bi;
					when pd =>
						ballst <= ei;
					when pi =>
						ballst <= ed;
					when bd =>
						if pld >= 620 and plb >= 480 and bdli >= 470 then
							ballst <= si;
						elsif pld >= 620 and plb >= bdls and pls <= bdli then
							ballst <= bi;
						elsif pld >= 620 then
							ballst <= pd;
						elsif plb >= 480 then
							ballst <= sd;
						else
							ballst <= bd;
						end if;
					when bi =>
						if pli <= 20 and plb >= 480 and bili >= 470 then
							ballst <= sd;
						elsif pli <= 20 and plb >= bils and pls <= bili then
							ballst <= bd;
						elsif pli <= 20 then
							ballst <= pi;
						elsif plb >= 480 then
							ballst <= si;
						else
							ballst <= bi;
						end if;
					when sd =>
						if pld >= 620 and pls <= 0 and bdls <= 10 then
							ballst <= bi;
						elsif pld >= 620 and plb >= bdls and pls <= bdli then
							ballst <= si;
						elsif pld >= 620 then
							ballst <= pd;
						elsif pls <= 0 then
							ballst <= bd;
						else
							ballst <= sd;
						end if;
					when si =>
						if pli <= 20 and pls <= 0 and bils <= 10 then
							ballst <= bd;
						elsif pli <= 20 and plb >= bils and pls <= bili then
							ballst <= sd;
						elsif pli <= 20 then
							ballst <= pi;
						elsif pls <= 0 then
							ballst <= bi;
						else
							ballst <= si;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	process (tim_bal, start, ballst)
	begin
		if rising_edge(tim_bal) then
			if start = '0' then
				mid <= 0;
				miu <= 0;
				mdd <= 0;
				mdu <= 0;
			else
				case ballst is
					when pd =>
						if miu < 9 then
							miu <= miu + 1;
						else
							miu <= 0;
							if mid < 9 then
								mid <= mid + 1;
							else
								mid <= 0;
							end if;
						end if;
					when pi =>
						if mdu < 9 then
							mdu <= mdu + 1;
						else
							mdu <= 0;
							if mdd < 9 then
								mdd <= mdd + 1;
							else
								mdd <= 0;
							end if;
						end if;
					when others =>
						mid <= mid;
						miu <= miu;
						mdd <= mdd;
						mdu <= mdu;
				end case;
			end if;
		end if;
	end process;
	
	process (de, col, row, pls, plb, pli, pld, bils, bili, bdls, bdli, start)
	begin
		if de = '1' then
			if start = '0' then
				if row > 0 and row < 10 and col > 315 and col < 325 then
					red <= (others => '1');
					green <= (others => '1');
					blue <= (others => '1');
				elsif row > 210 and row < 270 and col > 10 and col < 20 then
					red <= (others => '0');
					green <= (others => '0');
					blue <= (others => '1');
				elsif row > 210 and row < 270 and col > 620 and col < 630 then
					red <= (others => '1');
					green <= (others => '0');
					blue <= (others => '0');
				else
					red <= (others => '0');
					green <= (others => '0');
					blue <= (others => '0');
				end if;
			else
				if row > pls and row < plb and col > pli and col < pld then
					red <= (others => '1');
					green <= (others => '1');
					blue <= (others => '1');
				elsif row > bils and row < bili and col > 10 and col < 20 then
					red <= (others => '0');
					green <= (others => '0');
					blue <= (others => '1');
				elsif row > bdls and row < bdli and col > 620 and col < 630 then
					red <= (others => '1');
					green <= (others => '0');
					blue <= (others => '0');
				else
					red <= (others => '0');
					green <= (others => '0');
					blue <= (others => '0');
				end if;
			end if;
		else
			red <= (others => '0');
			green <= (others => '0');
			blue <= (others => '0');
		end if;
	end process;
	
end Behavioral;