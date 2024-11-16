library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

entity breakout_brick_ctrl is
    port (
        i_CLK : in std_logic;

        -- 1:8 tile scaling
        i_col_count_div : in std_logic_vector(6 downto 0);
        i_row_count_div : in std_logic_vector(6 downto 0);

        -- 12 bricks, each bit repr. one spot
        i_brick_YLW : in std_logic_vector(11 downto 0);
        i_brick_PRL : in std_logic_vector(11 downto 0);
        i_brick_BLU   : in std_logic_vector(11 downto 0);
        i_brick_GRN  : in std_logic_vector(11 downto 0);

        o_draw_YLW : out std_logic;
        o_draw_PRL : out std_logic;
        o_draw_BLU : out std_logic;
        o_draw_GRN : out std_logic
    );
end entity;

architecture rtl of breakout_brick_ctrl is
    

    signal w_brick_YLW : std_logic_vector(11 downto 0)                         := (others => '0');
    signal w_brick_PRL : std_logic_vector(11 downto 0)                         := (others => '0');
    signal w_brick_BLU : std_logic_vector(11 downto 0)                         := (others => '0');
    signal w_brick_GRN : std_logic_vector(11 downto 0)                         := (others => '0');
    signal r_draw      : std_logic                                            := '0';
    signal r_brick_on  : std_logic_vector(11 downto 0)                        := (others => '0');
    signal w_col_index : integer range 0 to (2 ** i_col_count_div'length - 1) := 0;
    signal w_row_index : integer range 0 to (2 ** i_row_count_div'length - 1) := 0;
begin

    w_col_index <= to_integer(unsigned(i_col_count_div));
    w_row_index <= to_integer(unsigned(i_row_count_div));

    p_latching : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            w_brick_YLW <= i_brick_YLW;
            w_brick_PRL <= i_brick_PRL;
            w_brick_BLU <= i_brick_BLU;
            w_brick_GRN <= i_brick_GRN;
        end if;
    end process;

    process (w_brick_YLW,
        w_brick_PRL,
        w_brick_BLU,
        w_brick_GRN,
        w_row_index)
    begin
        if ((w_row_index >= c_BRICK_ARRAY_Y(0)) and (w_row_index    <= (c_BRICK_ARRAY_Y(0) + 1))) then
            r_brick_on                                                  <= w_brick_BLU;
        elsif ((w_row_index >= c_BRICK_ARRAY_Y(1)) and (w_row_index <= (c_BRICK_ARRAY_Y(1) + 1))) then
            r_brick_on                                                  <= w_brick_YLW;
        elsif ((w_row_index >= c_BRICK_ARRAY_Y(2)) and (w_row_index <= (c_BRICK_ARRAY_Y(2) + 1))) then
            r_brick_on                                                  <= w_brick_PRL;
        elsif ((w_row_index >= c_BRICK_ARRAY_Y(3)) and (w_row_index <= (c_BRICK_ARRAY_Y(3) + 1))) then
            r_brick_on                                                  <= w_brick_GRN;
        else
            r_brick_on <= (others => '0');
        end if;
    end process;

    p_draw : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            r_draw <= '0';
            for i in 0 to 3 loop
                if (w_row_index >= c_BRICK_ARRAY_Y(i)) and (w_row_index <= (c_BRICK_ARRAY_Y(i) + 1)) then
                    for j in 0 to 11 loop
                        if (w_col_index >= c_BRICK_ARRAY_X(j)) and (w_col_index <= (c_BRICK_ARRAY_X(j) + 5)) and (r_brick_on(j) = '1') then
                            r_draw                                                  <= '1';
                        end if;
                    end loop;
                end if;
            end loop;
        end if;
    end process;

    o_draw_BLU <= r_draw when (w_row_index >= c_BRICK_ARRAY_Y(0)) and (w_row_index <= (c_BRICK_ARRAY_Y(0) + 1)) else
        '0';
    o_draw_YLW <= r_draw when (w_row_index >= c_BRICK_ARRAY_Y(1)) and (w_row_index <= (c_BRICK_ARRAY_Y(1) + 1)) else
        '0';
    o_draw_PRL <= r_draw when (w_row_index >= c_BRICK_ARRAY_Y(2)) and (w_row_index <= (c_BRICK_ARRAY_Y(2) + 1)) else
        '0';
    o_draw_GRN <= r_draw when (w_row_index >= c_BRICK_ARRAY_Y(3)) and (w_row_index <= (c_BRICK_ARRAY_Y(3) + 1)) else
        '0';

    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    --p_draw_BLU : process (i_CLK)
    --begin
    --    if rising_edge(i_CLK) then
    --        if (i_row_count_div >= c_BRICK_ARRAY_Y(0)) and (i_row_count_div <= (c_BRICK_ARRAY_Y(0) + 1)) then
    --            -- IF withing boundary(i) and boundary(i) + 5, AND i_LIFE(i) = 1 then DRAW!
    --            for i in 0 to 11 loop
    --                if (i_col_count_div >= c_BRICK_ARRAY_X(i)) and (i_col_count_div <= (c_BRICK_ARRAY_X(i) + 5)) then
    --                    o_draw_BLU                                                      <= '1';
    --                end if;
    --            end loop;
    --        end if;
    --    end if;
    --end process;

end architecture;