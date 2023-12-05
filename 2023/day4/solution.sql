DROP TABLE gwolofs.advent_day4;
CREATE TABLE gwolofs.advent_day4(
    gameid text,
    game text
);
\COPY gwolofs.advent_day4(gameid, game) FROM 'C:/Users/gwolofs/Downloads/advent_day4.txt' WITH (FORMAT 'text', DELIMITER ':');

DROP TABLE gwolofs.advent_day4_game_summary;
CREATE TABLE gwolofs.advent_day4_game_summary(
    gameid int,
    count int,
    score bigint
);

WITH numbers AS (
    SELECT gameid, STRING_TO_TABLE(split_part(game, '|'::text, 1), ' '::text) AS num, 'numbers' AS type
    FROM gwolofs.advent_day4
),

answers AS (
    SELECT gameid, STRING_TO_TABLE(split_part(game, '|'::text, 2), ' '::text) AS num, 'answers' AS type
    FROM gwolofs.advent_day4
)

INSERT INTO gwolofs.advent_day4_game_summary(gameid, count, score)
SELECT regexp_substr(numbers.gameid, '\d+')::int AS gameid, COUNT(*), (2 ^ COUNT(*))/2 AS score
FROM numbers
JOIN answers USING (gameid, num)
WHERE numbers.num <> ''
GROUP BY gameid
ORDER BY gameid;

--part1 answer
SELECT SUM(score)
FROM gwolofs.advent_day4_game_summary;

--insert the 0 score games.
INSERT INTO gwolofs.advent_day4_game_summary
SELECT DISTINCT regexp_substr(a.gameid, '\d+')::int AS gameid, 0 AS count, 0 AS score
FROM gwolofs.advent_day4 AS a
LEFT JOIN gwolofs.advent_day4_game_summary AS b ON regexp_substr(a.gameid, '\d+')::int = b.gameid
WHERE b.gameid IS NULL;

DO $do$
DECLARE
	i INT;
BEGIN
    FOR i IN 1..202 LOOP
        INSERT INTO gwolofs.advent_day4_game_summary(gameid, count, score)
        SELECT gameid, count, score FROM (
            SELECT DISTINCT gameid, count, score FROM gwolofs.advent_day4_game_summary
            WHERE gameid > i
                AND gameid <= i + (
                    SELECT count FROM gwolofs.advent_day4_game_summary WHERE gameid = i LIMIT 1
                )
        ) AS games_to_copy
        --cross join with count to copy by.
        CROSS JOIN generate_series(1, (SELECT count(*) FROM gwolofs.advent_day4_game_summary WHERE gameid = i));
    END LOOP;
END;
$do$

--part2 answer
SELECT COUNT(*) FROM gwolofs.advent_day4_game_summary;
