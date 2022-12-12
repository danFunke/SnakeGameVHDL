library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity reg is
    generic (N : integer := 8);
    port (
        d       : in STD_LOGIC_VECTOR (N-1 downto 0);
        load    : in STD_LOGIC;
        clk     : in STD_LOGIC;
        clr     : in STD_LOGIC;
        q       : out STD_LOGIC_VECTOR (N-1 downto 0)
    );
end reg;

architecture behavior of reg is
    begin
        process (clk, clr, load)
            begin
                if (clr = '1') then
                    q <= (others => '0');
                elsif (clk'event) and (clk = '1') then
                    if (load = '1') then
                        q <= d;
                    end if;
                end if;
        end process;
end behavior;