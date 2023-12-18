library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SIPORegister is
generic(
	N: integer := 8
);
port(
		clk,se,rst: IN STD_LOGIC;
		data_in_serial: IN std_logic;
		data_out_parallel: buffer std_logic_vector(N-1 downto 0)
);
end SIPORegister;

architecture behavioral of SIPORegister is
begin
process(clk)
	begin
	if(clk'event and clk='1') then
		if(rst='1') then
			data_out_parallel<=(others=>'1');
		elsif(se='1') then
			data_out_parallel((N-1) downto 1)<=data_out_parallel((N-2) downto 0);
			data_out_parallel(0)<=data_in_serial;
		else
			data_out_parallel<=data_out_parallel;
		end if;
	end if;	
end process;
end behavioral;
