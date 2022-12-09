library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gameController_tb is
end gameController_tb;

architecture behavior of gameController_tb is
    -- Declare internal components
    component gameController
        port (
            clk     : in STD_LOGIC;
            clr     : in STD_LOGIC;
            btn3    : in STD_LOGIC
        );
    end component;

    -- Delcare test signals
    signal clk_tb   : STD_LOGIC;
    signal clr_tb   : STD_LOGIC;
    signal btn3_tb  : STD_LOGIC;

    -- Define constants
    constant period : time := 10 ns;

    begin
        -- Port map internal components
        uut : gameController
            port map (
                clk     => clk_tb,
                clr     => clr_tb,
                btn3    => btn3_tb
            );

        -- Standard clock process
        clock : process
            begin
                clk_tb <= '0';
                wait for (period / 2);
                clk_tb <= '1';
                wait for (period / 2);
        end process clock;

        -- Test process
        test : process
            begin
                clr_tb <= '1';
                wait for period;
                
                -- Clock cycle 1
                clr_tb <= '0';
                wait for (period * 10);

                -- Clock cycle 11
                btn3_tb <= '1';
                wait for period;

                -- clock cycle 12
                btn3_tb <= '0';
                
                wait;
        end process test;

end behavior;