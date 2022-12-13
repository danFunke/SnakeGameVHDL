library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity prng is
    port (
        -- Inputs
        clk     : in STD_LOGIC;
        clr     : in STD_LOGIC;
        en      : in STD_LOGIC;
        outLd   : in STD_LOGIC;
        seed    : in STD_LOGIC_VECTOR (9 downto 0);

        -- Outputs
        inRange : out STD_LOGIC;
        outVal  : out STD_LOGIC_VECTOR (9 downto 0)
    );
end prng;

architecture behavior of prng is
    -- Declare internal components
    component lfsr
        port ( 
            clk     : in STD_LOGIC;
            clr     : in STD_LOGIC;
            en      : in STD_LOGIC;
            seed    : in STD_LOGIC_VECTOR (9 downto 0);
            Q       : out STD_LOGIC_VECTOR (9 downto 0)
        );
    end component;

    component comparator
        generic (N : integer := 8);
        port(
            x   : in STD_LOGIC_VECTOR (N-1 downto 0);
            y   : in STD_LOGIC_VECTOR (N-1 downto 0);
            lt  : out STD_LOGIC;
            gt  : out STD_LOGIC;
            eq  : out STD_LOGIC
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

    -- Declare internal signals
    signal gt53     : STD_LOGIC;
    signal lt396    : STD_LOGIC;
    signal ld       : STD_LOGIC;
    signal prn_s    : STD_LOGIC_VECTOR (9 downto 0);
    signal prn      : STD_LOGIC_VECTOR (9 downto 0);

    -- Declare constants
    constant low_threshold  : STD_LOGIC_VECTOR (9 downto 0) := "0001010011";
    constant high_threshold  : STD_LOGIC_VECTOR (9 downto 0) := "1110010110";

    begin
        -- Port map internal components
        lfsr_c : lfsr
            port map (
                clk => clk,
                clr => clr,
                en => en,
                seed => seed,
                Q => prn_s
            );

        lo_comp : comparator
            generic map (N => 10)
            port map (
                x => prn,
                y => low_threshold,
                lt => open,
                gt => gt53,
                eq => open
            );
        
        hi_comp : comparator
            generic map (N => 10)
            port map (
                x => prn,
                y => high_threshold,
                lt => lt396,
                gt => open,
                eq => open
            );

        outReg : reg
            generic map (N => 10)
            port map (
                d => prn_s,
                load => en,
                clk => clk,
                clr => clr,
                q => prn
            );

        -- Set outputs
        inRange <= gt53 and lt396;
        outVal <= prn;

    

end behavior;