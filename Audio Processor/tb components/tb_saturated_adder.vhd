library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

ENTITY tb_saturated_adder IS
END tb_saturated_adder;

ARCHITECTURE functional OF tb_saturated_adder IS
	
component saturated_adder is
generic (
	n, p, m : integer -- m <= max(n,p)+1
);
port (
	x_std : in std_logic_vector(n-1 downto 0); -- [n,q]
	y_std : in std_logic_vector(p-1 downto 0); -- [p,q]
	z_std : out std_logic_vector(m-1 downto 0); -- [m,q]
	op : in std_logic
);
end component;
	
SIGNAL add_ndiff_tb: STD_LOGIC;
SIGNAL a_tb,b_tb: std_logic_vector(7 downto 0);
SIGNAL sum_tb: std_logic_vector(8 downto 0);
signal a_tb_sfixed	:sfixed(-1 downto -8);
signal b_tb_sfixed	:sfixed(-1 downto -8);
signal sum_tb_sfixed	:sfixed(0 downto -8);
	
BEGIN

a_tb<=to_slv(a_tb_sfixed);
b_tb<=to_slv(b_tb_sfixed);	
sum_tb_sfixed<=to_sfixed(sum_tb,sum_tb_sfixed);
	
op_mode: PROCESS
	BEGIN
	add_ndiff_tb<='1','0' after 200 ns;
	WAIT FOR 300 ns;
	END PROCESS op_mode;

input:	PROCESS
	BEGIN
				A_tb_sfixed<= (to_sfixed(0.178468,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(-0.45,B_tb_sfixed));
				wait for 70 ns;
				A_tb_sfixed<= (to_sfixed(0.149829,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(-0.4841886,B_tb_sfixed));
				wait for 70 ns;	
				A_tb_sfixed<= (to_sfixed(-0.35,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(0.34,B_tb_sfixed));
				wait for 70 ns;
				A_tb_sfixed<= (to_sfixed(0.5,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(-0.5,B_tb_sfixed));
				wait for 70 ns;				
	END PROCESS input;
		
adder_mapping: saturated_adder generic map (8,8,9) PORT MAP (a_tb, b_tb, sum_tb,add_ndiff_tb);
	
END functional;

