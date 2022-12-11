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
        vsync   : out STD_LOGIC
    );
end gm_contrl_top;

architecture Behavioral of gm_contrl_top is

    signal cclk, gclk, vidon1, appleflg   : STD_LOGIC;
    signal sweb1, gweb1, gwea1, swea1 :STD_LOGIC_VECTOR(0 downto 0);
    signal gdoutb1, gdinb1, gdina1, gdouta1 :STD_LOGIC_VECTOR(1 downto 0);
    signal key, snake_address, snake_data, blank_address, blank_data, apple_address, apple_data, border_address, border_data :STD_LOGIC_VECTOR(7 downto 0);
    signal sdouta1, snake_cnt_out, saddrb1, sdinb1, gaddrb1, saddra1, gaddra1, sdina1, sdoutb1, hc1, vc1 :STD_LOGIC_VECTOR(9 downto 0);


    component ClkDiv
        port(
            mclk : in STD_LOGIC;
            clr : in STD_LOGIC;
            clk25 : out STD_LOGIC;
            clk6 : out STD_LOGIC
        );
    end component;

    component keyboard_ctrl
        port(
            clk25 : in STD_LOGIC;
            clr : in STD_LOGIC;
            PS2C : in STD_LOGIC;
            PS2D : in STD_LOGIC;
            keyval1: out STD_LOGIC_VECTOR(7 downto 0);
            keyval2: out STD_LOGIC_VECTOR(7 downto 0);
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

    component snake_controller
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
    end component;

    component ireg
        port ( 
            d   : in STD_LOGIC_VECTOR (9 downto 0);
            clr : in STD_LOGIC;
            clk : in STD_LOGIC;
            flg : in STD_LOGIC;
            q   : out STD_LOGIC_VECTOR (9 downto 0)
        );
    end component;

    component gRAM
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            clkb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    end component;

    component sRAM
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            clkb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    end component;

    component snake_sprite
        PORT (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component apple_sprite
        PORT (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component border_sprite
        PORT (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component blank_sprite
        PORT (
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    begin

    snake_cnt_out<="0000000010";
    --key<= X"75";

    controller: snake_controller 
        port map (
            clk25 => cclk,
            clk6 => gclk,
            clr => btn(3),       
            go => btn(1),           
            keyval => key,
            gdoutb => gdoutb1,
            sdouta => sdouta1,
            sdoutb=> sdoutb1,
            snake_count_out => snake_cnt_out,
            ld => ld,
            appleflgout => appleflg,
            blankflgout => open,
            gameoverflgout  => open, 
            sweb => sweb1,
            gweb => gweb1,
            gdinb => gdinb1,
            saddrb => saddrb1,
            sdinb => sdinb1,
            gaddrb => gaddrb1,
            saddra => saddra1
        );

    kbunit: keyboard_ctrl 
        port map (
            clk25 => cclk,
            clr => btn(3),
            PS2C => PS2C,
            PS2D => PS2D,
            keyval1 => open,
            keyval2 => key,
            keyval3 => open
        );

    clkdivunit1: ClkDiv 
        port map (
            mclk => mclk,
            clr => btn(3),
            clk25 => cclk,
            clk6 => gclk
        );
		 
    game_ram: gRAM 
        port map (	 
            clka => cclk,
            wea => gwea1,
            addra => gaddra1,
            dina => gdina1,
            douta => gdouta1,
            clkb => cclk,
            web => gweb1,
            addrb => gaddrb1,
            dinb => gdinb1,
            doutb => gdoutb1
        );

    snake_ram: sRAM 
        port map (	 
            clka => cclk,
            wea => swea1,
            addra => saddra1,
            dina => sdina1,
            douta => sdouta1,
            clkb => cclk,
            web => sweb1,
            addrb => saddrb1,
            dinb => sdinb1,
            doutb => sdoutb1
        );

    snake : snake_sprite 
        port map (
            clka    => cclk,
            addra   => snake_address,
            douta   => snake_data
        );

    blank : blank_sprite 
        port map (
            clka    => cclk,
            addra   => blank_address,
            douta   => blank_data
        );
        
    apple : apple_sprite 
        port map (
            clka    => cclk,
            addra   => apple_address,
            douta   => apple_data
        );

    border : border_sprite 
        port map (
            clka    => cclk,
            addra   => border_address,
            douta   => border_data
        );  
     
    counter : ireg 
        port map (
            d   => snake_cnt_out,
            clk => cclk,
            clr => btn(3),
            flg => appleflg,
            q   => open
        ); 

    vga_controller : vga_640x480 
        port map (
            clk    => cclk,
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

end Behavioral;