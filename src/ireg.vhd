library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.numeric_std.all;

entity iReg is
    Port ( 
        d   : in STD_LOGIC_VECTOR (9 downto 0);
        clr : in STD_LOGIC;
        clk : in STD_LOGIC;
        flg : in STD_LOGIC;
        q   : out STD_LOGIC_VECTOR (9 downto 0)
    );
end iReg;

architecture Behavioral of iReg is
    
    signal q_t: std_logic_vector(9 downto 0); 

    begin
        process(d , clr, clk, flg)
            begin
                if clr = '1' then
                    q_t <= "0000000010";
                elsif clk'event and clk = '1' then
                    if flg = '1' then
                        q_t <= d + "0000000001";
                end if;
            end if;
        end process;

    q  <= q_t; 
end Behavioral;