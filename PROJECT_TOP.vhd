library ieee;
use ieee.std_logic_1164.all;

use work.breakout_pkg.all;

entity PROJECT_TOP is
    port (
        i_GAME_START : in std_logic;
        i_LEFT       : in std_logic;
        i_RIGHT      : in std_logic;

        o_HSYNC     : out std_logic;
        o_VSYNC     : out std_logic;
        o_RED_video : out std_logic_vector(3 downto 0);
        o_BLU_video : out std_logic_vector(3 downto 0);
        o_GRN_video : out std_logic_vector(3 downto 0)
    );
end entity PROJECT_TOP;

architecture rtl of PROJECT_TOP is
    -- Constants
    constant c_VIDEO_WIDTH : integer := 4;
    constant c_TOTAL_COLS  : integer := 800;
    constant c_TOTAL_ROWS  : integer := 525;
    constant c_ACTIVE_COLS : integer := 640;
    constant c_ACTIVE_ROWS : integer := 480;

    -- Signals

    -- Signals breakout_top
    signal w_CLK                : std_logic;
    signal w_HSYNC_breakout     : std_logic;
    signal w_VSYNC_breakout     : std_logic;
    signal w_LEFT               : std_logic;
    signal w_RIGHT              : std_logic;
    signal w_game_start         : std_logic;
    signal w_RED_VIDEO_breakout : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    signal w_BLU_VIDEO_breakout : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    signal w_GRN_VIDEO_breakout : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    -- Signals VGA_sync_porch
    signal w_HSYNC_VGA : std_logic;
    signal w_VSYNC_VGA : std_logic;
    signal w_RED_VIDEO_VGA : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    signal w_BLU_VIDEO_VGA : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    signal w_GRN_VIDEO_VGA : std_logic_vector(c_VIDEO_WIDTH downto 0) := (others => '0');
    signal w_HSYNC_out : std_logic;
    signal w_VSYNC_out : std_logic;
begin
    clk_wiz_inst : entity work.clk_wiz
        port map
        (
            i_CLK => i_CLK,
            o_CLK => w_CLK
        );
    -----------------------------------------------------
    breakout_top_inst : entity work.breakout_top
        generic map(
            g_VIDEO_WIDTH     => c_VIDEO_WIDTH,
            g_TOTAL_COLS      => c_TOTAL_COLS,
            g_TOTAL_ROWS      => c_TOTAL_ROWS,
            g_ACTIVE_COLS     => c_ACTIVE_COLS,
            g_ACTIVE_ROWS     => c_ACTIVE_ROWS,
            g_PLAYER_paddle_Y => c_PLAYER_paddle_Y
        )
        port map
        (
            i_CLK        => w_CLK,
            i_HSYNC      => w_HSYNC_breakout,
            i_VSYNC      => w_VSYNC_breakout,
            i_RIGHT      => w_RIGHT,
            i_LEFT       => w_LEFT,
            i_game_start => w_game_start,
            o_HSYNC      => w_HSYNC_VGA,
            o_VSYNC      => w_VSYNC_VGA,
            o_RED_VIDEO  => w_RED_VIDEO_breakout,
            o_GRN_VIDEO  => w_GRN_VIDEO_breakout,
            o_BLU_VIDEO  => w_BLU_VIDEO_breakout
        );
    -----------------------------------------------------
    VGA_sync_pulses_inst : entity work.VGA_sync_pulses
        generic map(
            g_TOTAL_COLS  => c_TOTAL_COLS,
            g_TOTAL_ROWS  => c_TOTAL_ROWS,
            g_ACTIVE_ROWS => c_ACTIVE_ROWS,
            g_ACTIVE_COLS => c_ACTIVE_COLS
        )
        port map
        (
            i_CLK       => w_CLK,
            o_row_count => open,
            o_col_count => open,
            o_HSYNC     => w_HSYNC_breakout,
            o_VSYNC     => w_VSYNC_breakout
        );
    -----------------------------------------------------
    VGA_sync_porch_inst : entity work.VGA_sync_porch
        generic map(
            g_VIDEO_WIDTH => c_VIDEO_WIDTH,
            g_TOTAL_COLS  => c_TOTAL_COLS,
            g_TOTAL_ROWS  => c_TOTAL_ROWS,
            g_ACTIVE_COLS => c_ACTIVE_COLS,
            g_ACTIVE_ROWS => c_ACTIVE_ROWS
        )
        port map
        (
            i_CLK       => w_CLK,
            i_HSYNC     => w_HSYNC_VGA,
            i_VSYNC     => w_VSYNC_VGA,
            o_HSYNC     => w_HSYNC_out,
            o_VSYNC     => w_VSYNC_out,
            i_RED_video => w_RED_VIDEO_breakout,
            i_GRN_video => w_GRN_VIDEO_breakout,
            i_BLU_video => w_BLU_VIDEO_breakout,
            o_RED_video => w_RED_VIDEO_VGA,
            o_GRN_video => w_GRN_VIDEO_VGA,
            o_BLU_video => w_BLU_VIDEO_VGA
        );

    -----------------------------------------------------
    -- PLACEHOLDER FOR UART RX DECODER
    PB_debounce_inst_1 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_CLK,
            i_PB          => i_LEFT,
            o_PB_debounce => w_LEFT
        );

    PB_debounce_inst_2 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_CLK,
            i_PB          => i_RIGHT,
            o_PB_debounce => w_RIGHT
        );

    PB_debounce_inst_3 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_CLK,
            i_PB          => i_GAME_START,
            o_PB_debounce => w_game_start
        );
    -----------------------------------------------------
    -- Output signals
    g_output_video : for i in 0 to c_VIDEO_WIDTH-1 generate
        o_RED_video(i) <= w_RED_VIDEO_VGA(i);
        o_BLU_video(i) <= w_BLU_VIDEO_VGA(i);
        o_GRN_video(i) <= w_GRN_VIDEO_VGA(i);
    end generate;

    o_HSYNC <= w_HSYNC_out;
    o_VSYNC <= w_VSYNC_out;
    -----------------------------------------------------
end architecture;