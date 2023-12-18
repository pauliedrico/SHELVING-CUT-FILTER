LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Parallel_register_tb IS
END Parallel_register_tb;

ARCHITECTURE functional OF Parallel_register_tb IS
	
	COMPONENT Parallel_register IS
	GENERIC(N: integer := 4);
	port(
		clk,rst: IN STD_LOGIC;
		parallel_in : IN STD_LOGIC_VECTOR(N-1 downto 0);
		parallel_out : OUT STD_LOGIC_VECTOR(N-1 downto 0)
	);
	end component;

	SIGNAL clk_tb,rst_tb: STD_LOGIC;
	SIGNAL parallel_in_tb: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL parallel_out_tb: STD_LOGIC_VECTOR (3 DOWNTO 0);
	
	BEGIN
	
	Parallel_register_prova: Parallel_register
	GENERIC MAP (N=>4)
	PORT MAP (clk=>clk_tb, rst=>rst_tb, parallel_in=>parallel_in_tb, parallel_out=>parallel_out_tb);
	
	
		clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
		END PROCESS clock;
		
		PROCESS
			BEGIN
				
				rst_tb<='0';
				WAIT FOR 23 ns;
				
				parallel_in_tb<="1010";
				WAIT FOR 20 ns;

				parallel_in_tb<="1101";
				WAIT FOR 20 ns;

				parallel_in_tb<="0100";
				WAIT FOR 20 ns;

				rst_tb<='1';
				WAIT FOR 20 ns;

		END PROCESS;

END functional;