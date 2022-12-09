library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gameController is 
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
        sRAM_dataSel    : out STD_LOGIC
    );
end gameController;

architecture behavior of gameController is
    -- Define internal types, signals, variables, and constants
    type state_type is (state0, state1, state2, state3);
    signal current_state    : state_type;
    signal next_state       : state_type;

    begin
        synch : process (clk, clr)
            begin
                if (clr = '1') then
                    current_state <= state0;
                elsif ((clk'event) and (clk = '1')) then
                    current_state <= next_state;
                end if;
        end process synch;

        C1: process (current_state, btn3, gmClk)
            begin
                case current_state is
                    -- Wait for user to press "start" button
                    when state0 =>
                        if (btn3 = '1') then
                            next_state <= state1;
                        else
                            next_state <= state0;
                        end if;

                    -- Load initial game values   
                    when state1 =>
                        next_state <= state2;

                    -- Write initial head value to snake RAM
                    when state2 =>
                        next_state <= state3;

                    -- Write initial tail value to snake RAM
                    when state3 =>
                        next_state <= state0;
                end case;
        end process C1;

        C2: process (current_state)
            begin
                -- Assign default values
                headAddrSel     <= '0';
                headAddrLd      <= '0';
                headBlkSel      <= "000";
                headBlkLd       <= '0';
                dirSel          <= '0';
                dirLd           <= '0';
                lenSel          <= '0';
                lenLd           <= '0';
                indexSel        <= '0';
                indexLd         <= '0';
                sRAM_we         <= '0';
                sRAM_oe         <= '0';
                sRAM_addrSel    <= '0';
                bodyAddrLd      <= '0';
                sRAM_dataSel    <= '0';

                -- State1: initialize game values
                if (current_state = state1) then
                    headAddrSel <= '1';
                    headAddrLd  <= '1';
                    headBlkLd   <= '1';
                    dirSel      <= '1';
                    dirLd       <= '1';
                    lenSel      <= '1';
                    lenLd       <= '1';
                    indexSel    <= '1';
                    indexLd     <= '1';
                end if; -- State1

                -- State2: initialize head value in sRAM
                if (current_state = state2) then
                    sRAM_we     <= '1';
                    indexLd     <= '1';
                    bodyAddrLd  <= '1';
                end if; -- State2

                -- State3: initialize tail value in sRAM
                if (current_state = state3) then
                    sRAM_addrSel    <= '1';
                    sRAM_we         <= '1';
                    sRAM_dataSel    <= '1';
                end if; -- State3

        end process C2;

end behavior;