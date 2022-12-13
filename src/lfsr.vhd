library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr is
    port ( 
        clk     : in STD_LOGIC;
        clr     : in STD_LOGIC;
        en      : in STD_LOGIC;
        seed    : in STD_LOGIC_VECTOR (9 downto 0);
        Q       : out STD_LOGIC_VECTOR (9 downto 0)
    );
end lfsr;

architecture behavior of lfsr is
    -- Delcare internal signals
    signal Qt   : STD_LOGIC_VECTOR (9 downto 0) := "0000000001";

    begin

    process (clk)
        -- Declare process variables
        variable tmp : STD_LOGIC := '0';
        
        begin

        if (clk'event and clk = '1') then
            if (clr = '1') then
                Qt <= seed; 
            elsif en = '1' then
                tmp := Qt(6) XOR Qt(4) XOR Qt(3) XOR Qt(2) XOR Qt(0);
                Qt  <= tmp & Qt(9 downto 1);
            end if;
        end if;
    end process;

    Q <= Qt;

end behavior;