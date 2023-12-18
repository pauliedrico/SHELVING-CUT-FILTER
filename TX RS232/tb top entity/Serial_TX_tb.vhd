LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Serial_TX_tb IS
END Serial_TX_tb;

ARCHITECTURE functional OF Serial_TX_tb IS
	
	COMPONENT Serial_TX IS
	port(
		clk :IN std_logic;
		rst :IN std_logic;
		WR: IN std_logic;
		DIN: IN std_logic_vector(7 downto 0);
		TX: OUT std_logic
	);
	end component;

	SIGNAL clk_tb,rst_tb,WR_tb: std_logic;
	SIGNAL DIN_tb: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal TX_tb: std_logic;
	
	BEGIN
	
	Serial_TX_prova: Serial_TX 
	PORT MAP (clk=>clk_tb, rst=>rst_tb,WR=>WR_tb, TX=>TX_tb, DIN=>DIN_tb);
	
	
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
				
				rst_tb<='1';
				DIN_tb<="10010010";
				WAIT FOR 10 ms;
				
		END PROCESS;
		
		StartSignal: process(clk_tb)
		variable time_count : integer:=0;
	begin
		if(clk_tb'event and clk_tb='1') then
			time_count:= time_count+1;
			if time_count = 5 then
				WR_tb<= '0';
			elsif time_count= 100000 then
				time_count:=0;
				WR_tb<='1';
		end if;
		end if;
	end process;

END functional;