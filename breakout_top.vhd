library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

-- structure
-- 
--
--
--
--

entity breakout_top is
    generic (
        g_VIDEO_WIDTH : integer;
        g_TOTAL_COLS  : integer;
        g_TOTAL_ROWS  : integer;
        g_ACTIVE_COLS : integer;
        g_ACTIVE_ROWS : integer
    );
    port (
        i_CLK : in std_logic;

        i_HSYNC : in std_logic;
        i_VSYNC : in std_logic;

        i_RIGHT      : in std_logic;
        i_LEFT       : in std_logic;
        i_game_start : std_logic;

        o_HSYNC : out std_logic;
        o_VSYNC : out std_logic;

        o_RED_VIDEO : out std_logic_vector(g_VIDEO_WIDTH downto 0);
        o_GRN_VIDEO : out std_logic_vector(g_VIDEO_WIDTH downto 0);
        o_BLU_VIDEO : out std_logic_vector(g_VIDEO_WIDTH downto 0)
    );

end entity;

architecture rtl of breakout_top is
    type t_STATE is (s_IDLE, s_RUNNING, s_ENEMY_WINS, s_GAME_OVER, s_CLEANUP);
    signal s_STATE : t_STATE := s_IDLE;

    signal w_HSYNC : std_logic;
    signal w_VSYNC : std_logic;

    signal w_col_count        : std_logic_vector(9 downto 0); -- accounts for 480p
    signal w_row_count        : std_logic_vector(9 downto 0); -- accounts for 640p
    signal w_col_count_div_16 : std_logic_vector(5 downto 0) := (others => '0'); -- resolves to 480/16 = 30;
    signal w_row_count_div_16 : std_logic_vector(5 downto 0) := (others => '0'); -- resolves to 640/16 = 40;
    signal w_col_count_div_8  : std_logic_vector(6 downto 0) := (others => '0'); -- resolves to 480/16 = 30;
    signal w_row_count_div_8  : std_logic_vector(6 downto 0) := (others => '0'); -- resolves to 640/16 = 40;

    signal w_col_index_16 : integer range 0 to (2 ** w_col_count_div_16'length - 1) := 0;
    signal w_row_index_16 : integer range 0 to (2 ** w_row_count_div_16'length - 1) := 0;
    signal w_col_index_8  : integer range 0 to (2 ** w_col_count_div_8'length - 1)  := 0;
    signal w_row_index_8  : integer range 0 to (2 ** w_row_count_div_8'length - 1)  := 0;

    signal w_padel_X : std_logic_vector(XXX downto 0);
    signal w_ball_X  : std_logic_vector(XXX downto 0);
    signal w_ball_Y  : std_logic_vector(XXX downto 0);

    signal w_draw_PADEL : std_logic;
    signal w_draw_BALL  : std_logic;
    signal w_draw_BNDRY : std_logic;
    signal w_draw_LIFE  : std_logic;
    signal w_draw_ANY   : std_logic := '0';

    signal w_game_active : std_logic := '0';

    signal r_life_count : unsigned(3 downto 0) := (others => '0');

    signal w_game_over     : std_logic := '0';
    signal w_draw_GAMEOVER : std_logic := '0';

    signal w_padel_X_LEFT  : unsigned(5 downto 0) := (others => '0');
    signal w_padel_X_RIGHT : unsigned(5 downto 0) := (others => '0');
begin
    w_col_count_div_16 <= w_col_count(w_col_count'left downto 4);
    w_row_count_div_16 <= w_row_count(w_row_count'left downto 4);
    w_col_count_div_8  <= w_col_count(w_col_count'left downto 3);
    w_row_count_div_8  <= w_row_count(w_row_count'left downto 3);

    p_main : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            case s_STATE is
                    ------------------------------------------------
                when s_IDLE =>
                    r_life_count <= to_unsigned(6, r_life_count'length); -- 6 is max health
                    if (i_game_start = '1') then
                        s_STATE <= s_RUNNING;
                    end if;
                    ------------------------------------------------
                    -- most logic will have to go into this state
                    -- We will have to look if ball is within brick Y-boundary, and if so check 
                when s_RUNNING =>
                    


                    
                    ------------------------------------------------
                when s_ENEMY_WINS =>
                    r_life_count <= r_life_count - 1;
                    if (r_life_count = 1) then
                        s_STATE <= s_GAME_OVER;
                    else
                        s_STATE <= s_CLEANUP;
                    end if;
                    ------------------------------------------------
                when s_GAME_OVER =>
                    if (i_game_start = '1') then
                        s_STATE <= s_IDLE;
                    end if;
                    ------------------------------------------------
                when s_CLEANUP => s_STATE <= s_IDLE;
                    ------------------------------------------------
                when others => s_STATE <= s_IDLE;
                    ------------------------------------------------
            end case;
        end if;
    end process;

end architecture;
