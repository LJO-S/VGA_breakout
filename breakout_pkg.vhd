package breakout_pkg is

    -- Tile scaled by 16: 640-480 ==> 40-30
    --constant c_GAME_WIDTH      : integer := 80;
    --constant c_GAME_HEIGHT     : integer := 60;
    --constant c_GAME_CEIL       : integer := 5;
    constant c_PADDLE_SPEED      : integer := 250_000; -- 1 tile movement every 10 ms 
    constant c_PADDLE_HEIGHT     : integer := 1;
    constant c_GAME_WIDTH_START  : integer := 4;
    constant c_GAME_WIDTH_END    : integer := 76;
    constant c_GAME_HEIGHT_START : integer := 6;
    constant c_GAME_HEIGHT_END   : integer := 60;
    constant c_PLAYER_PADDLE_Y   : integer := c_GAME_HEIGHT_END - 1;

    constant c_PADDLE_WIDTH : integer := 8;
    constant c_BALL_SPEED   : integer := 100_000;--1_000_000;

    constant c_SCORE_LIMIT : integer := 9;
    -- If work.entity gives you problems, declare components
    -- in here and just instantiate in architecture.
end package;