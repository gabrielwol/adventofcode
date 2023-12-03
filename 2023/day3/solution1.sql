DROP TABLE gwolofs.advent_day3;
CREATE TABLE gwolofs.advent_day3(
    gameid smallserial,
    game text
);
\COPY gwolofs.advent_day3(game) FROM 'C:/Users/gwolofs/Downloads/advent_day3.txt' WITH (FORMAT 'text');

--replace all the special chars with 'x'
UPDATE gwolofs.advent_day3
SET game = regexp_replace(game, '\!|\@|\#|\$|\%|\^|\&|\*|\(|\)|\-|\+|\=|\/'::text, 'x', 'gi');

DROP TABLE gwolofs.advent_day3_long;
CREATE TABLE gwolofs.advent_day3_long(
    gameid int,
    _char char,
    pos smallint
)
INSERT INTO gwolofs.advent_day3_long (gameid, _char, pos)
SELECT gameid, _char, row_number() OVER (PARTITION BY gameid) AS pos
FROM (
    SELECT gameid, STRING_TO_TABLE(game, null) AS _char FROM gwolofs.advent_day3
) AS long;

WITH temp AS (
    SELECT
        curr_row.*,
        prev_row._char AS prev_row_char,
        next_row._char AS next_row_char
    FROM gwolofs.advent_day3_long AS curr_row
    LEFT JOIN gwolofs.advent_day3_long AS prev_row ON 
        prev_row._char = 'x'
        AND curr_row.pos = prev_row.pos
        AND curr_row.gameid = prev_row.gameid + 1
    LEFT JOIN gwolofs.advent_day3_long AS next_row ON 
        next_row._char = 'x'
        AND curr_row.pos = next_row.pos
        AND curr_row.gameid = next_row.gameid - 1
    ORDER BY curr_row.gameid, curr_row.pos
), games_coded AS (
    SELECT
        gameid,
        pos,
        _char,
        prev_row_char,
        next_row_char,
        CASE WHEN
                --directly above/below
                prev_row_char = 'x'
                OR next_row_char = 'x'
                --to the left
                OR LAG(_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                OR LAG(prev_row_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                OR LAG(next_row_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                --to the right
                OR LEAD(_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                OR LEAD(prev_row_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                OR LEAD(next_row_char, 1) OVER (PARTITION BY gameid ORDER BY pos) = 'x'
                --continuation of a run
                THEN 1 ELSE 0
            END AS run_including_x,
            run_including_num,
            CASE WHEN regexp_like(_char, '\d') THEN 
                SUM(run_including_num) OVER (PARTITION BY gameid ORDER BY pos)
            END AS num_island
    FROM temp,
    LATERAL (
        SELECT CASE WHEN regexp_like(_char, '\d') THEN 0 ELSE 1
            END AS run_including_num
    ) AS runs
),

valid_nums AS (
    SELECT num_island, regexp_replace(string_agg(_char, ''), '\.|x', '0')::int AS num
    FROM games_coded
    GROUP BY gameid, num_island
    HAVING SUM(run_including_x) > 0
)

SELECT SUM(num)
FROM valid_nums
    WHERE num_island IS NOT NULL
