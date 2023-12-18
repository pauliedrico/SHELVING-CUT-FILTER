LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Counter_tb IS
END Counter_tb;

ARCHITECTURE functional OF Counter_tb IS
	
	COMPONENT Counter IS
	generic(
		preset : integer := 255
	);
	port(
		clk		   : in std_logic;
		rst		   : in std_logic;
		ce				: in std_logic;
		tc				: out std_logic
	);
	END COMPONENT;
	
	SIGNAL clk_tb,rst_tb,ce_tb: std_logic;
	SIGNAL tc_tb: std_logic;
	
	BEGIN
	
	Counter_prova: Counter
	GENERIC MAP (preset=>4)
	PORT MAP (clk=>clk_tb, ce=>ce_tb, rst=>rst_tb, tc=>tc_tb);
	
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
				WAIT FOR 100 ns;
				
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