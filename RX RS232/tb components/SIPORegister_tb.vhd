LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY SIPORegister_tb IS
END SIPORegister_tb;

ARCHITECTURE functional OF SIPORegister_tb IS
	
	COMPONENT SIPORegister IS
	generic(
	N: integer := 10
	);
	port(
		clk,se,rst: IN STD_LOGIC;
		data_in_serial: IN std_logic;
		data_out_parallel: buffer std_logic_vector(N-1 downto 0)
	);
	END COMPONENT;
	
	SIGNAL clk_tb,se_tb,rst_tb: STD_LOGIC;
	SIGNAL data_in_serial_tb: std_logic;
	SIGNAL data_out_parallel_tb :std_logic_vector(3 downto 0);
	
	BEGIN
	
		clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
		END PROCESS clock;
		
		PROCESS
			BEGIN
				se_tb<='0';
				rst_tb<='0';
				data_in_serial_tb<='1';
				WAIT FOR 23 ns;
				
				se_tb<='1';
				data_in_serial_tb<='0';
				WAIT FOR 45 ns;
				
				se_tb<='0';
				WAIT FOR 40 ns;
				
				rst_tb<='1';
				WAIT FOR 40 ns;
				rst_tb<='0';

				se_tb<='0';
				data_in_serial_tb<='1';
				WAIT FOR 20 ns;
				
				se_tb<='1';
				WAIT FOR 100 ns;

		END PROCESS;
		
	SIPORegister_prova: SIPORegister
	GENERIC MAP (N=>4)
	PORT MAP (clk=>clk_tb, se=>se_tb, rst=>rst_tb, data_in_serial=>data_in_serial_tb, data_out_parallel=>data_out_parallel_tb);
	
		

END functional;