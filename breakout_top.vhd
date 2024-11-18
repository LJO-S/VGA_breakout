library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

-- TODO: need to fix how array defaults back to 1s after winning, cannot have dual drivers in 2 processes

entity breakout_top is
    generic (
        g_VIDEO_WIDTH     : integer;
        g_TOTAL_COLS      : integer;
        g_TOTAL_ROWS      : integer;
        g_ACTIVE_COLS     : integer;
        g_ACTIVE_ROWS     : integer;
        g_PLAYER_paddle_Y : integer
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

        o_RED_VIDEO : out std_logic_vector(g_VIDEO_WIDTH - 1 downto 0);
        o_GRN_VIDEO : out std_logic_vector(g_VIDEO_WIDTH - 1 downto 0);
        o_BLU_VIDEO : out std_logic_vector(g_VIDEO_WIDTH - 1 downto 0)
    );

end entity;

architecture rtl of breakout_top is
    type t_STATE is (s_IDLE, s_RUNNING, s_ENEMY_WINS, s_GAME_OVER, s_CLEANUP);
    signal s_STATE : t_STATE := s_IDLE;

    type t_brick_on_matrix is array (0 to 3) of std_logic_vector(11 downto 0);
    signal r_brick_on_array : t_brick_on_matrix := (others => (others => '1'));

    signal w_HSYNC : std_logic;
    signal w_VSYNC : std_logic;

    signal w_col_count        : std_logic_vector(9 downto 0); -- accounts for 480p
    signal w_row_count        : std_logic_vector(9 downto 0); -- accounts for 640p
    signal w_col_count_div_16 : std_logic_vector(5 downto 0) := (others => '0'); -- resolves to 480/16 = 30;
    signal w_row_count_div_16 : std_logic_vector(5 downto 0) := (others => '0'); -- resolves to 640/16 = 40;
    signal w_col_count_div_8  : std_logic_vector(6 downto 0) := (others => '0'); -- resolves to 480/16 = 30;
    signal w_row_count_div_8  : std_logic_vector(6 downto 0) := (others => '0'); -- resolves to 640/16 = 40;

    signal w_draw_PADDLE    : std_logic := '0';
    signal w_paddle_X       : std_logic_vector(6 downto 0);
    signal w_paddle_X_LEFT  : unsigned(6 downto 0) := (others => '0');
    signal w_paddle_X_RIGHT : unsigned(6 downto 0) := (others => '0');

    signal w_draw_BALL   : std_logic := '0';
    signal w_ball_X      : std_logic_vector(6 downto 0);
    signal w_ball_Y      : std_logic_vector(6 downto 0);
    signal r_ball_X_prev : std_logic_vector(6 downto 0);
    signal r_ball_Y_prev : std_logic_vector(6 downto 0);
    signal r_ball_HIT_X  : std_logic := '0';
    signal r_ball_HIT_Y  : std_logic := '0';

    signal w_draw_YLW  : std_logic;
    signal w_draw_PRL  : std_logic;
    signal w_draw_BLU  : std_logic;
    signal w_draw_GRN  : std_logic;
    signal w_brick_YLW : std_logic_vector(11 downto 0) := (others => '1');
    signal w_brick_PRL : std_logic_vector(11 downto 0) := (others => '1');
    signal w_brick_BLU : std_logic_vector(11 downto 0) := (others => '1');
    signal w_brick_GRN : std_logic_vector(11 downto 0) := (others => '1');

    signal w_draw_BOUNDARY : std_logic := '0';
    signal w_draw_ANY      : std_logic := '0';

    signal w_game_active : std_logic := '0';
    signal r_game_done   : std_logic := '0';

    signal w_draw_LIFE  : std_logic            := '0';
    signal r_life_count : unsigned(2 downto 0) := "110";

    signal w_game_over     : std_logic := '0';
    signal w_draw_GAMEOVER : std_logic := '0';
begin
    ----------------------------------------------------------------
    -- Concurrent statements
    w_col_count_div_16 <= w_col_count(w_col_count'left downto 4);
    w_row_count_div_16 <= w_row_count(w_row_count'left downto 4);
    w_col_count_div_8  <= w_col_count(w_col_count'left downto 3);
    w_row_count_div_8  <= w_row_count(w_row_count'left downto 3);

    w_paddle_X_LEFT  <= unsigned(w_paddle_X);
    w_paddle_X_RIGHT <= w_paddle_X_LEFT + TO_UNSIGNED(c_PADDLE_WIDTH, w_paddle_X_RIGHT'length);

    w_game_active <= '1' when s_STATE = s_RUNNING else
        '0';
    w_game_over <= '1' when s_STATE = s_GAME_OVER else
        '0';

    w_brick_BLU <= r_brick_on_array(0);
    w_brick_YLW <= r_brick_on_array(1);
    w_brick_PRL <= r_brick_on_array(2);
    w_brick_GRN <= r_brick_on_array(3);

    w_draw_ANY <= w_draw_BOUNDARY or w_draw_GAMEOVER or w_draw_BALL or w_draw_PADDLE;

    process (w_draw_ANY,
        w_draw_LIFE,
        w_draw_BLU,
        w_draw_GRN,
        w_draw_YLW,
        w_draw_PRL)
    begin
        if (w_draw_ANY = '1') then
            o_RED_VIDEO <= (others => '1');
            o_GRN_VIDEO <= (others => '1');
            o_BLU_VIDEO <= (others => '1');
        elsif (w_draw_LIFE = '1') then
            o_RED_VIDEO <= (others => '1');
            o_GRN_VIDEO <= (others => '0');
            o_BLU_VIDEO <= (others => '0');
        elsif (w_draw_BLU = '1') then
            o_RED_VIDEO <= (others => '0');
            o_GRN_VIDEO <= (others => '0');
            o_BLU_VIDEO <= (others => '1');
        elsif (w_draw_YLW = '1') then
            o_RED_VIDEO                                                     <= (others => '1');
            o_GRN_VIDEO                                                     <= (others => '1');
            o_BLU_VIDEO(o_BLU_VIDEO'left downto (o_BLU_VIDEO'length)/2 + 1) <= (others => '1');
            o_BLU_VIDEO((o_BLU_VIDEO'length)/2 downto 0)                    <= (others => '0');
        elsif (w_draw_PRL = '1') then
            o_RED_VIDEO(o_RED_VIDEO'left downto (o_RED_VIDEO'length)/2 + 1) <= (others => '1');
            o_RED_VIDEO((o_RED_VIDEO'length)/2 downto 0)                    <= (others => '0');
            o_GRN_VIDEO                                                     <= (others => '0');
            o_BLU_VIDEO                                                     <= (others => '1');
        elsif (w_draw_GRN = '1') then
            o_RED_VIDEO <= (others => '0');
            o_GRN_VIDEO <= (others => '1');
            o_BLU_VIDEO <= (others => '0');
        else
            o_RED_VIDEO <= (others => '0');
            o_GRN_VIDEO <= (others => '0');
            o_BLU_VIDEO <= (others => '0');
        end if;
    end process;

    ----------------------------------------------------------------
    p_pipeline_syncs : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            o_HSYNC <= w_HSYNC;
            o_VSYNC <= w_VSYNC;
        end if;
    end process;
    ----------------------------------------------------------------
    p_ball_pipeline : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            r_ball_X_prev <= w_ball_X;
            r_ball_Y_prev <= w_ball_Y;
        end if;
    end process;
    ----------------------------------------------------------------
    p_game_done : process (i_CLK)
        variable v_game_done : std_logic := '1';
    begin
        if rising_edge(i_CLK) then
            if (w_game_active = '1') then
                v_game_done := '0';
                for i in 0 to 3 loop
                    for j in 0 to 11 loop
                        v_game_done := v_game_done or r_brick_on_array(i)(j);
                    end loop;
                end loop;
            end if;
            if (v_game_done = '0') then
                r_game_done <= '1';
            else
                r_game_done <= '0';
            end if;
        end if;
    end process;
    ----------------------------------------------------------------
    p_brick_interaction : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            r_ball_HIT_X <= '0';
            r_ball_HIT_Y <= '0';
            if (w_game_active = '1') then
                for i in 0 to 3 loop --     __GRN__BLU__PRL__YELLOW__
                    if (to_integer(unsigned(w_ball_Y)) >= c_BRICK_ARRAY_Y(i)) and (to_integer(unsigned(w_ball_Y)) <= (c_BRICK_ARRAY_Y(i) + 1)) then
                        for j in 0 to 11 loop
                            if (to_integer(unsigned(w_ball_X)) >= c_BRICK_ARRAY_X(j)) and (to_integer(unsigned(w_ball_X)) <= (c_BRICK_ARRAY_X(j) + 5)) and (r_brick_on_array(i)(j) = '1') then

                                r_brick_on_array(i)(j) <= '0'; -- zero out brick spot

                                if (to_integer(unsigned(r_ball_Y_prev)) > (c_BRICK_ARRAY_Y(i) + 1)) then
                                    -- FROM BELOW HIT
                                    r_ball_HIT_Y <= '1';

                                elsif (to_integer(unsigned(r_ball_Y_prev)) < c_BRICK_ARRAY_Y(i)) then
                                    -- FROM ABOVE HIT
                                    r_ball_HIT_Y <= '1';

                                elsif (to_integer(unsigned(r_ball_Y_prev)) >= c_BRICK_ARRAY_Y(i)) and (to_integer(unsigned(r_ball_Y_prev)) <= (c_BRICK_ARRAY_Y(i) + 1)) then
                                    -- FROM SIDE HIT, X
                                    r_ball_HIT_X <= '1';

                                end if;

                            end if;
                        end loop;
                    end if;
                end loop;
            elsif (w_game_over = '1') then
                r_brick_on_array <= (others => (others => '1')); -- fill bricks
            end if;
        end if;
    end process;
    ----------------------------------------------------------------
    p_main : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            case s_STATE is
                    ------------------------------------------------
                when s_IDLE =>
                    if (i_game_start = '1') then
                        s_STATE <= s_RUNNING;
                    end if;
                    ------------------------------------------------
                when s_RUNNING =>
                    if (to_integer(unsigned(w_ball_Y)) = c_GAME_HEIGHT_END - 1) then
                        if (unsigned(w_ball_X) < w_paddle_X_LEFT) or (unsigned(w_ball_X) > w_paddle_X_RIGHT) then
                            s_STATE <= s_ENEMY_WINS;
                        end if;
                    elsif (r_game_done = '1') then
                        s_STATE <= s_GAME_OVER;
                    else
                        s_STATE <= s_RUNNING;
                    end if;
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
                        s_STATE      <= s_IDLE;
                        r_life_count <= to_unsigned(6, r_life_count'length); -- max health
                        --r_brick_on_array <= (others => (others => '1'));
                    end if;
                    ------------------------------------------------
                when s_CLEANUP => s_STATE <= s_IDLE;
                    ------------------------------------------------
                when others => s_STATE <= s_IDLE;
                    ------------------------------------------------
            end case;
        end if;
    end process;
    ----------------------------------------------------------------
    -- INSTANTIATION OF COMPONENTS
    breakout_ball_ctrl_inst : entity work.breakout_ball_ctrl
        port map
        (
            i_CLK           => i_CLK,
            i_game_active   => w_game_active,
            i_col_count_div => w_col_count_div_8,
            i_row_count_div => w_row_count_div_8,
            i_hit_Y         => r_ball_HIT_Y,
            i_hit_X         => r_ball_HIT_X,
            o_draw_ball     => w_draw_ball,
            o_ball_X        => w_ball_X,
            o_ball_Y        => w_ball_Y
        );
    ------------------------------------------------
    breakout_paddle_ctrl_inst : entity work.breakout_paddle_ctrl
        generic map(
            g_PLAYER_paddle_Y => g_PLAYER_paddle_Y
        )
        port map
        (
            i_CLK           => i_CLK,
            i_LEFT          => i_LEFT,
            i_RIGHT         => i_RIGHT,
            i_col_count_div => w_col_count_div_8,
            i_row_count_div => w_row_count_div_8,
            o_draw_paddle   => w_draw_paddle,
            o_paddle_X      => w_paddle_X
        );
    ------------------------------------------------
    breakout_brick_ctrl_inst : entity work.breakout_brick_ctrl
        port map
        (
            i_CLK           => i_CLK,
            i_col_count_div => w_col_count_div_8,
            i_row_count_div => w_row_count_div_8,
            i_brick_YLW     => w_brick_YLW,
            i_brick_PRL     => w_brick_PRL,
            i_brick_BLU     => w_brick_BLU,
            i_brick_GRN     => w_brick_GRN,
            o_draw_YLW      => w_draw_YLW,
            o_draw_PRL      => w_draw_PRL,
            o_draw_BLU      => w_draw_BLU,
            o_draw_GRN      => w_draw_GRN
        );
    ------------------------------------------------
    breakout_life_ctrl_inst : entity work.breakout_life_ctrl
        port map
        (
            i_CLK        => i_CLK,
            i_col_count  => w_col_count,
            i_row_count  => w_row_count,
            i_life_count => std_logic_vector(r_life_count),
            o_draw_heart => w_draw_LIFE
        );
    ------------------------------------------------
    breakout_boundary_ctrl_inst : entity work.breakout_boundary_ctrl
        port map
        (
            i_CLK           => i_CLK,
            i_col_count_div => w_col_count_div_8,
            i_row_count_div => w_row_count_div_8,
            o_draw_boundary => w_draw_BOUNDARY
        );

    ------------------------------------------------
    VGA_sync_to_count_inst : entity work.VGA_sync_to_count
        generic map(
            g_TOTAL_COLS => g_TOTAL_COLS,
            g_TOTAL_ROWS => g_TOTAL_ROWS
        )
        port map
        (
            i_CLK       => i_CLK,
            i_HSYNC     => i_HSYNC,
            i_VSYNC     => i_VSYNC,
            o_HSYNC     => w_HSYNC,
            o_VSYNC     => w_VSYNC,
            o_col_count => w_col_count,
            o_row_count => w_row_count
        );

    ------------------------------------------------
    breakout_game_over_inst : entity work.breakout_game_over
        port map
        (
            i_CLK           => i_CLK,
            i_game_over     => w_game_over,
            i_col_count     => w_col_count,
            i_row_count     => w_row_count,
            o_DRAW_GAMEOVER => w_draw_GAMEOVER
        );

    ------------------------------------------------

end architecture;
