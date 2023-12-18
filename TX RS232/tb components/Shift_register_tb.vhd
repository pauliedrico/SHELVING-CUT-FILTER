LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Shift_register_tb IS
END Shift_register_tb;

ARCHITECTURE functional OF Shift_register_tb IS
	
	COMPONENT Shift_register IS
	GENERIC(N: integer := 4);
	port(
		clk,le,se,rst: IN STD_LOGIC;
		data_in_parallel: IN std_logic_vector(N-1 downto 0);
		data_in_serial: IN std_logic;
		data_out_parallel: buffer std_logic_vector(N-1 downto 0)
	);
	END COMPONENT;
	
	SIGNAL clk_tb,le_tb,se_tb,rst_tb: STD_LOGIC;
	SIGNAL data_in_serial_tb: std_logic;
	SIGNAL data_in_parallel_tb: std_logic_vector (3 DOWNTO 0);
	SIGNAL data_out_parallel_tb: std_logic_vector(3 DOWNTO 0);
	
	BEGIN
	data_in_serial_tb<='1';
	
		clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
		END PROCESS clock;
		
		PROCESS
			BEGIN
				le_tb<='1';
				se_tb<='0';
				rst_tb<='0';
				data_in_parallel_tb<="1010";
				WAIT FOR 23 ns;
				
				le_tb<='0';
				se_tb<='1';
				WAIT FOR 20 ns;
				
				se_tb<='0';
				WAIT FOR 40 ns;

				le_tb<='1';
				se_tb<='0';
				data_in_parallel_tb<="1101";
				WAIT FOR 20 ns;

				le_tb<='0';
				se_tb<='1';
				WAIT FOR 20 ns;
				
				se_tb<='0';
				WAIT FOR 40 ns;

				le_tb<='1';
				se_tb<='0';
				data_in_parallel_tb<="0010";
				WAIT FOR 20 ns;

				le_tb<='0';
				se_tb<='1';
				WAIT FOR 20 ns;
				
				se_tb<='0';
				WAIT FOR 40 ns;

				le_tb<='1';
				se_tb<='0';
				data_in_parallel_tb<="0110";
				WAIT FOR 20 ns;

				le_tb<='0';
				se_tb<='1';
				WAIT FOR 20 ns;

				rst_tb<='1';
				WAIT FOR 20 ns;

				rst_tb<='0';
				WAIT FOR 100 ns;
		END PROCESS;
		
	Shift_register_prova: Shift_register
	GENERIC MAP (N=>4)
	PORT MAP (clk=>clk_tb, le=>le_tb, se=>se_tb, rst=>rst_tb, data_in_serial=>data_in_serial_tb, data_in_parallel=>data_in_parallel_tb, data_out_parallel=>data_out_parallel_tb);
	
		

END functional;