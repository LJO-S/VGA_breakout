library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

entity breakout_life_ctrl is
    port (
        i_CLK        : in std_logic;
        i_col_count  : in std_logic_vector(9 downto 0);
        i_row_count  : in std_logic_vector(9 downto 0);
        i_life_count : in std_logic_vector(2 downto 0);

        o_draw_heart : out std_logic
    );
end entity breakout_life_ctrl;

architecture rtl of breakout_life_ctrl is

    type t_SYMBOL_ARRAY is array (0 to 11) of natural;

    -- L I V E S: {} {} {} {} {} {}
    constant c_SYMBOL_ARRAY : t_SYMBOL_ARRAY := (
    2, -- L
    4, -- I
    6, -- V
    8, -- E
    10, -- S
    12, -- :
    14, -- {}
    18, -- {}
    22, -- {}
    26, -- {}
    30, -- {}
    34 -- {}
    );
    constant c_SYMBOL_BOT : natural := 0;
    constant c_SYMBOL_TOP : natural := 1;

    signal w_col_count_div : std_logic_vector(5 downto 0); -- 40
    signal w_row_count_div : std_logic_vector(5 downto 0); -- 30
    signal w_col_addr      : std_logic_vector(2 downto 0)  := (others => '0'); -- 0-7 X
    signal w_row_addr      : std_logic_vector(3 downto 0)  := (others => '0'); -- 0-15 Y
    signal w_symbol_active : std_logic_vector(11 downto 0) := (others => '0');
    signal r_symbol_active : std_logic_vector(3 downto 0)  := (others => '0');

    signal r_life_count : std_logic_vector(i_life_count'left downto 0) := (others => '0');
    signal r_ROM_data   : std_logic_vector(7 downto 0)                 := (others => '0');
    signal r_bit_draw   : std_logic                                    := '0';
    signal r_ROM_addr   : std_logic_vector(7 downto 0);

    signal w_col_addr_d1 : std_logic_vector(2 downto 0) := (others => '0');
    signal w_col_addr_d2 : std_logic_vector(2 downto 0) := (others => '0');
    signal w_col_addr_d3 : std_logic_vector(2 downto 0) := (others => '0');
    signal w_symbol_active_d1 : std_logic_vector(11 downto 0) := (others => '0');
    signal w_symbol_active_d2 : std_logic_vector(11 downto 0) := (others => '0');
    signal w_symbol_active_d3 : std_logic_vector(11 downto 0) := (others => '0');


begin
    --
    -- Tile scaling: ROM addresses
    -- 1:4 means we need 2 of 1:16 tiles to cover 1 letter in X
    -- 1:2 means we need 2 of 1:16 tiles to cover 1 letter in Y
    w_col_addr <= i_col_count(4 downto 2); -- 1:4
    w_row_addr <= i_row_count(4 downto 1); -- 1:2

    -- Tile scaling: Screen Position 1:16
    w_col_count_div <= i_col_count(i_col_count'left downto 4);
    w_row_count_div <= i_row_count(i_row_count'left downto 4);

    -- w_draw_active if inside boundaries
    g_letter_active : for i in w_symbol_active'right to w_symbol_active'left generate
        w_symbol_active(i)             <= '1' when (unsigned(w_col_count_div) >= c_SYMBOL_ARRAY(i))
        and (unsigned(w_col_count_div) <= c_SYMBOL_ARRAY(i) + 1)
        and (unsigned(w_row_count_div) >= c_SYMBOL_BOT)
        and (unsigned(w_row_count_div) <= c_SYMBOL_TOP) else
        '0';
    end generate;

    -- One-hot encoding
    p_onehot_encoding : process (i_CLK)
    begin
        if rising_edge(i_CLK) then

            r_life_count <= i_life_count;

            case w_symbol_active is
                when "000000000001" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(0, r_symbol_active'length)); -- L
                when "000000000010" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(1, r_symbol_active'length)); -- I
                when "000000000100" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(2, r_symbol_active'length)); -- V
                when "000000001000" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(3, r_symbol_active'length)); -- E
                when "000000010000" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(4, r_symbol_active'length)); -- S
                when "000000100000" =>
                    r_symbol_active <= std_logic_vector(to_unsigned(5, r_symbol_active'length)); -- :
                when "000001000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 1) then
                        r_symbol_active <= std_logic_vector(to_unsigned(6, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when "000010000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 2) then
                        r_symbol_active <= std_logic_vector(to_unsigned(7, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when "000100000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 3) then
                        r_symbol_active <= std_logic_vector(to_unsigned(8, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when "001000000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 4) then
                        r_symbol_active <= std_logic_vector(to_unsigned(9, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when "010000000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 5) then
                        r_symbol_active <= std_logic_vector(to_unsigned(10, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when "100000000000" =>
                    if (to_integer(unsigned(r_life_count)) >= 6) then
                        r_symbol_active <= std_logic_vector(to_unsigned(11, r_symbol_active'length)); -- {}
                    else
                        r_symbol_active <= (others => '1');
                    end if;
                when others                =>
                    r_symbol_active <= (others => '1');
            end case;
        end if;
    end process;

    -- Draw process
    p_draw : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            r_ROM_addr <= r_symbol_active & w_row_addr;
            if (to_integer(unsigned(w_symbol_active_d3)) > 0) then
                r_bit_draw <= r_ROM_data(to_integer(unsigned(not w_col_addr_d3)));
            else
                r_bit_draw <= '0';
            end if;
        end if;
    end process;

    p_pipeline : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            w_col_addr_d1 <= w_col_addr;
            w_col_addr_d2 <= w_col_addr_d1;
            w_col_addr_d3 <= w_col_addr_d2;

            w_symbol_active_d1 <= w_symbol_active;
            w_symbol_active_d2 <= w_symbol_active_d1;
            w_symbol_active_d3 <= w_symbol_active_d2;
        end if;
    end process;

    -- ROM
    -- 1:1 tile scaling = 8x16 ROM 
    p_ROM : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            case r_ROM_addr is
                    -- L
                when x"00" => r_ROM_data <= "00000000";
                when x"01" => r_ROM_data <= "00000000";
                when x"02" => r_ROM_data <= "11000000";
                when x"03" => r_ROM_data <= "11000000";
                when x"04" => r_ROM_data <= "11000000";
                when x"05" => r_ROM_data <= "11000000";
                when x"06" => r_ROM_data <= "11000000";
                when x"07" => r_ROM_data <= "11000000";
                when x"08" => r_ROM_data <= "11000000";
                when x"09" => r_ROM_data <= "11000000";
                when x"0A" => r_ROM_data <= "11111110";
                when x"0B" => r_ROM_data <= "11111110";
                when x"0C" => r_ROM_data <= "00000000";
                when x"0D" => r_ROM_data <= "00000000";
                when x"0E" => r_ROM_data <= "00000000";
                when x"0F" => r_ROM_data <= "00000000";
                    -- I
                when x"10" => r_ROM_data <= "00000000";
                when x"11" => r_ROM_data <= "00000000";
                when x"12" => r_ROM_data <= "00111100";
                when x"13" => r_ROM_data <= "00011000";
                when x"14" => r_ROM_data <= "00011000";
                when x"15" => r_ROM_data <= "00011000";
                when x"16" => r_ROM_data <= "00011000";
                when x"17" => r_ROM_data <= "00011000";
                when x"18" => r_ROM_data <= "00011000";
                when x"19" => r_ROM_data <= "00011000";
                when x"1A" => r_ROM_data <= "00011000";
                when x"1B" => r_ROM_data <= "00111100";
                when x"1C" => r_ROM_data <= "00000000";
                when x"1D" => r_ROM_data <= "00000000";
                when x"1E" => r_ROM_data <= "00000000";
                when x"1F" => r_ROM_data <= "00000000";
                    -- V
                when x"20" => r_ROM_data <= "00000000";
                when x"21" => r_ROM_data <= "00000000";
                when x"22" => r_ROM_data <= "11000110";
                when x"23" => r_ROM_data <= "11000110";
                when x"24" => r_ROM_data <= "11000110";
                when x"25" => r_ROM_data <= "11000110";
                when x"26" => r_ROM_data <= "11000110";
                when x"27" => r_ROM_data <= "11000110";
                when x"28" => r_ROM_data <= "11000110";
                when x"29" => r_ROM_data <= "01101100";
                when x"2A" => r_ROM_data <= "01111100";
                when x"2B" => r_ROM_data <= "00010000";
                when x"2C" => r_ROM_data <= "00000000";
                when x"2D" => r_ROM_data <= "00000000";
                when x"2E" => r_ROM_data <= "00000000";
                when x"2F" => r_ROM_data <= "00000000";
                    -- E
                when x"30" => r_ROM_data <= "00000000";
                when x"31" => r_ROM_data <= "00000000";
                when x"32" => r_ROM_data <= "11111110";
                when x"33" => r_ROM_data <= "11111110";
                when x"34" => r_ROM_data <= "11000000";
                when x"35" => r_ROM_data <= "11000000";
                when x"36" => r_ROM_data <= "11111000";
                when x"37" => r_ROM_data <= "11111000";
                when x"38" => r_ROM_data <= "11000000";
                when x"39" => r_ROM_data <= "11000000";
                when x"3A" => r_ROM_data <= "11111110";
                when x"3B" => r_ROM_data <= "11111110";
                when x"3C" => r_ROM_data <= "00000000";
                when x"3D" => r_ROM_data <= "00000000";
                when x"3E" => r_ROM_data <= "00000000";
                when x"3F" => r_ROM_data <= "00000000";
                    -- S
                when x"40" => r_ROM_data <= "00000000";
                when x"41" => r_ROM_data <= "00000000";
                when x"42" => r_ROM_data <= "11111110";
                when x"43" => r_ROM_data <= "11000110";
                when x"44" => r_ROM_data <= "11000000";
                when x"45" => r_ROM_data <= "11000000";
                when x"46" => r_ROM_data <= "11111110";
                when x"47" => r_ROM_data <= "11111110";
                when x"48" => r_ROM_data <= "00000110";
                when x"49" => r_ROM_data <= "00000110";
                when x"4A" => r_ROM_data <= "11000110";
                when x"4B" => r_ROM_data <= "11111110";
                when x"4C" => r_ROM_data <= "00000000";
                when x"4D" => r_ROM_data <= "00000000";
                when x"4E" => r_ROM_data <= "00000000";
                when x"4F" => r_ROM_data <= "00000000";
                    -- :
                when x"50" => r_ROM_data <= "00000000";
                when x"51" => r_ROM_data <= "00000000";
                when x"52" => r_ROM_data <= "00000000";
                when x"53" => r_ROM_data <= "00000000";
                when x"54" => r_ROM_data <= "00000000";
                when x"55" => r_ROM_data <= "01100000";
                when x"56" => r_ROM_data <= "01100000";
                when x"57" => r_ROM_data <= "00000000";
                when x"58" => r_ROM_data <= "01100000";
                when x"59" => r_ROM_data <= "01100000";
                when x"5A" => r_ROM_data <= "00000000";
                when x"5B" => r_ROM_data <= "00000000";
                when x"5C" => r_ROM_data <= "00000000";
                when x"5D" => r_ROM_data <= "00000000";
                when x"5E" => r_ROM_data <= "00000000";
                when x"5F" => r_ROM_data <= "00000000";
                    -- {heart}
                when x"60" | x"70" | x"80" | x"90" | x"A0" | x"B0" => r_ROM_data <= "00000000";
                when x"61" | x"71" | x"81" | x"91" | x"A1" | x"B1" => r_ROM_data <= "00000000";
                when x"62" | x"72" | x"82" | x"92" | x"A2" | x"B2" => r_ROM_data <= "00000000";
                when x"63" | x"73" | x"83" | x"93" | x"A3" | x"B3" => r_ROM_data <= "01100110";
                when x"64" | x"74" | x"84" | x"94" | x"A4" | x"B4" => r_ROM_data <= "11111111";
                when x"65" | x"75" | x"85" | x"95" | x"A5" | x"B5" => r_ROM_data <= "11111111";
                when x"66" | x"76" | x"86" | x"96" | x"A6" | x"B6" => r_ROM_data <= "11111111";
                when x"67" | x"77" | x"87" | x"97" | x"A7" | x"B7" => r_ROM_data <= "01111110";
                when x"68" | x"78" | x"88" | x"98" | x"A8" | x"B8" => r_ROM_data <= "01111110";
                when x"69" | x"79" | x"89" | x"99" | x"A9" | x"B9" => r_ROM_data <= "00111100";
                when x"6A" | x"7A" | x"8A" | x"9A" | x"AA" | x"BA" => r_ROM_data <= "00111100";
                when x"6B" | x"7B" | x"8B" | x"9B" | x"AB" | x"BB" => r_ROM_data <= "00011000";
                when x"6C" | x"7C" | x"8C" | x"9C" | x"AC" | x"BC" => r_ROM_data <= "00000000";
                when x"6D" | x"7D" | x"8D" | x"9D" | x"AD" | x"BD" => r_ROM_data <= "00000000";
                when x"6E" | x"7E" | x"8E" | x"9E" | x"AE" | x"BE" => r_ROM_data <= "00000000";
                when x"6F" | x"7F" | x"8F" | x"9F" | x"AF" | x"BF" => r_ROM_data <= "00000000";
                    -- others
                when others => r_ROM_data <= (others => '0');
            end case;
        end if;
    end process;

    o_draw_heart <= r_bit_draw;

end architecture;