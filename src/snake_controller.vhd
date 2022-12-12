library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

 entity snake_controller is
  port (
            clk25           : in STD_LOGIC;
            clk6            : in STD_LOGIC;
            clr             : in STD_LOGIC;
            go              : in STD_LOGIC;
            

            keyval          : in STD_LOGIC_VECTOR(7 downto 0); -- from keyboard
            gdoutb          : in STD_LOGIC_VECTOR(1 downto 0); -- game data out
            sdouta          : in STD_LOGIC_VECTOR(9 downto 0); -- snake data out
            sdoutb          : in STD_LOGIC_VECTOR(9 downto 0); -- snake data out
            snake_count_out : in STD_LOGIC_VECTOR(9 downto 0); -- Length of snake

            ld              : out STD_LOGIC_VECTOR (9 downto 0);
            appleflgout     : out STD_LOGIC; -- increment score
            blankflgout     : out STD_LOGIC; -- if nothing is there
            gameoverflgout  : out STD_LOGIC;
            sweb            : out STD_LOGIC_VECTOR(0 DOWNTO 0); -- snake write enable port b
            gweb            : out STD_LOGIC_VECTOR(0 DOWNTO 0);-- game write enable b
            gdinb           : out STD_LOGIC_VECTOR(1 downto 0); -- game data in on b
            saddrb          : out STD_LOGIC_VECTOR(9 downto 0); -- snake address port b
            sdinb           : out STD_LOGIC_VECTOR(9 downto 0); -- snake data in port b
            gaddrb          : out STD_LOGIC_VECTOR(9 downto 0); -- game address port b
            saddra          : out STD_LOGIC_VECTOR(9 downto 0)  -- snake address port a
        );
end snake_controller;

architecture Behavioral of snake_controller is
   
--    type state_type is (start, findhead, nextblock, checkboard, updatesnake, updatesnake2, headupdate,headupdate2, updatebrdhead, updatebrdhead2, updatebrdhead3,updatebrdtail, updatebrdtail2,updatebrdtail3, waitforgmclk, decrement);
    -- type state_type is (state0, state1, state2, state3, state4, state5, state6) --state7, state8, state9, state10, state11, state12, state13, state14);
    -- signal present_state, next_state : state_type;
    signal ld1,ld4, aflg, goflg, blnkflg: STD_LOGIC;
--    signal nexthead: STD_LOGIC_VECTOR(9 downto 0);
    signal count: STD_LOGIC_VECTOR(9 downto 0):="0000000010";
    shared variable saddr_head, saddr_tail :  STD_LOGIC_VECTOR(9 downto 0);
    shared variable saddr :  STD_LOGIC_VECTOR(9 downto 0);
    shared variable numb1: STD_LOGIC_VECTOR(9 downto 0);
    shared variable nexthead: STD_LOGIC_VECTOR(9 downto 0);
    shared variable currentBlockCode: STD_LOGIC_VECTOR(1 downto 0);
    

    -- type state_type is (state0, state1, state2, state3, state4, state5, state6, state7, state8, state9, checkboard0, checkboard1, stateUpdateHeadRam);
    type state_type is (state0, state1, state2); --, state3, state4, state5, state6, state7, state8, state9, checkboard0, checkboard1, stateUpdateHeadRam);
    signal present_state    : state_type;
    signal next_state       : state_type;

    begin
        synch : process (clk25, clr)
            begin
                if (clr = '1') then
                    present_state <= state0;
                elsif ((clk25'event) and (clk25 = '1')) then
                    present_state <= next_state;
                end if;
        end process synch;

    stateTransitionTable : process (clk6, present_state)
        begin
            -- case present_state is
            --     when state0 =>
            --         next_state <= state1;
                    
            --     when state1 =>
            --         next_state <= state2; 

            --     when state2 =>
            --         next_state <= state3;

            --     when state3 =>
            --         next_state <= state4;

            --     when state4 =>
            --         next_state <= checkBoard0;

            --     when checkBoard0 =>
            --         next_state <= checkBoard1;

            --     when checkBoard1 =>
            --         next_state <= stateUpdateHeadRam;

            --     when stateUpdateHeadRam =>
            --         next_state <= state5;

            --     when state5 =>  
            --         next_state <= state6;

            --     when state6 =>
            --         next_state <= state7;

            --     when state7 =>
            --         next_state <= state8;

            --     when state8 =>
            --         next_state <= state9;

            --     when state9 =>
            --         if clk6'event and clk6 = '1' then
            --             next_state <= state0;
            --         end if;


            -- end case;                    
    end process stateTransitionTable;

-- c2 : process (present_state, keyval)
--     begin
--         if (present_state = state0) then
--             -- Put snake head RAM address on sRAM Port A address bus
--             saddra <= "0000000001";
            
--             -- Set write vals
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state1) then
--             -- Read tail block address into variable
--             saddr_tail := sdouta;

--             -- put block address on game write bus
--             gaddrb <= saddr_tail;
--             gdinb <= "00";
            
--             -- set write vals
--             sweb <= "0";
--             gweb <= "1";

--         elsif (present_state = state2) then
--             -- Put head RAM address on READ address bus
--             saddra <= "0000000000";
            
--             -- set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state3) then
--             -- Read head block address into variable
--             saddr_head := sdouta;

--             -- put tail address on WRITE address bus, put head block address on WRITE data bus
--             saddrb <= "0000000001";
--             sdinb <= saddr_head;

--             -- Set write states
--             sweb <= "1";
--             gweb <= "0";

--         elsif (present_state = state4) then
--             -- Update saddr based on keyval
--             if keyval = X"75" then      -- UP 
--                 saddr_head := sdouta - 40;
--             elsif keyval = X"72" then   -- DOWN 
--                 saddr_head := sdouta + 40;
--             elsif keyval = X"6B" then   -- LEFT
--                 saddr_head := sdouta - 1;   
--             elsif keyval = X"74" then   -- RIGHT
--                 saddr_head := sdouta + 1;   
--             else
--                 saddr_head := sdouta - 40;  -- Default UP
--             end if;

--         elsif (present_state = checkBoard0) then
--             -- Put updated head value on game address bus
--             gaddrb <= saddr_head;

--             -- Set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = checkBoard1) then
--             -- Read current block code into variable
--             currentBlockCode := gdoutb;
--             ld <= "1111111111"; -- DEBUGGING

--             -- if (currentBlockCode = "10") then   -- next block is apple
--             --     ld <= "1111111111"; -- DEBUGGING
--             -- end if;

--             -- Set write states
--             sweb <= "0";
--             gweb <= "0";


--         elsif (present_state = stateUpdateHeadRam) then

--             -- Put head address on WRITE address bus, put updated head block address on WRITE data bus
--             saddrb <= "0000000000";
--             sdinb <= saddr_head;
            
--             gaddrb <= saddr_head;
--             gdinb <= "01";

--             -- set write states
--             sweb <= "1";
--             gweb <= "1";

--         elsif (present_state = state5) then
--             -- Put head RAM address on READ address bus

--             -- set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state6) then
--             -- Read head block address into variable
-- --            saddr := sdouta;

--             -- Put head block address on game WRITE address bus; put snake code on game WRITE data bus
-- --            gaddrb <= saddr;
-- --            gdinb <= "01";

-- --            -- Enable write
-- --            gweb <= "1";
--             -- set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state7) then
-- --            -- Put temp RAM address on READ address bus
-- --            saddra <= "0000000010";
-- --            gweb <= "0";
            
--              -- set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state8) then
-- --            -- Read temp block address into variable
-- --            saddr := sdouta;

-- --            -- Put temp block address on game WRITE address bus; put blank code on game WRITE data bus
-- --            gaddrb <= saddr;
-- --            gdinb <= "00";
            
-- --            -- Enable write
-- --            gweb <= "1";

--             -- set write states
--             sweb <= "0";
--             gweb <= "0";

--         elsif (present_state = state9) then
--             -- set write states
--             sweb <= "0";
--             gweb <= "0";
--         end if;

        -- THIS PART IS SORTA WORKING... NOT DELETING TAIL
        -- if (present_state = state0) then
        --     saddra <= "0000000000";
        --     saddrb <= "0000000000";
        --     gweb <= "0";
        --     sweb <= "0";

        -- elsif (present_state = state1) then
        --     ld <= sdouta;

        --     -- Update saddr based on keyval
        --     if keyval = X"75" then      -- UP 
        --         saddr := sdouta - 40;
        --     elsif keyval = X"72" then   -- DOWN 
        --         saddr := sdouta + 40;
        --     elsif keyval = X"6B" then   -- LEFT
        --         saddr := sdouta - 1;   
        --     elsif keyval = X"74" then   -- RIGHT
        --         saddr := sdouta + 1;   
        --     else
        --         saddr:=sdouta-40;       -- DEFAULT UP
        --     end if;

        --     gaddrb <= saddr;
        --     gweb <= "0";
        --     sweb <= "0";

        -- elsif (present_state = state2) then
            
        --     gdinb <= "01";
        --     sweb <= "0";
        --     gweb <= "1";

        -- elsif (present_state = state3) then
        --     sdinb <= saddr;
        --     sweb <= "1";
        --     gweb <= "0";

        -- elsif (present_state = state4) then
        --     -- saddra<="0000000010";
        --     -- sweb <= "0";
        --     -- gweb <= "0";
        -- elsif (present_state = state5) then
        --     -- saddr:=sdouta;
        --     -- gaddrb<=saddr;
        --     -- sweb <= "0";
        --     -- gweb <= "0";
        -- elsif (present_state = state6) then
        --     -- gdinb<="00";
        --     -- gweb<="1";
        --     -- sweb<="0";
        -- end if;
        
-- end process c2;

end Behavioral;