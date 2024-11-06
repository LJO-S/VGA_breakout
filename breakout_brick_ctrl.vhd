library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

entity breakout_brick_ctrl is
    port (
        i_CLK : in std_logic;

        i_col_count_div : in std_logic_vector(6 downto 0);
        i_row_count_div : in std_logic_vector(6 downto 0);

        i_brick_yellow : in std_logic_vector(11 downto 0);
        i_brick_purple : in std_logic_vector(11 downto 0);
        i_brick_blue   : in std_logic_vector(11 downto 0);
        i_brick_green  : in std_logic_vector(11 downto 0);

        o_draw_yellow : out std_logic;
        o_draw_purple : out std_logic;
        o_draw_blue   : out std_logic;
        o_draw_green  : out std_logic
    );
end entity;

architecture rtl of breakout_brick_ctrl is
    type t_BRICK_ARRAY_X is array (0 to 11) of natural;
    type t_BRICK_ARRAY_Y is array (0 to 3) of natural;
    -- Each brick is 6 tiles wide (1:8 scaling)
    constant c_BRICK_ARRAY_X : t_BRICK_ARRAY_X := (4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 64, 70);
    constant c_BRICK_ARRAY_Y : t_BRICK_ARRAY_Y := (4, 6, 8, 10);

    signal w_brick_yellow : std_logic_vector(3 downto 0) := (others => '0');
    signal w_brick_purple : std_logic_vector(3 downto 0) := (others => '0');
    signal w_brick_blue   : std_logic_vector(3 downto 0) := (others => '0');
    signal w_brick_green  : std_logic_vector(3 downto 0) := (others => '0');
begin
   ---- w_draw_active if inside boundaries
   --g_letter_active : for i in w_symbol_active'right to w_symbol_active'left generate
   --    w_symbol_active(i)             <= '1' when (unsigned(w_col_count_div) >= c_SYMBOL_ARRAY(i))
   --    and (unsigned(w_col_count_div) <= c_SYMBOL_ARRAY(i) + 1)
   --    and (unsigned(w_row_count_div) >= c_SYMBOL_BOT)
   --    and (unsigned(w_row_count_div) <= c_SYMBOL_TOP) else
   --    '0';
   --end generate;

    p_latching : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            w_brick_yellow <= i_brick_yellow;
            w_brick_purple <= i_brick_purple;
            w_brick_blue   <= i_brick_blue;
            w_brick_green  <= i_brick_green;
        end if;
    end process;

    p_draw_BLU : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_row_count_div >= c_BRICK_ARRAY_Y(0)) and (i_row_count_div <= c_BRICK_ARRAY_Y(0) + 1) then
                for i in 0 to 11 loop
                    -- IF withing boundary(i) and boundary(i) + 5, AND i_LIFE(i) = 1 then DRAW!
                    if (XXX = XXX) then
                        
                    end if;
                end loop;
            end if;
        end if;
    end process;


    p_draw_YLW : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_col_count_div >= c_BRICK_ARRAY_X()) then
                
            end if;
        end if;
    end process;
    p_draw_PRL : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_col_count_div >= c_BRICK_ARRAY_X()) then
                
            end if;
        end if;
    end process;
    p_draw_GRN : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_col_count_div >= c_BRICK_ARRAY_X()) then
                
            end if;
        end if;
    end process;

end architecture;