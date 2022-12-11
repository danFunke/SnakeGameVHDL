type state_type is (requestPrng, waitForPrng, checkPrng0, checkPrng1)

signal prngEn   : STD_LOGIC;

variable prn    : STD_LOGIC_VECTOR (9 downto 0);

if (current_state = requestPrng) then
    prngEn <= '1';
    next_state <= waitForPrng;
end if;

if (current_state = waitForPrng) then
    if (prngInRange <= '1') then
        prngEn      <= '0';         -- Disable PRNG
        prn         <= prngOut;     -- Capture output of PRNG
        next_state  <= checkPrng0;
    else
        next_state <= waitForPrng;  -- Stay here until PRNG is in playable range
    end if;
end if;

if (current_state = checkPrng0) then
    bAddra <= prn;                  -- not sure which port to put this on
    next_state <= checkPrng1;
end if;

if (current_state = checkPrng1) then
    if (bdouta = "00") then         -- not sure which port to read from
        next_state <=               -- whatever comes next
    else
        next_state <= requestPrng;  -- Repeat cycle if prn is in snake or wall
    end if;
end if;