library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Serial_RX is 
	port(
		clk :IN std_logic;
		rst :IN std_logic;
		DIN: IN std_logic;
		DOUT:OUT std_logic_vector (7 downto 0);
		RDY: OUT std_logic
	);
end Serial_RX;

architecture behavioral of Serial_RX is

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
	
	
	component SIPORegister is
	generic(
		N: integer := 8
	);
	port(
		clk,se,rst: IN STD_LOGIC;
		data_in_serial: IN std_logic;
		data_out_parallel: buffer std_logic_vector(N-1 downto 0)
	);
	end component;
	
	component Counter_3bits is
	port(
    clk    : in std_logic;
    rst  : in std_logic;
	 ce     : in std_logic;
    q      : out std_logic_vector(2 downto 0)
	);
	end component;

	type state_type is (detec_1,detec_2,skip7_1,skip7_2,skip7_3,sample_1,sample_2,sample_3,save_bit,skip5_1,skip5_2,skip5_3,save_stop_bit,control_stop_bit,data_ready,reset);
	signal current_state, next_state: state_type;
	
	signal data_out_detector: std_logic_vector(7 downto 0);
	signal data_out_samples: std_logic_vector(2 downto 0);
	signal sampled_bit: std_logic;
	signal stop_bit:std_logic;
	signal RST_Detector,SE_Detector: std_logic;
	signal RST_Samples,SE_Samples: std_logic;
	signal RST_Out,SE_Out: std_logic;
	signal START_DETECTED: std_logic;
	signal RST_x8,CE_x8, RST_Steps,CE_Steps, RST_Bits,CE_Bits: std_logic;
	signal TC_steps: std_logic_vector(2 downto 0);
	signal TC_x8,TC2_steps,TC4_steps,TC6_steps,TC_bits: std_logic;
	
	
	begin
	
	Counter_x8: Counter
	GENERIC MAP (preset=>128)
	PORT MAP (clk=>clk, rst=>RST_x8, ce=>CE_x8,tc=>TC_x8);
	
	Counter_Steps: Counter_3bits
	PORT MAP (clk=>clk, rst=>RST_Steps, ce=>CE_Steps,q=>TC_Steps);
	
	Counter_Bits: Counter
	GENERIC MAP (preset=>8)
	PORT MAP (clk=>clk, rst=>RST_Bits, ce=>CE_Bits,tc=>TC_Bits);
	
	Detector: SIPORegister
	GENERIC MAP (N=>8)
	PORT MAP (clk=>clk, rst=>RST_Detector, se=>SE_Detector, data_in_serial=>DIN, data_out_parallel=>data_out_detector);
	
	Samples: SIPORegister
	GENERIC MAP (N=>3)
	PORT MAP (clk=>clk, rst=>RST_Samples, se=>SE_Samples, data_in_serial=>DIN, data_out_parallel=>data_out_samples);
	
	RX_OUT: SIPORegister
	GENERIC MAP (N=>9)
	PORT MAP (clk=>clk, rst=>RST_Out, se=>SE_Out, data_in_serial=>sampled_bit,
				data_out_parallel(8)=> DOUT(0),data_out_parallel(7)=> DOUT(1),data_out_parallel(6)=> DOUT(2),
				data_out_parallel(5)=> DOUT(3),data_out_parallel(4)=> DOUT(4),data_out_parallel(3)=> DOUT(5),
				data_out_parallel(2)=> DOUT(6),data_out_parallel(1)=> DOUT(7), data_out_parallel(0) => stop_bit);
	
	
	sampled_bit<= (data_out_samples(0) and data_out_samples(1)) or (data_out_samples(0) and data_out_samples(2)) or (data_out_samples(1) and data_out_samples(2)); 
	START_DETECTED<= data_out_detector(7) and data_out_detector(6) and data_out_detector(5) and data_out_detector(4) and (not(data_out_detector(3))) and (not(data_out_detector(2))) and (not(data_out_detector(1))) and (not(data_out_detector(0)));	
	TC2_steps<=TC_steps(1);
	TC4_steps<=TC_steps(2);
	TC6_steps<=TC_steps(1) and TC_steps(2);
		
	cambio_stato: process(clk)
	begin
		if(clk'event and clk='1') then
		case current_state is
			when detec_1 => if (TC_x8='1' and START_DETECTED='0' ) then next_state<=detec_2; 
								elsif(START_DETECTED='1') then next_state<=skip7_1; end if;
			when detec_2 => next_state<=detec_1;
			
			when skip7_1 => if (TC_x8='1' and TC6_steps='0') then next_state<=skip7_2;
							    elsif(TC_x8='1' and TC6_steps='1') then next_state<=skip7_3; end if;
			when skip7_2 => next_state<=skip7_1;
			when skip7_3 => next_state<=sample_1;
			
			when sample_1 => if (TC_x8='1' and TC2_steps='0' ) then next_state<=sample_2;
							     elsif(TC_x8='1' and TC2_steps='1') then next_state<=sample_3; end if;
			when sample_2 => next_state<=sample_1;
			when sample_3 => if (TC_bits='1') then next_state<=save_stop_bit; 
									elsif(TC_bits='0') then next_state<=save_bit; end if;
			
			when save_bit => next_state<=skip5_1;
			
			when skip5_1 => if (TC_x8='1' and TC4_steps='0') then next_state<=skip5_2;
							    elsif(TC_x8='1' and TC4_steps='1') then next_state<=skip5_3; end if;
			when skip5_2 => next_state<=skip5_1;
			when skip5_3 => next_state<=sample_1;
			
			when save_stop_bit => next_state<=control_stop_bit;
			when control_stop_bit => if (stop_bit='1') then next_state<=data_ready; 
										 elsif(stop_bit='0') then next_state<=reset; end if; 
					
			when data_ready => next_state<=reset;
			
			when reset => next_state<=detec_1;
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
		when detec_1 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0';	
		when detec_2 => SE_Detector<='1';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0';
			
	   when skip7_1 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
		when skip7_2 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='1';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
		when skip7_3 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='0';RST_Steps<='1';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
	
		when sample_1 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
		when sample_2 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='1';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='1';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0';
		when sample_3 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='1';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='0';RST_Steps<='1';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
			
		when save_bit => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='1';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='1';RST_Bits<='0'; RDY<='0'; 
			
		when skip5_1 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
		when skip5_2 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='1';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
		when skip5_3 => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='0';RST_x8<='1';	CE_Steps<='0';RST_Steps<='1';	CE_Bits<='0';RST_Bits<='0'; RDY<='0'; 
			
		when save_stop_bit => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='1';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0';
		when control_stop_bit => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='0';
			
		when data_ready => SE_Detector<='0';RST_Detector<='0'; SE_Samples<='0';RST_Samples<='0';SE_Out<='0';RST_Out<='0'; CE_x8<='1';RST_x8<='0';	CE_Steps<='0';RST_Steps<='0';	CE_Bits<='0';RST_Bits<='0'; RDY<='1';
			
		when reset => SE_Detector<='0';RST_Detector<='1'; SE_Samples<='0';RST_Samples<='1';SE_Out<='0';RST_Out<='1'; CE_x8<='0';RST_x8<='1'; CE_Steps<='0';RST_Steps<='1';	CE_Bits<='0';RST_Bits<='1'; RDY<='0'; 

		end case;
	end process;

end architecture;
	