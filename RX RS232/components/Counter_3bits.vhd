library    ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Counter_3bits is
port(
    clk    : in std_logic;
    rst  : in std_logic;
	 ce     : in std_logic;
    q      : out std_logic_vector(2 downto 0)
);
end Counter_3bits ;

architecture behavioral of Counter_3bits  is
begin

process(clk)
variable q_int : std_logic_vector(2 downto 0);
begin
if(rising_edge(clk))then
   if rst = '1' then
		q_int := (others => '0');
	elsif ce = '1' and q_int< 7 then
       q_int := q_int+1;
   end if;
	q<=q_int;
end if;
end process;

end behavioral;
