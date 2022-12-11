library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity ClkDiv is
	 port(
		 mclk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 clk6 : out STD_LOGIC;
		 clk25 : out STD_LOGIC
	     );
end ClkDiv;

architecture ClkDiv of ClkDiv is

signal q: STD_LOGIC_VECTOR(23 downto 0);

begin

	-- clock divider
	process(mclk, clr)
	begin
		if clr = '1' then
			q <= X"000000";
		elsif mclk'event and mclk = '1' then
			q <= q - 1;
		end if;
	end process;

	clk25 <= q(1);			-- 25 MHz  40 ns
    clk6 <= q(23);			-- 190 Hz  

end ClkDiv;