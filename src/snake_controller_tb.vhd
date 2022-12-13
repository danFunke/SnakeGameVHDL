library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity snake_controller_tb is
end snake_controller_tb;

architecture tb of snake_controller_tb is
    -- Declare internal components
    component snake_controller_v2
        port (
            -- Inputs
            clr     : in STD_LOGIC;
            clk     : in STD_LOGIC;
            gClk    : in STD_LOGIC;

            keyVal  : in STD_LOGIC_VECTOR (7 downto 0);
            gDoutA  : in STD_LOGIC_VECTOR (1 downto 0);
            seed    : in STD_LOGIC_VECTOR (9 downto 0);

            -- Outputs
            gAddrA  : out STD_LOGIC_VECTOR (9 downto 0);
            gDinA   : out STD_LOGIC_VECTOR (1 downto 0);
            gWenA   : out STD_LOGIC_VECTOR (0 downto 0);

            -- DEBUGGING
            ld      : out STD_LOGIC_VECTOR (9 downto 0);
            x       : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

    component gRAM
        port (
            -- Port A
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR (9 downto 0);
            dina    : in STD_LOGIC_VECTOR (1 downto 0);
            wea     : in STD_LOGIC_VECTOR (0 downto 0);
            douta   : out STD_LOGIC_VECTOR (1 downto 0);

            -- Port B
            clkb    : in STD_LOGIC;
            addrb   : in STD_LOGIC_VECTOR (9 downto 0);
            dinb    : in STD_LOGIC_VECTOR (1 downto 0);
            web     : in STD_LOGIC_VECTOR (0 downto 0);
            doutb   : out STD_LOGIC_VECTOR (1 downto 0)
        );
    end component;

    -- Declare test signals
    signal clk_tb           : STD_LOGIC;
    signal clr_tb           : STD_LOGIC;
    signal gClk_tb          : STD_LOGIC;
    signal keyVal_tb        : STD_LOGIC_VECTOR (7 downto 0);
    signal sw_tb            : STD_LOGIC_VECTOR (9 downto 0);

    -- gRAM signals, PORT A
    signal gAddrA   : STD_LOGIC_VECTOR (9 downto 0);
    signal gDinA    : STD_LOGIC_VECTOR (1 downto 0);
    signal gWenA    : STD_LOGIC_VECTOR (0 downto 0);
    signal gDoutA   : STD_LOGIC_VECTOR (1 downto 0);

    -- sRAM signals, PORT B
    signal gAddrB   : STD_LOGIC_VECTOR (9 downto 0);
    signal gDinB    : STD_LOGIC_VECTOR (1 downto 0);
    signal gWenB    : STD_LOGIC_VECTOR (0 downto 0);
    signal gDoutB   : STD_LOGIC_VECTOR (1 downto 0);

    -- Constants
    constant period     : time := 40 ns; -- 25 MHz clock
    constant gPeriod    : time := 2000 ns; -- faux game clock

    begin
        uut : snake_controller_v2
            port map (
                -- Inputs
                clr     => clr_tb,
                clk     => clk_tb,
                gClk    => gClk_tb,

                keyVal => keyVal_tb,
                gDoutA => gDoutA,
                seed   => sw_tb,

                -- Outputs
                gAddrA => gAddrA,
                gDinA => gDinA,
                gWenA => gWenA,

                -- DEBUGGING
                ld => open,
                x => open
            );

        gameRAM : gRAM
            port map (
                clka    => clk_tb,
                addra   => gAddrA,
                dina    => gDinA,
                wea     => gWENA,
                douta   => gDoutA,
                clkb    => clk_tb,
                addrb   => gAddrB,
                dinb    => gDinB,
                web     => gWENB,
                doutb   => gDoutB
            );
        

        clock : process
            begin
                clk_tb <= '1';
                wait for (period / 2);
                clk_tb <= '0';
                wait for (period / 2);
        end process clock;

        gClock : process
            begin
                gClk_tb <= '1';
                wait for (gPeriod / 2);
                gClk_tb <= '0';
                wait for (gPeriod / 2);
        end process gClock;

        test : process
            begin
                clr_tb <= '1';
                keyVal_tb <= X"75";
                sw_tb <= "0000000000";
                wait for period;

                clr_tb <= '0';
                wait;
        end process test;

end tb;