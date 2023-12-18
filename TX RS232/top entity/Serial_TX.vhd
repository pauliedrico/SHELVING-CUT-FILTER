library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Serial_TX is 
	port(
		clk :IN std_logic;
		rst :IN std_logic;
		WR: IN std_logic;
		DIN: IN std_logic_vector(7 downto 0);
		TX: OUT std_logic
	);
end Serial_TX;

architecture behavioral of Serial_TX is

	component Counter is
	generic(
		preset : integer := 255
	);
	port
	(
		clk		   : in std_logic;
		rst			: in std_logic;
		ce				: in std_logic;
		tc				: out std_logic
	);
	end component;
	
	
	component Parallel_register is
	generic(
		N: integer := 8
	);
	port(
		clk,rst: IN STD_LOGIC;
		parallel_in : IN STD_LOGIC_VECTOR(N-1 downto 0);
		parallel_out : OUT STD_LOGIC_VECTOR(N-1 downto 0)
	);
	end component;
	
	component Shift_register is
	generic(
		N: integer := 10
	);
	port(
		clk,le,se,rst: IN STD_LOGIC;
		data_in_parallel: IN std_logic_vector(N-1 downto 0);
		data_in_serial: IN std_logic;
		data_out_serial: out std_logic
	);
	end component;

	type state_type is (idle,load,bitTX,shift,reset);
	
	signal current_state, next_state: state_type;
	signal DIN_star: std_logic_vector(7 downto 0);
	signal SE,LE: std_logic;
	signal RST1,CE1: std_logic;
	signal RST2,CE2: std_logic;
	signal TC1,TC2: std_logic;
	signal RSTP,RSTS: std_logic;
	
	begin
	
	Counter1: Counter
	GENERIC MAP (preset=>1040)
	PORT MAP (clk=>clk, rst=>RST1, ce=>CE1,tc=>TC1);
	
	Counter2: Counter
	GENERIC MAP (preset=>9)
	PORT MAP (clk=>clk, rst=>RST2, ce=>CE2,tc=>TC2);
	
	DelayRegister: Parallel_register
	GENERIC MAP (N=>8)
	PORT MAP (clk=>clk, rst=>RSTP, parallel_in=>DIN, parallel_out=>DIN_star);
	
	ShiftRegister: Shift_register
	GENERIC MAP (N=>10)
	PORT MAP (clk=>clk, rst=>RSTS, le=>LE, se=>SE,data_in_parallel(0)=>'0',data_in_parallel(8 downto 1)=>DIN_star,
				data_in_parallel(9)=>'1',data_in_serial=>'1',data_out_serial=>TX);
	
	
	cambio_stato: process(clk)
	begin
		if(clk'event and clk='1') then
		case current_state is
			when idle => if (WR='1') then next_state<=load; end if;
			when load => next_state<=bitTX;
			when bitTX => if (TC1='1' and TC2='0') then next_state<=shift;
							  elsif (TC1='1' and TC2='1') then next_state<=reset;
							  end if;
			when shift=> next_state<=bitTX;
			when reset => next_state<=idle;
			when others => next_state<=reset;
		end case;
		end if;
	end process;
	
	aggiornamento_stato: process(next_state,rst)
	begin
		if(rst='0') then 
			current_state<=reset;
		else
			current_state<=next_state;
		end if;	
	end process;
	
	cambio_output:process(current_state)
	begin
		case current_state is
			when idle =>   LE<='0';SE<='0';CE1<='0';RST1<='0';CE2<='0';RST2<='0';RSTP<='0';RSTS<='0';	
			when load =>	LE<='1';SE<='0';CE1<='0';RST1<='1';CE2<='0';RST2<='1';RSTP<='0';RSTS<='0';
			when bitTX =>  LE<='0';SE<='0';CE1<='1';RST1<='0';CE2<='0';RST2<='0';RSTP<='0';RSTS<='0';
			when shift=>	LE<='0';SE<='1';CE1<='0';RST1<='1';CE2<='1';RST2<='0';RSTP<='0';RSTS<='0';
			when reset => 	LE<='0';SE<='0';CE1<='0';RST1<='1';CE2<='0';RST2<='1';RSTP<='1';RSTS<='1';
		end case;
	end process;

end architecture;
	