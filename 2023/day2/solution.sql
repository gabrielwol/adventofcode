CREATE TABLE gwolofs.advent_day2(
    gameid text,
    games text
);
\COPY gwolofs.advent_day2(gameid, games) FROM 'C:/Users/gwolofs/Downloads/advent_day2.txt' WITH (FORMAT 'text', DELIMITER ':');

WITH games AS (
    SELECT gameid, SPLIT_PART(games, ';', 1) AS game FROM gwolofs.advent_day2 UNION
    SELECT gameid, SPLIT_PART(games, ';', 2) FROM gwolofs.advent_day2 UNION
    SELECT gameid, SPLIT_PART(games, ';', 3) FROM gwolofs.advent_day2 UNION
    SELECT gameid, SPLIT_PART(games, ';', 4) FROM gwolofs.advent_day2 UNION
    SELECT gameid, SPLIT_PART(games, ';', 5) FROM gwolofs.advent_day2 UNION
    SELECT gameid, SPLIT_PART(games, ';', 6) FROM gwolofs.advent_day2
),

valid_games AS (
    SELECT
        regexp_substr(gameid, '\d+')::int AS gameid,
        MAX(regexp_substr(game, '\d+(?= g)')::int) AS green,
        MAX(regexp_substr(game, '\d+(?= r)')::int) AS red,
        MAX(regexp_substr(game, '\d+(?= b)')::int) AS blue
    FROM games
    GROUP BY gameid
)

SELECT
    SUM(gameid) FILTER (WHERE red <= 12 AND green <= 13 AND blue <= 14) AS round1,
    SUM(green*red*blue) AS round2
FROM valid_games

DROP TABLE gwolofs.advent_day2;
