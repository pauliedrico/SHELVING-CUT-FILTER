library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Audio_Processor is 
	port(
		clk :IN std_logic;
		rst :IN std_logic;
		START: IN std_logic;
		SW_0: IN std_logic;
		SW_1: IN std_logic;
		DIN: IN std_logic_vector(7 downto 0);
		DOUT: buffer std_logic_vector(7 downto 0);
		DONE: OUT std_logic
	);
end Audio_Processor;

architecture behavioral of Audio_Processor is

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
	
	component saturated_adder is
	generic (
		n, p, m : integer 
	);
	port (
		x_std : in std_logic_vector(n-1 downto 0); 
		y_std : in std_logic_vector(p-1 downto 0); 
		z_std : out std_logic_vector(m-1 downto 0);
		op : in std_logic
	);
	end component;
	
	component saturated_multiplier is
	generic (
		n, p, m : integer
	);
	port (
		x_std : in std_logic_vector(n-1 downto 0); 
		y_std : in std_logic_vector(p-1 downto 0); 
		z_std : out std_logic_vector(m-1 downto 0) 
	);
	end component;
	
	type state_type is (reset,idle,sample,LF_Count,LF_result,LF_last,LF_done,HF_Count,HF_result,HF_last,HF_done,LB_result,LB_wait,LB_done);
	
	
	constant a_LF: std_logic_vector(7 downto 0):="00101110";   -- value 0.1784 in sfixed(-1 downto -8) format
	constant a_HF: std_logic_vector(7 downto 0):="00100110";   -- value 0.1498 in sfixed(-1 downto -8) format	
	constant H02_LF: std_logic_vector(7 downto 0):="10001101";         -- value -0.45 in sfixed(-1 downto -8) format
	constant H02_HF: std_logic_vector(7 downto 0):="10000100"; -- value -0.4841 in sfixed(-1 downto -8) format
	constant inversion: std_logic_vector(7 downto 0):="00000001";
	signal current_state, next_state: state_type;
	signal DIN_star: std_logic_vector(7 downto 0);
	signal X,XP,Y1P: std_logic_vector(7 downto 0);
	signal outmux1,outmux2,outmux3,outadd1,outadd2,outadd4,outconv,in1add1,in2add1,inadd4: std_logic_vector(7 downto 0);
	signal outadd3 : std_logic_vector(8 downto 0); 
	signal outmult1,outmult2: std_logic_vector(15 downto 0);
	signal outmult3: std_logic_vector(16 downto 0);
	signal LE_X,NO_FILTER,FILTER_TYPE: std_logic;
	signal CE_PR,RST_PR,TC_PR,LE_Y1P,LE_Y,LE_XP: std_logic;
	signal RST_Y,RST_X,RST_XP,RST_Y1P,RST_SAMPLE: std_logic;
	--------------------------------------------
	begin
	
	Counter_PROCESS: Counter
	GENERIC MAP (preset=>1023)
	PORT MAP (clk=>clk, rst=>RST_PR, ce=>CE_PR,tc=>TC_PR);
	
	Sample_register: process(clk)
	begin
	if(clk'event and clk='1') then
		if(RST_SAMPLE='1') then
			DIN_star<=(others=>'0');
		else
			DIN_star<=DIN;
		end if;
	end if;
	end process;
	
	X_register: process(clk)
	begin
	if(clk'event and clk='1') then
		if(RST_X='1') then
			X<=(others=>'0');
		elsif (LE_X='1') then
			X<=DIN_star;
		else
			X<=X;
		end if;
	end if;
	end process;
	
	XP_register: process(clk)
	begin
	if(clk'event and clk='1') then
		if(RST_XP='1') then
			XP<=(others=>'0');
		elsif (LE_XP='1') then
			XP<=X;
		else
			XP<=XP;
		end if;
	end if;
	end process;
	
	Y1P_register: process(clk)
	begin
	if(clk'event and clk='1') then
		if(RST_Y1P='1') then
			Y1P<=(others=>'0');
		elsif (LE_Y1P='1') then
			Y1P<=outadd2;
		else
			Y1P<=Y1P;
		end if;
	end if;
	end process;
	
	Y_register: process(clk)
	begin
	if(clk'event and clk='1') then
		if(RST_Y='1') then
			DOUT<=(others=>'0');
		elsif (LE_Y='1') then
			DOUT<=outmux3;
		else
			DOUT<=DOUT;
		end if;
	end if;
	end process;
	
	mux1: process(FILTER_TYPE)
	begin
		if FILTER_TYPE='1' then 
			outmux1<=a_HF;
		else
			outmux1<=a_LF;
		end if;
	end process;
	
	mux2: process(FILTER_TYPE)
	begin
		if FILTER_TYPE='1' then 
			outmux2<=H02_HF;
		else
			outmux2<=H02_LF;
		end if;
	end process;
	
	mux3: process(NO_FILTER,X,outadd4)
	begin
		if NO_FILTER='1' then 
			outmux3<=X;
		else
			outmux3<=outadd4;
		end if;
	end process;
	
	inverter: process(outmux1)
	begin 
		outconv<=std_logic_vector(unsigned(not(outmux1)) + unsigned(inversion));
	end process;

	mult1: saturated_multiplier
	generic map(8,8,16)
	port map(outmux1,X,outmult1);
	
	mult2: saturated_multiplier
	generic map(8,8,16)
	port map(outconv,Y1P,outmult2);
	
	mult3: saturated_multiplier
	generic map(9,8,17)
	port map(outadd3,outmux2,outmult3);
	
	in1add1<=outmult1(15 downto 8);
	in2add1<=outmult2(15 downto 8);
	
	add1: saturated_adder
	generic map(8,8,8)
	port map(in1add1,in2add1,outadd1,'0');
	
	add2: saturated_adder
	generic map(8,8,8)
	port map(XP,outadd1,outadd2,'0');
	
	add3: saturated_adder
	generic map(8,8,9)
	port map(X,outadd2,outadd3,FILTER_TYPE);
	
	inadd4<=outmult3(16)&outmult3(14 downto 8);
	
	add4: saturated_adder
	generic map(8,8,8)
	port map(inadd4,X,outadd4,'0');
	
-----------------------------------------------------------------------------------------	
	cambio_stato: process(clk)
	begin
		if(clk'event and clk='1') then
		case current_state is
			when idle => if (START='1') then next_state<=sample; end if;
			when sample => if (SW_0='1' and SW_1='0') then next_state<=HF_Count;
							  elsif (SW_0='0' and SW_1='1') then next_state<=LF_Count;
							  else next_state<=LB_result; end if;
			when LF_Count => if (TC_PR='1') then next_state<=LF_result; end if;
			when LF_result=> next_state<=LF_last;
			when LF_last=> next_state<=LF_done;
			when LF_done=> next_state<=idle;
			when HF_Count => if (TC_PR='1') then next_state<=HF_result; end if;
			when HF_result=> next_state<=HF_last;
			when HF_last=> next_state<=HF_done;
			when HF_done=> next_state<=idle;
			when LB_result=> next_state<=LB_wait;
			when LB_wait=> next_state<=LB_done;
			when LB_done=> next_state<=idle;
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
			when reset=> LE_X<='0'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='1';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='1';RST_X<='1'; RST_XP<='1';RST_Y1P<='1';RST_SAMPLE<='1';
			when idle=> LE_X<='0'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when sample=> LE_X<='1'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='1';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0';
			when LF_Count => LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='0'; CE_PR<='1'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when LF_result=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='1';LE_Y1P<='0';LE_Y<='1';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when LF_last=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='1';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when LF_done=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='1';DONE<='1';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when HF_Count => LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='1'; CE_PR<='1'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when HF_result=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='1'; CE_PR<='0'; RST_PR<='1';LE_Y1P<='0';LE_Y<='1';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when HF_last=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='1'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='1';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when HF_done=> LE_X<='0'; NO_FILTER<='0'; FILTER_TYPE<='1'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='1';DONE<='1';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
			when LB_result=> LE_X<='0'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='1';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0';
			when LB_wait=> LE_X<='0'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='0';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0';
			when LB_done=> LE_X<='0'; NO_FILTER<='1'; FILTER_TYPE<='0'; CE_PR<='0'; RST_PR<='0';LE_Y1P<='0';LE_Y<='0';LE_XP<='0';DONE<='1';RST_Y<='0';RST_X<='0'; RST_XP<='0';RST_Y1P<='0';RST_SAMPLE<='0'; 
		end case;
	end process;

end architecture;
	