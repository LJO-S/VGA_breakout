library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

entity breakout_ball_ctrl is
    port (
        i_CLK         : in std_logic;
        i_game_active : in std_logic;

        i_col_count_div : in std_logic_vector(6 downto 0); -- tile-scaled counter (left-shifted by 3 = divided by 8)
        i_row_count_div : in std_logic_vector(6 downto 0); -- tile-scaled counter (left-shifted by 3 = divided by 8)

        i_hit_Y : in std_logic;
        i_hit_X : in std_logic;

        o_draw_ball : out std_logic;

        -- 7 bits, i.e. 0-127 for both X and Y
        o_ball_X : out std_logic_vector(6 downto 0);
        o_ball_Y : out std_logic_vector(6 downto 0)
    );
end breakout_ball_ctrl;

architecture arch of breakout_ball_ctrl is

    signal w_col_index : integer range 0 to 2 ** (i_col_count_div'length) := 0;
    signal w_row_index : integer range 0 to 2 ** (i_row_count_div'length) := 0;

    signal r_ball_count : integer range 0 to c_BALL_SPEED := 0;

    signal r_ball_X      : integer range 0 to 2 ** (i_col_count_div'length) := 0;
    signal r_ball_X_prev : integer range 0 to 2 ** (i_col_count_div'length) := 0;
    signal r_ball_Y      : integer range 0 to 2 ** (i_row_count_div'length) := 0;
    signal r_ball_Y_prev : integer range 0 to 2 ** (i_row_count_div'length) := 0;

    signal r_draw_ball : std_logic := '0';

    signal r_hit_X   : std_logic := '0';
    signal r_hit_Y   : std_logic := '0';
begin

    w_col_index <= to_integer(unsigned(i_col_count_div));
    w_row_index <= to_integer(unsigned(i_row_count_div));

    p_register_hit : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_hit_X = '1') then
                r_hit_X <= '1';
            elsif (r_ball_count = c_BALL_SPEED) then
                r_hit_X <= '0';
            end if;
            if (i_hit_Y = '1') then
                r_hit_Y <= '1';
            elsif (r_ball_count = c_BALL_SPEED) then
                r_hit_Y <= '0';
            end if;
        end if;
    end process;

    p_ball_move : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_game_active = '0') then
                -- idle state for ball
                r_ball_X      <= (c_GAME_WIDTH_START + c_GAME_WIDTH_END)/2;
                r_ball_Y      <= (c_GAME_HEIGHT_START + c_GAME_HEIGHT_END)/2;
                r_ball_X_prev <= (c_GAME_WIDTH_START + c_GAME_WIDTH_END)/2 + 1; -- +- will determine initial direction of ball
                r_ball_Y_prev <= (c_GAME_HEIGHT_START + c_GAME_HEIGHT_END)/2 + 1;
            else
                if (r_ball_count = c_BALL_SPEED) then
                    r_ball_count <= 0;

                    -------------------------------------------------------
                    ---------------X_POSITION------------------------------
                    -- Update prev position
                    r_ball_X_prev <= r_ball_X;

                    -- Ball is moving right
                    if (r_ball_X_prev < r_ball_X) then
                        if (r_ball_X = c_GAME_WIDTH_END - 1) or (r_hit_X = '1') then
                            -- at game boundary -> bounce
                            r_ball_X <= r_ball_X - 1;
                        else
                            r_ball_X <= r_ball_X + 1;
                        end if;
                        -- Ball is moving left
                    elsif (r_ball_X_prev > r_ball_X) then
                        if (r_ball_X = c_GAME_WIDTH_START) or (r_hit_X = '1') then
                            -- at game boundary -> bounce
                            r_ball_X <= r_ball_X + 1;
                        else
                            r_ball_X <= r_ball_X - 1;
                        end if;
                    end if;
                    -------------------------------------------------------
                    ---------------Y_POSITION------------------------------

                    -- Update previous position
                    r_ball_Y_prev <= r_ball_Y;

                    -- Ball is moving up
                    if (r_ball_Y < r_ball_Y_prev) then
                        if (r_ball_Y = c_GAME_HEIGHT_START) or (r_hit_Y = '1') then
                            -- at game boundary -> bounce
                            r_ball_Y <= r_ball_Y + 1;
                        else
                            r_ball_Y <= r_ball_Y - 1;
                        end if;
                        -- Ball is moving down
                    elsif (r_ball_Y > r_ball_Y_prev) then
                        if (r_ball_Y = c_GAME_HEIGHT_END - 1) or (r_hit_Y = '1') then
                            -- at game boundary -> bounce
                            r_ball_Y <= r_ball_Y - 1;
                        else
                            r_ball_Y <= r_ball_Y + 1;
                        end if;
                    end if;
                    -------------------------------------------------------
                else
                    r_ball_count <= r_ball_count + 1;
                end if;
            end if;
        end if;
    end process; -- p_ball_move

    p_ball_draw : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (w_col_index = r_ball_X) and (w_row_index = r_ball_Y) then
                r_draw_ball <= '1';
            else
                r_draw_ball <= '0';
            end if;
        end if;
    end process; -- p_ball_draw

    o_draw_ball <= r_draw_ball;
    o_ball_X    <= std_logic_vector(to_unsigned(r_ball_X, o_ball_X'length));
    o_ball_Y    <= std_logic_vector(to_unsigned(r_ball_Y, o_ball_Y'length));

end architecture;