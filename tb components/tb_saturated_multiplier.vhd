library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

ENTITY tb_saturated_multiplier IS
END tb_saturated_multiplier;

ARCHITECTURE functional OF tb_saturated_multiplier IS
	
component  saturated_multiplier is
generic (
	n, p, m : integer -- m<=n+p
);
port (
	x_std : in std_logic_vector(n-1 downto 0); -- [n,q]
	y_std : in std_logic_vector(p-1 downto 0); -- [p,l]
	z_std : out std_logic_vector(m-1 downto 0) -- [m,q+l]
);
end component;

SIGNAL a_tb: std_logic_vector(8 downto 0);
SIGNAL b_tb: std_logic_vector(7 downto 0);
SIGNAL mult_tb: std_logic_vector(16 downto 0);
signal a_tb_sfixed	:sfixed(0 downto -8);
signal b_tb_sfixed	:sfixed(-1 downto -8);
signal mult_tb_fixed	:sfixed(0 downto -16);
signal gimm : std_logic_vector(7 downto 0);
signal gimm_fix : sfixed(-1 downto -8);
	
BEGIN

a_tb<=to_slv(a_tb_sfixed);
b_tb<=to_slv(b_tb_sfixed);	
mult_tb_fixed<=to_sfixed(mult_tb,mult_tb_fixed);
gimm(7)<=mult_tb(16);
gimm(6 downto 0)<= mult_tb(14 downto 8);
gimm_fix<=to_sfixed(gimm,gimm_fix);
	
input:	PROCESS
	BEGIN
				A_tb_sfixed<= (to_sfixed(-0.23,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(0.01,B_tb_sfixed));
				wait for 70 ns;
				A_tb_sfixed<= (to_sfixed(0.25,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(0.33,B_tb_sfixed));
				wait for 70 ns;	
				A_tb_sfixed<= (to_sfixed(-0.35,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(0.34,B_tb_sfixed));
				wait for 70 ns;
				A_tb_sfixed<= (to_sfixed(0.5,A_tb_sfixed));
				B_tb_sfixed<= (to_sfixed(-0.5,B_tb_sfixed));
				wait for 70 ns;				
	END PROCESS input;
		
mult_mapping: saturated_multiplier generic map (9,8,17) PORT MAP (a_tb, b_tb, mult_tb);
	
END functional;

