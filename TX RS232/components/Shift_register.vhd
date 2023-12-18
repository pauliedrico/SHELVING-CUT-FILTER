library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Shift_register is
generic(
	N: integer := 10
);
port(
		clk,le,se,rst: IN STD_LOGIC;
		data_in_parallel: IN std_logic_vector(N-1 downto 0);
		data_in_serial: IN std_logic;
		data_out_parallel: buffer std_logic_vector(N-1 downto 0)
);
end Shift_register;

architecture behavioral of Shift_register is
begin
process(clk,rst)
	begin
	if(rst='1') then 
			data_out_parallel<=(others=>'1');
	elsif(clk'event and clk='1') then
		if(le='1') then
			data_out_parallel<=data_in_parallel;
		elsif(se='1') then
			data_out_parallel((N-1) downto 1) <= data_out_parallel((N-2) downto 0);
			data_out_parallel(0)<=data_in_serial;
		else
			data_out_parallel<=data_out_parallel;
		end if;
	end if;	
end process;
end behavioral;
