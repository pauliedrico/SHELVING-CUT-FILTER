LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Counter_3bits_tb IS
END Counter_3bits_tb;

ARCHITECTURE functional OF Counter_3bits_tb IS
	
	COMPONENT Counter_3bits IS
	port(
    clk    : in std_logic;
    rst  : in std_logic;
	 ce     : in std_logic;
    q      : out std_logic_vector(2 downto 0)
	);
	END COMPONENT;
	
	SIGNAL clk_tb,rst_tb,ce_tb: std_logic;
	SIGNAL q_tb: std_logic_vector(2 downto 0);
	
	BEGIN
	
	Counter_3bits_prova: Counter_3bits
	PORT MAP (clk=>clk_tb, ce=>ce_tb, rst=>rst_tb, q=>q_tb);
	
		clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
		END PROCESS clock;
		
		ciclo: PROCESS
			BEGIN
				rst_tb<='1';
				ce_tb<='0';
				WAIT FOR 23 ns;
				
				rst_tb<='0';
				ce_tb<='1';
				WAIT FOR 300 ns;
				
				ce_tb<='0';
				WAIT FOR 20 ns;
				
				rst_tb<='1';
				WAIT FOR 20 ns;
				
				rst_tb<='0';
				ce_tb<='1';
				WAIT FOR 100 ns;
				
				ce_tb<='0';
				WAIT FOR 20 ns;
		END PROCESS ciclo;

END functional;