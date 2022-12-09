library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gameController is 
    port (
        clk     : in STD_LOGIC;
        clr     : in STD_LOGIC;
        btn3    : in STD_LOGIC
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

        C1: process (current_state, btn3)
            begin
                case current_state is
                    when state0 =>
                        if (btn3 = '1') then
                            next_state <= state1;
                        else
                            next_state <= state0;
                        end if;
                    when state1 =>
                        next_state <= state2;
                    when state2 =>
                        next_state <= state3;
                    when state3 =>
                        next_state <= state0;
                end case;
        end process C1;

end behavior;