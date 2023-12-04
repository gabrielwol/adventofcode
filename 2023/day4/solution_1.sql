DROP TABLE gwolofs.advent_day4;
CREATE TABLE gwolofs.advent_day4(
    gameid text,
    game text
);
\COPY gwolofs.advent_day4(gameid, game) FROM 'C:/Users/gwolofs/Downloads/advent_day4.txt' WITH (FORMAT 'text', DELIMITER ':');

WITH numbers AS (
    SELECT gameid, STRING_TO_TABLE(split_part(game, '|'::text, 1), ' '::text) AS num, 'numbers' AS type
    FROM gwolofs.advent_day4
),

answers AS (
    SELECT gameid, STRING_TO_TABLE(split_part(game, '|'::text, 2), ' '::text) AS num, 'answers' AS type
    FROM gwolofs.advent_day4
), 

per_game_score AS (
    SELECT regexp_substr(numbers.gameid, '\d+')::int AS gameid, COUNT(*), (2 ^ COUNT(*))/2 AS score
    FROM numbers
    JOIN answers USING (gameid, num)
    WHERE numbers.num <> ''
    GROUP BY gameid
    ORDER BY gameid
)

SELECT SUM(score)
FROM per_game_score
