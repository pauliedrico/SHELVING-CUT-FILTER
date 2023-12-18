library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity saturated_multiplier is
generic (
	n, p, m : integer -- m<=n+p
);
port (
	x_std : in std_logic_vector(n-1 downto 0); -- [n,q]
	y_std : in std_logic_vector(p-1 downto 0); -- [p,l]
	z_std : out std_logic_vector(m-1 downto 0) -- [m,q+l]
);
end saturated_multiplier;

architecture saturated_multiplier_arch of saturated_multiplier is


signal x : signed(n-1 downto 0); -- [n,q]
signal y : signed(p-1 downto 0); -- [p,l]
signal z : signed(m-1 downto 0); -- [m,q+l]

signal zx : signed(n+p-1 downto 0);
signal OVi : std_logic;
constant wmax : signed(m-2 downto 0) := (others=>'1');
constant wmin : signed(m-2 downto 0) := (others=>'0');

begin

x<=signed(x_std);
y<=signed(y_std);
z_std<=std_logic_vector(z);

zx <= x*y;

overflow_detect : process(zx)
variable temp : std_logic;
begin
temp := '0';
for I in m to n+p-1 loop
if ((zx(I) xor zx(m-1))='1') then
temp := '1';
end if;
end loop;
OVi <= temp;
end process;

z <= ('0'&wmax) when OVi='1' AND zx(n+p-1)='0' else
	 ('1'&wmin) when OVi='1' AND zx(n+p-1)='1' else
     zx(m-1 downto 0);

end saturated_multiplier_arch;