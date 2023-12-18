library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Parallel_register is
generic(
	N: integer := 8
);
port(
		clk,rst: IN STD_LOGIC;
		parallel_in : IN STD_LOGIC_VECTOR(N-1 downto 0);
		parallel_out : OUT STD_LOGIC_VECTOR(N-1 downto 0)
);
end Parallel_register;

architecture behavioral of Parallel_register is
begin
process(clk,rst)
	begin
	if(rst='1') then 
			parallel_out<=(others=>'1');
	elsif(clk'event and clk='1') then
			parallel_out<=parallel_in;	
	end if;
end process;
end behavioral;