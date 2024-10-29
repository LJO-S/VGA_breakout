library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;
entity breakout_boundary_ctrl is
    port (
        i_CLK           : in std_logic;
        i_col_count_div : in std_logic_vector(6 downto 0);
        i_row_count_div : in std_logic_vector(6 downto 0);

        o_draw_boundary : out std_logic
    );
end entity breakout_boundary_ctrl;

architecture rtl of breakout_boundary_ctrl is
    signal w_col_index     : integer range 0 to 2 ** (i_col_count_div'length) := 0;
    signal w_row_index     : integer range 0 to 2 ** (i_row_count_div'length) := 0;
    signal r_draw_boundary : std_logic                                        := '0';

begin
    w_col_index <= to_integer(unsigned(i_col_count_div));
    w_row_index <= to_integer(unsigned(i_row_count_div));

    process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            -- Ceiling
            if ((w_col_index >= 0) and (w_col_index <= 3)) or ((w_col_index <= 79) and (w_col_index >= 76)) or ((w_row_index >=4) and (w_row_index <= 6)) then
                r_draw_boundary <= '1';
            else
                r_draw_boundary <= '0';
            end if;
        end if;
    end process;

    o_draw_boundary <= r_draw_boundary;
    --o_draw_boundary <= r_draw_ceil or r_draw_wall;
end architecture;