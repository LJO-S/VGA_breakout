package breakout_pkg is

    -- Each brick is 6 tiles wide (1:8 scaling)
    type t_BRICK_ARRAY_X is array (0 to 11) of natural;
    type t_BRICK_ARRAY_Y is array (0 to 3) of natural;
    constant c_BRICK_ARRAY_X : t_BRICK_ARRAY_X := (4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 64, 70);
    constant c_BRICK_ARRAY_Y : t_BRICK_ARRAY_Y := (7, 9, 11, 13);

    constant c_PADDLE_SPEED      : integer := 500_000; 
    constant c_PADDLE_HEIGHT     : integer := 1;
    constant c_GAME_WIDTH_START  : integer := 4;
    constant c_GAME_WIDTH_END    : integer := 76;
    constant c_GAME_HEIGHT_START : integer := 6;
    constant c_GAME_HEIGHT_END   : integer := 60;
    constant c_PLAYER_PADDLE_Y   : integer := c_GAME_HEIGHT_END - 1;

    constant c_PADDLE_WIDTH : integer := 8;
    constant c_BALL_SPEED   : integer := 1_000_000;

    constant c_SCORE_LIMIT : integer := 9;
end package;