library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_bsprite is
    port ( --from vga_640x480
           clr : in std_logic;
           vidon    : in std_logic;
           hc       : in std_logic_vector(9 downto 0);
           vc       : in std_logic_vector(9 downto 0);
           
           --from board RAM
           RAM_data       : in std_logic_vector(1 downto 0);
           RAM_addr: out std_logic_vector(9 downto 0);
           
           --from blank sprite
           blank_m       : in std_logic_vector(7 downto 0);
           blank_addr: out std_logic_vector(7 downto 0);
           
           --from snake sprite
           snake_m       : in std_logic_vector(7 downto 0);
           snake_addr: out std_logic_vector(7 downto 0);
           
           --from apple sprite
           apple_m       : in std_logic_vector(7 downto 0);
           apple_addr: out std_logic_vector(7 downto 0);
           
           --from border sprite
           border_m       : in std_logic_vector(7 downto 0);
           border_addr: out std_logic_vector(7 downto 0);
           
           
           red : out std_logic_vector(2 downto 0);
           green : out std_logic_vector(2 downto 0);
           blue : out std_logic_vector(1 downto 0)
	);
end vga_bsprite;

architecture Behavioral of vga_bsprite is

constant hbp: std_logic_vector(9 downto 0) := "0010010000";	 
	--Horizontal back porch = 144 (128+16)
constant vbp: std_logic_vector(9 downto 0) := "0000011111";	 
	--Vertical back porch = 31 (2+29)
constant w, h: integer := 16;
signal xpix, ypix: std_logic_vector(9 downto 0);
--signal C, R: std_logic_vector(9 downto 0);		
--signal spriteon: std_logic;
begin
	--set C and R using switches
--	C <= "000000000";
--	R <= "000000000";
	ypix <= vc - vbp;
	xpix <= hc - hbp;

	--Enable sprite video out when within the sprite region
-- 	spriteon <= '1' when (((hc > C + hbp) and (hc <= C + hbp + w))
--           and ((vc >= R + vbp) and (vc < R + vbp + h))) else '0'; 

process(xpix, ypix)  
variable  x_board, y_board: STD_LOGIC_VECTOR (5 downto 0); --x and y coordinates based on RAM addr
variable  x_addr1, x_addr2, y_addr1, y_addr2 : STD_LOGIC_VECTOR (9 downto 0);
variable  board_addr1, board_addr2 : STD_LOGIC_VECTOR (10 downto 0);
variable  sprite_addr1, sprite_addr2 : STD_LOGIC_VECTOR (13 downto 0);
constant N : std_logic_vector (5 downto 0) := "101000" ; --40 width of game board *****dont do *40, instead shift by zeroes i.e. yboard *(32+8)
    begin     
        x_board := xpix(9 downto 4);-- xpix/16
        y_board := ypix(9 downto 4) - 5;--ypix/16 - 5 for score area
        --calculate the x, y board position and corresponding RAM address
        board_addr1 := (y_board & "00000") + ("00"& y_board & "000"); --y_board*(32+8)=y_board*40
        board_addr2 := board_addr1 + ("00000" & x_board); --y_board*(32+8)=y_board*40 +x_board
        RAM_addr<= board_addr2(9 downto 0);
        --calculate the Sprite ROM address based on xpix, ypix position within the sprite block
        x_addr1 := x_board & "0000"; --x coordinate time 16 pixel sprite width
        x_addr2 := xpix - x_addr1;  --x coordinate within sprite block 0-15
        y_addr1 := y_board & "0000"; --y coordinate times 16 pixel sprite width
        y_addr2 := ypix - y_addr1;  --y coordinate within sprite block 0-15
        sprite_addr1:= y_addr2 & "0000";          --ypix*16
        sprite_addr2 := sprite_addr1 + ("0000" & x_addr2);  --ypix*16+xpix
        blank_addr <= sprite_addr2(7 downto 0);
        snake_addr <= sprite_addr2(7 downto 0);
        apple_addr <= sprite_addr2(7 downto 0);
        border_addr <= sprite_addr2(7 downto 0);
        
    end process;


process(vidon, RAM_data, blank_m, snake_m, apple_m, border_m)
    begin
		red <= "000";
		green <= "000";
		blue <= "00";
        if ypix <80 and vidon = '1' then --scoreboard placeholder
              red <= "000";
		        green <= "000";
		        blue <= "00";

        elsif ypix >= 80 and vidon = '1' then --gameboard
            case RAM_data is
                when "00" =>
                    red   <= blank_m(7 downto 5);
                    green <= blank_m(4 downto 2);
                    blue  <= blank_m(1 downto 0);
                    
                when "01" =>
                    red   <= snake_m(7 downto 5);
                    green <= snake_m(4 downto 2);
                    blue  <= snake_m(1 downto 0);
                when "10" =>
                    red   <= apple_m(7 downto 5);
                    green <= apple_m(4 downto 2);
                    blue  <= apple_m(1 downto 0);
                when "11" =>
                    red   <= border_m(7 downto 5);
                    green <= border_m(4 downto 2);
                    blue  <= border_m(1 downto 0);
                when others => 
                red   <= "000";
                green <= "000";
                blue  <= "00";
            end case;        
		end if;
end process;

end behavioral;