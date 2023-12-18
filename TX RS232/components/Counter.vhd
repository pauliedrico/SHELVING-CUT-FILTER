library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is

	generic
	(
		preset : integer := 255
	);

	port
	(
		clk		   : in std_logic;
		async_rst	: in std_logic;
		sync_rst	   : in std_logic;
		ce				: in std_logic;
		tc				: out std_logic
	);

end entity;

architecture behavioral of Counter is
begin

	process (clk,async_rst)
		variable   cnt		   : integer range 0 to preset;
	begin
		if async_rst='1' then 
			cnt := 0;
		elsif(clk'event and clk='1') then
			if sync_rst = '1' then
				cnt := 0;
			elsif ce = '1' then
				if(cnt<preset) then
					cnt := cnt + 1;
				end if;
			end if;
		end if;
		
		if(cnt<preset) then 
			tc <= '0';
		elsif(cnt=preset) then 
			tc <= '1';
		end if;

	end process;
end behavioral;




