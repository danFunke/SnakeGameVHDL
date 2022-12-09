library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gameController_tb is
end gameController_tb;

architecture behavior of gameController_tb is
    -- Declare internal components
    component gameController
        port (
            -- Inputs
            clk     : in STD_LOGIC;
            clr     : in STD_LOGIC;
            btn3    : in STD_LOGIC;
            gmClk   : in STD_LOGIC;

            -- Outputs
            headAddrSel     : out STD_LOGIC;
            headAddrLd      : out STD_LOGIC;
            headBlkSel      : out STD_LOGIC_VECTOR (2 downto 0);
            headBlkLd       : out STD_LOGIC;
            dirSel          : out STD_LOGIC;
            dirLd           : out STD_LOGIC;
            lenSel          : out STD_LOGIC;
            lenLd           : out STD_LOGIC;
            indexSel        : out STD_LOGIC;
            indexLd         : out STD_LOGIC;
            sRAM_we         : out STD_LOGIC;
            sRAM_oe         : out STD_LOGIC;
            sRAM_addrSel    : out STD_LOGIC;
            bodyAddrLd      : out STD_LOGIC;
            sRAM_DataSel    : out STD_LOGIC
        );
    end component;

    -- Test input signals
    signal clk_tb   : STD_LOGIC;
    signal clr_tb   : STD_LOGIC;
    signal btn3_tb  : STD_LOGIC;
    signal gmClk_tb : STD_LOGIC;

    -- Test output signals
    signal headAddrSel_tb   : STD_LOGIC;
    signal headAddrLd_tb    : STD_LOGIC;
    signal headBlkSel_tb    : STD_LOGIC_VECTOR (2 downto 0);
    signal headBlkLd_tb     : STD_LOGIC;
    signal dirSel_tb        : STD_LOGIC;
    signal dirLd_tb         : STD_LOGIC;
    signal lenSel_tb        : STD_LOGIC;
    signal lenLd_tb         : STD_LOGIC;
    signal indexSel_tb      : STD_LOGIC;
    signal indexLd_tb       : STD_LOGIC;
    signal sRAM_we_tb       : STD_LOGIC;
    signal sRAM_oe_tb       : STD_LOGIC;
    signal sRAM_addrSel_tb  : STD_LOGIC;
    signal bodyAddrLd_tb    : STD_LOGIC;
    signal sRAM_dataSel_tb  : STD_LOGIC;

    -- Define constants
    constant period : time := 10 ns;

    begin
        -- Port map internal components
        uut : gameController
            port map (
                -- Inputs
                clk     => clk_tb,
                clr     => clr_tb,
                btn3    => btn3_tb,
                gmClk   => gmClk_tb,

                -- Outputs
                headAddrSel     => headAddrSel_tb,
                headAddrLd      => headAddrLd_tb,
                headBlkSel      => headBlkSel_tb,
                headBlkLd       => headBlkLd_tb,
                dirSel          => dirSel_tb,
                dirLd           => dirLd_tb,
                lenSel          => lenSel_tb,
                lenLd           => lenLd_tb,
                indexSel        => indexSel_tb,
                indexLd         => indexLd_tb,
                sRAM_we         => sRAM_we_tb,
                sRAM_oe         => sRAM_oe_tb,
                sRAM_addrSel    => sRAM_addrSel_tb,
                bodyAddrLd      => bodyAddrLd_tb,
                sRAM_dataSel    => sRAM_dataSel_tb
            );

        -- Standard clock process
        clock : process
            begin
                clk_tb <= '0';
                wait for (period / 2);
                clk_tb <= '1';
                wait for (period / 2);
        end process clock;

        -- Game clock process
        gmClock : process
            begin
                gmClk_tb <= '0';
                wait for (period * 5);
                gmClk_tb <= '1';
                wait for (period * 5);
        end process gmClock;

        -- Test process
        test : process
            begin
                clr_tb <= '1';
                btn3_tb <= '0';
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