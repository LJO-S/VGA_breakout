library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
use work.breakout_pkg.all;

entity breakout_paddle_ctrl is
    generic (
        g_PLAYER_paddle_Y : integer
    );
    port (
        i_CLK           : in std_logic;
        i_LEFT          : in std_logic;
        i_RIGHT         : in std_logic;
        i_col_count_div : in std_logic_vector(6 downto 0);
        i_row_count_div : in std_logic_vector(6 downto 0);
        o_draw_paddle    : out std_logic;
        o_paddle_X       : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of breakout_paddle_ctrl is

    signal w_col_index : natural range 0 to (2 ** i_col_count_div'length) := 0;
    signal w_row_index : natural range 0 to (2 ** i_row_count_div'length) := 0;

    signal r_paddle_count : natural range 0 to c_paddle_SPEED := 0;

    -- Start location of paddle
    signal r_paddle_X : natural range 0 to (c_GAME_WIDTH_END - c_paddle_WIDTH - 1) := (c_GAME_WIDTH_START + c_GAME_HEIGHT_END - c_paddle_WIDTH - 1)/2; -- probably shouldnt start at 0 range

    signal r_draw_paddle : std_logic := '0';
begin
    w_col_index <= to_integer(unsigned(i_col_count_div));
    w_row_index <= to_integer(unsigned(i_row_count_div));

    p_paddle_counter : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_LEFT = '1') xor (i_RIGHT = '1') then
                if (r_paddle_count = c_paddle_SPEED) then
                    r_paddle_count <= 0;
                else
                    r_paddle_count <= r_paddle_count + 1;
                end if;
            else
                r_paddle_count <= 0;
            end if;
        end if;
    end process;

    p_move_paddle : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_LEFT = '1') and (r_paddle_count = c_paddle_SPEED) then
                if (r_paddle_X = c_GAME_WIDTH_START) then
                    r_paddle_X <= c_GAME_WIDTH_START;
                else
                    r_paddle_X <= r_paddle_X - 1;
                end if;
            elsif (i_RIGHT = '1') and (r_paddle_count = c_paddle_SPEED) then
                if (r_paddle_X = (c_GAME_WIDTH_END - c_paddle_WIDTH - 1)) then
                    r_paddle_X <= (c_GAME_WIDTH_END - c_paddle_WIDTH - 1);
                else
                    r_paddle_X <= r_paddle_X + 1;
                end if;
            else
                r_paddle_X <= r_paddle_X;
            end if;
        end if;
    end process;

    p_draw_paddle : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (w_row_index = g_PLAYER_paddle_Y) and
                (w_col_index >= r_paddle_X) and
                (w_col_index <= r_paddle_X + c_paddle_WIDTH) then
                r_draw_paddle <= '1';
            else
                r_draw_paddle <= '0';
            end if;
        end if;
    end process;
    o_draw_paddle <= r_draw_paddle;
    o_paddle_X    <= std_logic_vector(to_unsigned(r_paddle_X, o_paddle_X'length));

end architecture;