----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:36:04 04/23/2023 
-- Design Name: 
-- Module Name:    lcd_driver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd_driver is

  PORT(
	clk : in std_logic;
	lcd_rs,lcd_rw,lcd_e : out std_logic;
	lcd_d : out std_logic_vector(3 downto 0);
	reset_display : in std_logic;
	line1_buffer : IN STD_LOGIC_VECTOR(127 downto 0); 
	line2_buffer : IN STD_LOGIC_VECTOR(127 downto 0);
	SF_CE0 : out std_logic
  ); 
end lcd_driver;
architecture Behavioral of lcd_driver is

  TYPE CONTROL IS(power_up, init,resetline, line1, line2 ,send);
  SIGNAL  state  : CONTROL;
  signal ptr : natural range 0 to 16 := 15;
  signal lcd_data_1st, lcd_data_2nd : std_logic_vector (3 downto 0);
   SIGNAL 	line		  : STD_LOGIC := '1';
begin
	lcd_rw <= '0';
	SF_CE0 <= '1'; --disable strata flash
	
	process(clk)
	variable cnt : integer := 0;
	begin
	if rising_edge (clk) then 
		case state is 
			
			when power_up =>
				lcd_rs <= '0';
				cnt := cnt + 1;
				if cnt = 750000 then
				lcd_d <= "0011";
				lcd_e <= '1';
				
				elsif cnt = 750012 then --pulse e high for 12 clock cycles
				
				lcd_e <= '0';
				
				elsif cnt = 1000000 then 
				lcd_d <= "0011";
				lcd_e <= '1';
				elsif cnt = 1000012 then 
				lcd_e <= '0';
				elsif cnt = 1006000 then 
				lcd_d <= "0011";
				lcd_e <= '1';
				elsif cnt = 1006012 then
				lcd_e <= '0';
				elsif cnt = 1009000 then
				lcd_d <= "0011";
				lcd_e <= '1';
				elsif cnt = 1009012 then 
				lcd_e <= '0';
				elsif cnt = 1012000 then 
				lcd_d <= "0010";
				lcd_e <= '1';
				elsif cnt = 1012012 then
				lcd_e <= '0';
				elsif cnt = 1100000
				then 
				state <= init;
				cnt := 0;
				else 
					--
				end if;
			
			when init => 
				cnt := cnt + 1;
				lcd_rs <= '0';
				if cnt = 100 then 
					lcd_d <= "0010";  --send 0x28 1st part
					lcd_e <= '1';
					
				elsif cnt = 5000 then --Wait 100 탎 or longer, which is 5,000 clock cycles at 50 MHz.
					lcd_e <= '0';
					
				elsif cnt = 10000 then --send 0x28 2nd part
					lcd_d <= "1000";
					lcd_e <= '1';
					
				elsif cnt = 15000 then --Wait 100 탎
					lcd_e <= '0';
					
				elsif cnt = 20000 then --Issue an Entry Mode Set command, 0x06 1st part
					lcd_d <= "0000";
					lcd_e <= '1';
					
				elsif cnt = 25000 then --Wait 100 탎
					lcd_e <= '0';
					
				elsif cnt = 30000 then -- Issue an Entry Mode Set command, 0x06 2nd part
					lcd_d <= "0110"; 
					lcd_e <= '1';
					
				elsif cnt = 35000 then --Wait 100 탎
					lcd_e <= '0';
					
				elsif cnt = 40000 then --display on command 0x0C first part
					lcd_d <= "0000";
					lcd_e <= '1';
					
				elsif cnt = 45000 then 
					lcd_e <= '0';
					
				elsif cnt = 50000 then --display on command 0x0C second part
					lcd_d <= "1100";
					lcd_e <= '1'; 
					
				elsif cnt = 55000 then
					lcd_e <= '0';
					
				elsif cnt = 60000 then --clear display 1st part , 0x01
					lcd_d <= "0000";
					lcd_e <= '1';
					
				elsif cnt = 65000 then 
					lcd_e <='0';
				
				elsif cnt = 70000 then  --clear display 2nd part , 0x01
					lcd_d <= "0001";
					lcd_e <= '1';
				elsif cnt = 75000 then
					lcd_e <= '0';
		
				
				
				elsif cnt = 190000  then  -- wait for more than 1.64 ms
					state <= resetline;
					cnt := 0;
				end if;
				
				
			when resetline => 
					ptr <= 16;
					if line = '1' then 
						lcd_data_1st <= "1000"; 
						lcd_data_2nd <= "0000";
						lcd_rs <= '0';
						lcd_rw <= '0';
						state <= send;
					else
						lcd_data_1st <= "1100"; 
						lcd_data_2nd <= "0000";
						lcd_rs <= '0';
						lcd_rw <= '0';
						state <= send;
					end if;
			when line1 => 
						lcd_data_1st <= line1_buffer(ptr*8 + 7 downto ptr*8 + 4);
						lcd_data_2nd <= line1_buffer(ptr*8 + 3 downto ptr*8);
						lcd_rs <= '1';
						lcd_rw <= '0';
						cnt := 0; 
						line <= '1';
						state <= send;
			when line2 =>
						line <= '0';
						lcd_data_1st <= line2_buffer(ptr*8 + 7 downto ptr*8 + 4);
						lcd_data_2nd <= line2_buffer(ptr*8 + 3 downto ptr*8);
						lcd_rs <= '1';
						lcd_rw <= '0';
						cnt := 0;            
						state <= send;
		  
		  
	
			when send=>
										
					if cnt < 5000 then 
					cnt := cnt + 1;
						if cnt = 50 then
							lcd_e <='0';
						elsif cnt = 700 then  -- send upper nibble
							lcd_e <= '1';
							lcd_d <= lcd_data_1st;
						elsif cnt = 1350 then 
							lcd_e <= '0';
						elsif cnt = 2050 then --send lower nibble
							lcd_d <= lcd_data_2nd;
							lcd_e <= '1';
						elsif cnt = 2750 then 
							lcd_e <= '0';
						
						end if;
						
					else 
						cnt := 0;
						if line = '1' then
							if ptr = 0 then
									line <= '0';
									state <= resetline;
							else
								ptr <= ptr - 1;
								state <= line1;
							end if;
						else 
							if ptr = 0 then
								line <= '1';
								state <= resetline;
							else
								ptr <= ptr - 1;
								state <= line2;
							end if;
						end if;
						
					end if;

		
		end case;
		
		if reset_display = '1' then --display reset
			state <= power_up;
		end if;
		
	end if;
	end process ;
end Behavioral;

