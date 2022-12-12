library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gm_contrl_top is
    Port (
        -- Inputs
        btn     : in STD_LOGIC_VECTOR (3 downto 0);
        mclk    : in STD_LOGIC;
        PS2C    : in STD_LOGIC;
        PS2D    : in STD_LOGIC;

        -- Outputs
        ld      : out STD_LOGIC_VECTOR(9 downto 0);
        red     : out STD_LOGIC_VECTOR (2 downto 0);
        green   : out STD_LOGIC_VECTOR (2 downto 0);
        blue    : out STD_LOGIC_VECTOR (1 downto 0);
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;

        -- DEBUGGING
        a_to_g  : out STD_LOGIC_VECTOR (6 downto 0);
        an      : out STD_LOGIC_VECTOR (7 downto 0);
        dp      : out STD_LOGIC
    );
end gm_contrl_top;

architecture Behavioral of gm_contrl_top is

    signal vidon1, appleflg   : STD_LOGIC;
    signal sweb1, gweb1, gwea1, swea1 :STD_LOGIC_VECTOR(0 downto 0);
    signal gdoutb1, gdinb1, gdina1, gdouta1 :STD_LOGIC_VECTOR(1 downto 0);
    signal key, snake_address, snake_data, blank_address, blank_data, apple_address, apple_data, border_address, border_data :STD_LOGIC_VECTOR(7 downto 0);
    signal sdouta1, snake_cnt_out, saddrb1, sdinb1, gaddrb1, saddra1, gaddra1, sdina1, sdoutb1, hc1, vc1 :STD_LOGIC_VECTOR(9 downto 0);

    signal cClk     : STD_LOGIC;
    signal gClk     : STD_LOGIC;
    signal keyVal   : STD_LOGIC_VECTOR (7 downto 0);

    -- gRAM signals
    signal gAddrB   : STD_LOGIC_VECTOR (9 downto 0);
    signal gDoutB   : STD_LOGIC_VECTOR (1 downto 0);
    signal gDinB    : STD_LOGIC_VECTOR (1 downto 0);
    signal gWenB    : STD_LOGIC_VECTOR (0 downto 0);

    -- DEBUGGING
    signal x_disp       : STD_LOGIC_VECTOR (31 downto 0);
    -- DEBUGGING

    component ClkDiv
        port(
            mclk    : in STD_LOGIC;
            clr     : in STD_LOGIC;
            clk25   : out STD_LOGIC;
            clk6    : out STD_LOGIC
        );
    end component;

    component keyboard_ctrl
        port(
            clk25   : in STD_LOGIC;
            clr     : in STD_LOGIC;
            PS2C    : in STD_LOGIC;
            PS2D    : in STD_LOGIC;
            keyval1 : out STD_LOGIC_VECTOR(7 downto 0);
            keyval2 : out STD_LOGIC_VECTOR(7 downto 0);
            keyval3 : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component vga_640x480
        port ( 
            clk      : in std_logic;
            clr      : in std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            hc       : out std_logic_vector(9 downto 0);
            vc       : out std_logic_vector(9 downto 0);
            vidon    : out std_logic
        );
    end component;

    component vga_bsprite
        port ( 
            --from vga_640x480
            clr      : in std_logic;
            vidon    : in std_logic;
            hc       : in std_logic_vector(9 downto 0);
            vc       : in std_logic_vector(9 downto 0);
            
            --from board RAM
            RAM_data    : in std_logic_vector(1 downto 0);
            RAM_addr    : out std_logic_vector(9 downto 0);
            
            --from blank sprite
            blank_m     : in std_logic_vector(7 downto 0);
            blank_addr  : out std_logic_vector(7 downto 0);
            
            --from snake sprite
            snake_m     : in std_logic_vector(7 downto 0);
            snake_addr  : out std_logic_vector(7 downto 0);
            
            --from apple sprite
            apple_m     : in std_logic_vector(7 downto 0);
            apple_addr  : out std_logic_vector(7 downto 0);
            
            --from border sprite
            border_m    : in std_logic_vector(7 downto 0);
            border_addr : out std_logic_vector(7 downto 0);
            
            
            red : out std_logic_vector(2 downto 0);
            green : out std_logic_vector(2 downto 0);
            blue : out std_logic_vector(1 downto 0)
        );
    end component;

    component snake_controller_v2 is
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
    end component;

    -- DEBUGGING
    component x7segb8 is
        port(
            x       : in STD_LOGIC_VECTOR(31 downto 0);
            clk     : in STD_LOGIC;
            clr     : in STD_LOGIC;
            a_to_g  : out STD_LOGIC_VECTOR(6 downto 0);
            an      : out STD_LOGIC_VECTOR(7 downto 0);
            dp      : out STD_LOGIC
        );
    end component;
    -- DEBUGGING

    component gRAM
        PORT (
            -- Port A
            clka    : in STD_LOGIC;
            wea     : in STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra   : in STD_LOGIC_VECTOR(9 DOWNTO 0);
            dina    : in STD_LOGIC_VECTOR(1 DOWNTO 0);
            douta   : out STD_LOGIC_VECTOR(1 DOWNTO 0);

            -- Port B
            clkb    : in STD_LOGIC;
            web     : in STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb   : in STD_LOGIC_VECTOR(9 DOWNTO 0);
            dinb    : in STD_LOGIC_VECTOR(1 DOWNTO 0);
            doutb   : out STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    end component;

    component snake_sprite
        PORT (
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta   : out STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component apple_sprite
        PORT (
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta   : out STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component border_sprite
        PORT (
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta   : out STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component blank_sprite
        PORT (
            clka    : in STD_LOGIC;
            addra   : in STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta   : out STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    begin

    controller : snake_controller_v2
        port map (
            -- Inputs
            clr     => btn(3),
            clk => cclk,
            --clk     => btn(2),
            gclk    => gClk,
            keyVal  => keyVal,
            gDoutA  => gDoutB,

            -- Outputs
            gAddrA  => gAddrB,
            gDinA   => gDinB,
            gWenA   => gWenB,

            -- DEBUGGING
            ld      => ld,
            x       => x_disp
        );

    kbunit: keyboard_ctrl 
        port map (
            clk25   => cclk,
            clr     => btn(3),
            PS2C    => PS2C,
            PS2D    => PS2D,
            keyval1 => open,
            keyval2 => keyVal,
            keyval3 => open
        );

    clkdivunit1: ClkDiv 
        port map (
            mclk    => mclk,
            clr     => btn(3),
            clk25   => cClk,
            clk6    => gClk
        );
		 
    game_ram: gRAM 
        port map (
            -- Port A	 
            clka    => cClk,
            wea     => gwea1,
            addra   => gaddra1,
            dina    => gdina1,
            douta   => gdouta1,

            -- Port B
            clkb    => cClk,
            web     => gWenB,
            addrb   => gAddrB,
            dinb    => gDinB,
            doutb   => gDoutB
        );

    snake : snake_sprite 
        port map (
            clka    => cClk,
            addra   => snake_address,
            douta   => snake_data
        );

    blank : blank_sprite 
        port map (
            clka    => cClk,
            addra   => blank_address,
            douta   => blank_data
        );
        
    apple : apple_sprite 
        port map (
            clka    => cClk,
            addra   => apple_address,
            douta   => apple_data
        );

    border : border_sprite 
        port map (
            clka    => cClk,
            addra   => border_address,
            douta   => border_data
        );

    vga_controller : vga_640x480 
        port map (
            clk    => cClk,
            clr    => btn(3),
            hsync  => hsync,
            vsync  => vsync,
            hc     => hc1,
            vc     => vc1,
            vidon  => vidon1
        );
        
    bsprite : vga_bsprite 
        port map (
            clr         => btn(3),
            vidon       => vidon1,
            hc          => hc1,
            vc          => vc1,
            RAM_data    => gdouta1,     
            RAM_addr    => gaddra1, 
            blank_m     => blank_data,
            blank_addr  => blank_address,
            snake_m     => snake_data,
            snake_addr  => snake_address,
            apple_m     => apple_data,
            apple_addr  => apple_address,
            border_m    => border_data,
            border_addr => border_address,    
            red         => red,
            green       => green,
            blue        => blue
        );
        
    -- DEBUGGING
    display : x7segb8
        port map (
            x       => x_disp,
            clk     => mclk,
            clr     => btn(3),
            a_to_g  => a_to_g,
            an      => an,
            dp      => dp
        );
    -- DEBUGGING

end Behavioral;