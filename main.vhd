----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:35:49 04/23/2023 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
	
	port(
		clk : in std_logic;
		sw : in std_logic;
		lcd_rs,lcd_rw,lcd_e : out std_logic;
		lcd_d : out std_logic_vector(3 downto 0);
		reset_n : in std_logic;
		SF_CE0 : out std_logic --D16 physical pin 
	);

end main;

architecture Behavioral of main is

	component lcd_driver 
	
	  PORT(
	clk : in std_logic;
	lcd_rs,lcd_rw,lcd_e : out std_logic;
	lcd_d : out std_logic_vector(3 downto 0);
	reset_display : in std_logic;
	line1_buffer : IN STD_LOGIC_VECTOR(127 downto 0); 
	line2_buffer : IN STD_LOGIC_VECTOR(127 downto 0);
	SF_CE0 : out std_logic
  ); 
	
	end component;
	
	signal line1_buffer, line2_buffer: std_logic_vector (127 downto 0);
	
	

begin
	line1_buffer <= x"7F2048454c4c4f20202020202020207E";
	line2_buffer <= x"7E20574f524c4420202020202020207F";



U1: lcd_driver port map (	clk => clk,
									lcd_rs => lcd_rs, lcd_rw => lcd_rw, 
									lcd_e => lcd_e, 
									lcd_d => lcd_d, 
									reset_display => sw , 
									line1_buffer => line1_buffer, 
									line2_buffer => line2_buffer, 
									SF_CE0 =>SF_CE0 );
end Behavioral;

