LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Counter_tb IS
END Counter_tb;

ARCHITECTURE functional OF Counter_tb IS
	
	COMPONENT Counter IS
	GENERIC(preset: natural := 256);
	PORT (clk,async_rst,sync_rst,ce: in std_logic;
			tc: out std_logic
			);
	END COMPONENT;
	
	SIGNAL clk_tb,async_rst_tb,sync_rst_tb,ce_tb: std_logic;
	SIGNAL tc_tb: std_logic;
	
	BEGIN
	
	Counter_prova: Counter
	GENERIC MAP (preset=>4)
	PORT MAP (clk=>clk_tb, ce=>ce_tb, async_rst=>async_rst_tb, sync_rst=> sync_rst_tb, tc=>tc_tb);
	
		clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
		END PROCESS clock;
		
		ciclo: PROCESS
			BEGIN
				async_rst_tb<='0';
				sync_rst_tb<='1';
				ce_tb<='0';
				WAIT FOR 23 ns;
				
				sync_rst_tb<='0';
				ce_tb<='1';
				WAIT FOR 100 ns;
				
				ce_tb<='0';
				WAIT FOR 20 ns;
				
				async_rst_tb<='1';
				WAIT FOR 20 ns;
				
				async_rst_tb<='0';
				ce_tb<='1';
				WAIT FOR 100 ns;
				
				ce_tb<='0';
				WAIT FOR 20 ns;
		END PROCESS ciclo;

END functional;