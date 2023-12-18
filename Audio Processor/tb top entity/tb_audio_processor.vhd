library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use STD.textio.all;
use ieee.std_logic_textio.all;


entity tb_audio_processor is
end entity;

architecture behavioral of tb_audio_processor is

component Audio_Processor is 
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
end component;

signal clk_tb: std_logic;
signal START_tb :std_logic;
signal RST_tb   :std_logic;
signal SW_0_tb:std_logic;
signal SW_1_tb:std_logic;
signal DIN_tb :std_logic_vector(7 downto 0);
signal DOUT_tb :std_logic_vector(7 downto 0);
signal DIN_tb_sfixed	 :sfixed(-1 downto -8);
signal DOUT_tb_sfixed	 :sfixed(-1 downto -8);
signal DONE_tb   :std_logic;

file file_VECTORS : text;
file file_RESULTS : text;

  
begin
Audio_prova :Audio_Processor
port map(clk=>clk_tb,RST=>RST_tb,START=>START_tb,SW_0=>SW_0_tb,SW_1=>SW_1_tb,DIN=>DIN_tb,DOUT=>DOUT_tb,DONE=>DONE_tb);


DIN_tb<=to_slv(DIN_tb_sfixed);

DOUT_tb_sfixed<=to_sfixed(DOUT_tb,DOUT_tb_sfixed);

clock: PROCESS
		BEGIN
			clk_tb<='0';
			WAIT FOR 10 ns;
			clk_tb<='1';
			WAIT FOR 10 ns;
END PROCESS clock;
		

control: process
begin
	RST_tb<='0', '1' after 50 ns;
	SW_0_tb<='0';
	SW_1_tb<='1';
	wait for 1000 ms;
end process;

start_signal: process
begin
	START_tb<='0'; 
	wait for 5 us;
	START_tb<='1';
	wait for 15 us;
	START_tb<='0'; 
	wait for 5 us;
end process;	
			
		
-- Process for:
-- 1) Reading input stimuli from file
-- 2) Writing sum results to file
inputfile: process
    variable v_ILINE     : line;
    variable v_OLINE     : line;
    variable v_ADD_TERM1 : real;
     
  begin
    -- Opening input and output files in read/write modes
    file_open(file_VECTORS, "inputs.txt",  read_mode);
    file_open(file_RESULTS, "outputs.txt", write_mode);
 
	readline(file_VECTORS, v_ILINE);
      read(v_ILINE, v_ADD_TERM1);       -- get first input

	  
      -- Pass the variable to a signal to allow the ripple-carry to use it
      DIN_tb_sfixed <= to_sfixed(v_ADD_TERM1,DIN_tb_sfixed);
    -- Read input stimuli from file input_vectors.txt
		
	wait for 7 us;
	
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE);
      read(v_ILINE, v_ADD_TERM1);       -- get first input

	  
      -- Pass the variable to a signal to allow the ripple-carry to use it
      DIN_tb_sfixed <= to_sfixed(v_ADD_TERM1,DIN_tb_sfixed);
 
      wait for 25  us;
 
     -- Write output result to file output_results.txt
      write(v_OLINE, to_real(DOUT_tb_sfixed));
      writeline(file_RESULTS, v_OLINE);
	  
    end loop;
 
    -- Closin In/Out files
    file_close(file_VECTORS);
    file_close(file_RESULTS);
     
    wait;
  end process;

end architecture;