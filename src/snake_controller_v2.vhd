library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_arith.all;

entity snake_controller_v2 is
    port (
        -- Inputs
        clr     : in STD_LOGIC;
        clk     : in STD_LOGIC;
        gClk    : in STD_LOGIC;

        keyVal  : in STD_LOGIC_VECTOR (7 downto 0);
        gDoutA  : in STD_LOGIC_VECTOR (1 downto 0);

        -- Outputs
        gAddrA  : out STD_LOGIC_VECTOR (9 downto 0);
        gDinA   : out STD_LOGIC_VECTOR (1 downto 0);
        gWenA   : out STD_LOGIC_VECTOR (0 downto 0);

        -- DEBUGGING
        ld      : out STD_LOGIC_VECTOR (9 downto 0);
        x       : out STD_LOGIC_VECTOR (31 downto 0)
    );
end snake_controller_v2;

architecture behavior of snake_controller_v2 is
    -- Declare internal components
    component sRAM
        port (
            -- Port A
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR (9 downto 0);
            dina    : in STD_LOGIC_VECTOR (9 downto 0);
            wea     : in STD_LOGIC_VECTOR (0 downto 0);
            douta   : out STD_LOGIC_VECTOR (9 downto 0);

            -- Port B
            clkb    : in STD_LOGIC;
            addrb   : in STD_LOGIC_VECTOR (9 downto 0);
            dinb    : in STD_LOGIC_VECTOR (9 downto 0);
            web     : in STD_LOGIC_VECTOR (0 downto 0);
            doutb   : out STD_LOGIC_VECTOR (9 downto 0)
        );
    end component;

    component reg
        generic (N : integer := 8);
        port (
            d       : in STD_LOGIC_VECTOR (N-1 downto 0);
            load    : in STD_LOGIC;
            clk     : in STD_LOGIC;
            clr     : in STD_LOGIC;
            q       : out STD_LOGIC_VECTOR (N-1 downto 0)
        );
    end component;

    -- Define internal types, signals, variables, and constants
    type state_type is (state0, state1, state2, state3, state3_1, state4, state5, state6, state7, state8, state9, state10, state11, state12, state13, state14, state15, state15_1, state15_2, state15_3, state15_4, state16, state17, waitForgClk);
    signal current_state    : state_type;
    signal next_state       : state_type;

    -- Snake head will always be at address zero
    constant HEAD_ADDR_RAM  : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    constant BLANK_CODE     : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant SNAKE_CODE     : STD_LOGIC_VECTOR (1 downto 0) := "01";
    constant APPLE_CODE     : STD_LOGIC_VECTOR (1 downto 0) := "10";
    constant WALL_CODE      : STD_LOGIC_VECTOR (1 downto 0) := "11";

    -- sRAM signals, PORT A
    signal sAddrA   : STD_LOGIC_VECTOR (9 downto 0);
    signal sDinA    : STD_LOGIC_VECTOR (9 downto 0);
    signal sWenA    : STD_LOGIC_VECTOR (0 downto 0);
    signal sDoutA   : STD_LOGIC_VECTOR (9 downto 0);

    -- sRAM signals, PORT B
    signal sAddrB   : STD_LOGIC_VECTOR (9 downto 0);
    signal sDinB    : STD_LOGIC_VECTOR (9 downto 0);
    signal sWenB    : STD_LOGIC_VECTOR (0 downto 0);
    signal sDoutB   : STD_LOGIC_VECTOR (9 downto 0);

    -- TempRegA signals
    signal tempRegALd   : STD_LOGIC;
    signal tempRegAOut  : STD_LOGIC_VECTOR (9 downto 0);

    -- gRAM Signals
    signal gRAMA_WEN    : STD_LOGIC_VECTOR (0 downto 0);
    signal gRAMB_WEN    : STD_LOGIC_VECTOR (0 downto 0);

    -- tempRegB Signals
    signal tempRegBin   : STD_LOGIC_VECTOR (9 downto 0);
    signal tempRegBout  : STD_LOGIC_VECTOR (9 downto 0);
    signal tempRegBld   : STD_LOGIC;

    -- tempRegC Signals
    signal tempRegCout  : STD_LOGIC_VECTOR (1 downto 0);
    signal tempRegCld   : STD_LOGIC;

    begin
        snakeRAM : sRAM
            port map (
                clka    => clk,
                addra   => sAddrA,
                dina    => sDinA,
                wea     => sWENA,
                douta   => sDoutA,
                clkb    => clk,
                addrb   => sAddrB,
                dinb    => sDinB,
                web     => sWENB,
                doutb   => sDoutB
            );

        -- DEBUGGING
        tempRegA : reg
            generic map (N => 10)
            port map (
                d => sDoutA,
                load => tempRegALd,
                clk => clk,
                clr => clr,
                q => tempRegAOut
            );

        tempRegB : reg
            generic map (N => 10)
            port map (
                d => tempRegBin,
                load => tempRegBld,
                clk => clk,
                clr => clr,
                q => tempRegBout
            );

        tempRegC : reg
            generic map (N => 2)
            port map (
                d => gDoutA,
                load => tempRegCld,
                clk => clk,
                clr => clr,
                q => tempRegCout
            );
        -- DEBUGGING

        synch : process (clk, clr)
            begin
                if (clr = '1') then
                    current_state <= state0;
                elsif ((clk'event) and (clk = '1')) then
                    current_state <= next_state;
                end if;
        end process synch;

        stateTransitionTable : process (current_state, gClk, tempRegCout)
            begin
                case current_state is
                    when state0 =>
                        next_state <= state1;

                    when state1 =>
                        next_state <= state2;
                        
                    when state2 =>
                        next_state <= state3;

                    when state3 =>
                        next_state <= state3_1;

                    when state3_1 =>
                        next_state <= state4;

                    when state4 =>
                        next_state <= state5;

                    when state5 =>
                        next_state <= state6;

                    when state6 =>
                        next_state <= state7;

                    when state7 =>
                        next_state <= state8;

                    when state8 =>
                        next_state <= state9;

                    when state9 =>
                        next_state <= state10;

                    when state10 =>
                        next_state <= state11;

                    when state11 =>
                        next_state <= state12;
                    
                    when state12 =>
                        next_state <= state13;

                    when state13 =>
                        next_state <= state14;

                    when state14 =>
                        if (tempRegCout = "00") then
                            next_state <= state15;
                        elsif (tempRegCout = "10") then
                            next_state <= state16;
                        else
                            next_state <= state17;
                        end if;

                    when state15 =>
                        -- Move normally
                        next_state <= state15_1;
                    
                    when state15_1 =>
                        -- Move normally
                        next_state <= state15_2;

                        when state15_2 =>
                        -- Move normally
                        next_state <= state15_3;

                        when state15_3 =>
                        -- Move normally
                        next_state <= state15_4;

                        when state15_4 =>
                        -- Move normally
                        next_state <= waitForgClk;

                    when state16 =>
                        -- Eat apple
                        next_state <= state15;

                    when state17 =>
                        -- Game Over

                    when waitForgClk =>
                        if ((gClk'event) and (gClk = '1')) then
                            next_state <= state0;
                        end if;
                        

                end case;
        end process stateTransitionTable;

        stateBehaviorTable  : process (current_state, keyVal, sDoutA, tempRegAout, tempRegBout, tempRegCout)
            -- Declare process variables
            variable headAddressBlk : STD_LOGIC_VECTOR (9 downto 0);
            variable tailAddressBlk : STD_LOGIC_VECTOR (9 downto 0);

            begin
                -- Set default values
                sWenA <= "0";
                sWenB <= "0";
                gRAMA_WEN <= "0";
                gRAMA_WEN <= "0";
                tempRegALd <= '0';
                tempRegBLd <= '0';
                tempRegCLd <= '0';


                if (current_state = state0) then
                    sAddrA <= "0000000001"; -- Put tail address on sRAM PORT A address bus

                    -- DEBUGGING
                    ld <= "0000000000";
                    x <= "0000000000000000000000" & "0000000001";

                elsif (current_state = state1) then
                    -- wait for data

                    -- DEBUGGING
                    ld <= "0000000001";
                    x <= "0000000000000000000000" & sDoutA;
  
                elsif (current_state = state2) then
                    -- Clock tail block address into tempRegA
                    tempRegALd <= '1';

                    -- DEBUGGING
                    ld <= "0000000010";
                    x <= "0000000000000000000000" & sDoutA;

                elsif (current_state = state3) then
                    -- Valid Tail Block Address in tempRegA, write to temp tail
                    sAddrB <= "0000000010";
                    sDinB <= tempRegAout;
                    sWenB <= "1";

                    -- DEBUGGING
                    ld <= "0000000011";
                    x <= "0000000000000000000000" & tempRegAout;

                elsif (current_state = state3_1) then
                    sAddrA <= "0000000000"; -- Put head address on sRAM PORT A address bus

                    -- DEBUGGING
                    ld <= "0000000100";
                    x <= "0000000000000000000000" & "0000000000";

                elsif (current_state = state4) then
                    -- wait for data
                
                    -- DEBUGGING
                    ld <= "0000000101";
                    x <= "0000000000000000000000" & sDoutA;

                elsif (current_state = state5) then
                    -- Clock head block address into tempRegA
                    tempRegALd <= '1';

                    -- DEBUGGING
                    ld <= "0000000110";
                    x <= "0000000000000000000000" & sDoutA;

                elsif (current_state = state6) then
                    -- Valid Head Block address in tempRegA, write to tail
                    sAddrB <= "0000000001";
                    sDinB <= tempRegAout;
                    sWenB <= "1";

                    -- DEBUGGING
                    ld <= "0000000111";
                    x <= "0000000000000000000000" & tempRegAout;
                
                elsif (current_state = state7) then
                    -- Update Head Block address based on keyVal, write to head in sRAM
                    sAddrB <= "0000000000";

                    if (keyVal = X"72") then
                        sDinB <= tempRegAout + 40;  -- DOWN
                    elsif (keyVal = X"6B") then
                        sDinB <= tempRegAout - 1;   -- LEFT
                    elsif (keyVal = X"74") then
                        sDinB <= tempRegAout + 1;   -- RIGHT
                    else
                        sDinB <= tempRegAout - 40;  -- Default UP
                    end if;

                    sWenb <= "1";

                    -- DEBUGGING
                    ld <= "0000001000";
                    x <= "0000000000000000000000" & tempRegAout;

                elsif (current_state = state8) then
                    -- Read new Head Block Address from sRAM
                    sAddrA <= "0000000000";

                    -- DEBUGGING
                    ld <= "0000001001";
                    x <= "0000000000000000000000" & "0000000000";

                elsif (current_state = state9) then
                    -- wait for data

                    -- DEBUGGING
                    ld <= "0000001010";
                    x <= "0000000000000000000000" & sDoutA;

                elsif (current_state = state10) then
                    -- Clock head block address into tempRegA
                    tempRegALd <= '1';

                    -- DEBUGGING
                    ld <= "0000001011";
                    x <= "0000000000000000000000" & sDoutA;

                elsif (current_state = state11) then
                    -- Valid Head Block address in tempRegA, put on gAddrA
                    gAddrA <= tempRegAout;

                    -- DEBUGGING
                    ld <= "0000001100";
                    x <= "0000000000000000000000" & tempRegAout;

                elsif (current_state = state12) then
                    -- wait for gData

                    -- DEBUGGING
                    ld <= "0000001101";
                    x <= "000000000000000000000000000000" & gDoutA;

                elsif (current_state = state13) then
                    -- Clock gData into tempRegC
                    tempRegCLd <= '1';

                    -- DEBUGGING
                    ld <= "0000001110";
                    x <= "000000000000000000000000000000" & gDoutA;

                elsif (current_state = state14) then
                    -- Valid data in tempRegC; decide what to do next

                    -- DEBUGGING
                    ld <= "0000001111";
                    x <= "000000000000000000000000000000" & tempRegCout;

                elsif (current_state = state15) then
                    -- MOVE NORMAL, start updating board at head
                    gDinA <= "01";
                    gRAMA_WEN <= "1";

                    -- DEBUGGING
                    ld <= "0000010000";
                    x <= X"0000000" & X"F";

                elsif (current_state = state15_1) then
                    -- Get old tail block address
                    sAddrA <= "0000000010";

                    -- DEBUGGING
                    ld <= "0000010000";
                    x <= X"0000000" & X"F";

                elsif (current_state = state15_2) then
                    -- wait for data

                    -- DEBUGGING
                    ld <= "0000010000";
                    x <= X"0000000" & X"F";

                elsif (current_state = state15_3) then
                    -- Clock data into tempRegA
                    tempRegALd <= '1';

                    -- DEBUGGING
                    ld <= "0000010000";
                    x <= "0000000000000000000000" & tempRegAout;

                elsif (current_state = state15_4) then
                    -- valid data in tempRegA, put on gAddrA and clear contents
                    gAddrA <= tempRegAout;
                    gDinA <= "00";
                    gRAMA_WEN <= "1";

                    -- DEBUGGING
                    ld <= "0000010000";
                    x <= "0000000000000000000000" & tempRegAout;
                
                elsif (current_state = state16) then
                    -- APPLE!

                    -- DEBUGGING
                    ld <= "0000010001";
                    x <= X"000000" & X"10";

                elsif (current_state = state17) then
                    -- GAME OVER

                    -- DEBUGGING
                    ld <= "0000010010";
                    x <= X"000000" & X"11";

                elsif (current_state = waitForgClk) then

                end if;

                gWenA <= gRAMA_WEN;
        end process stateBehaviorTable;
        
end behavior;