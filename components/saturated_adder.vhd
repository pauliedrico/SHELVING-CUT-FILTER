library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity saturated_adder is
generic (
	n, p, m : integer -- m <= max(n,p)+1
);
port (
	x_std : in std_logic_vector(n-1 downto 0); -- [n,q]
	y_std : in std_logic_vector(p-1 downto 0); -- [p,q]
	z_std : out std_logic_vector(m-1 downto 0); -- [m,q]
	op : in std_logic
);
end saturated_adder;

architecture saturated_adder_arch of saturated_adder is

function MAX(LEFT, RIGHT: INTEGER) return INTEGER is
begin
if LEFT > RIGHT then return LEFT;
else return RIGHT;
end if;
end;

signal x : signed(n-1 downto 0); -- [n,q]
signal y : signed(p-1 downto 0); -- [p,q]
signal z : signed(m-1 downto 0); -- [m,q]

signal zx : signed(max(n,p) downto 0);
signal OVi : std_logic;
constant wmax : signed(m-2 downto 0) := (others=>'1');
constant wmin : signed(m-2 downto 0) := (others=>'0');

begin

x<=signed(x_std);
y<=signed(y_std);
z_std<=std_logic_vector(z);

zx <= (x(n-1)&x) + (y(p-1)&y) when op='0' else
	  (x(n-1)&x) - (y(p-1)&y);

overflow_detect : process(zx)
variable temp : std_logic;
begin
temp := '0';
for I in m to max(n,p) loop
	if ((zx(I) xor zx(m-1))='1') then
		temp := '1';
	end if;
end loop;

OVi <= temp; 
end process;

z <= ('0'&wmax) when OVi='1' AND zx(max(n,p))='0' else
	 ('1'&wmin) when OVi='1' AND zx(max(n,p))='1' else
	 zx(m-1 downto 0);

end saturated_adder_arch;
