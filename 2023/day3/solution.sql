DROP TABLE gwolofs.advent_day3;
CREATE TABLE gwolofs.advent_day3(
    gameid smallserial,
    game text
);
\COPY gwolofs.advent_day3(game) FROM 'C:/Users/gwolofs/Downloads/advent_day3.txt' WITH (FORMAT 'text');

DROP TABLE gwolofs.advent_day3_long;
CREATE TABLE gwolofs.advent_day3_long(
    gameid int,
    pos smallint,
    _char char,
    is_special smallint,
    gear_id text
);
INSERT INTO gwolofs.advent_day3_long (gameid, pos, _char, is_special, gear_id)
SELECT
    gameid,
    row_number() OVER game AS pos,
    _char,
    regexp_instr(_char, '\!|\@|\#|\$|\%|\^|\&|\*|\(|\)|\-|\+|\=|\/'::text) AS is_special,
    CASE WHEN _char = '*'
            THEN CONCAT(lpad(gameid::text, 3, '0'::char), '_', lpad((row_number() OVER (PARTITION BY gameid))::text, 3, '0'::char))
        END AS gear_id
FROM (
    SELECT gameid, STRING_TO_TABLE(game, null) AS _char FROM gwolofs.advent_day3
) AS long
WINDOW game AS (PARTITION BY gameid);

WITH temp AS (
    SELECT *,
        LAG(is_special, 1) OVER col AS prev_row_is_special,
        LAG(gear_id, 1) OVER col AS prev_row_gear_id,
        LEAD(is_special, 1) OVER col AS next_row_is_special,
        LEAD(gear_id, 1) OVER col AS next_row_gear_id
    FROM gwolofs.advent_day3_long
    WINDOW col AS (PARTITION BY pos ORDER BY gameid)
    ORDER BY gameid, pos
),

runs_coded AS (
    SELECT
        gameid,
        _char,
        CASE WHEN
            vert > 0 --directly above/below
            OR LAG(vert,1) OVER w > 0 --to the left
            OR LEAD(vert, 1) OVER w > 0 --to the right
            THEN 1 ELSE 0
        END AS run_including_x,
        CASE WHEN regexp_like(_char, '\d') THEN 
            SUM(run_including_num) OVER w
        END AS run_id,
        COALESCE(gears, LAG(gears, 1) OVER w, LEAD(gears, 1) OVER w) AS gear_ids
    FROM temp,
    LATERAL (
        SELECT
            CASE WHEN regexp_like(_char, '\d') THEN 0 ELSE 1 END AS run_including_num,
            is_special + COALESCE(prev_row_is_special, 0) + COALESCE(next_row_is_special, 0) AS vert,
            COALESCE(gear_id, prev_row_gear_id, next_row_gear_id) AS gears
    ) AS runs
    WINDOW w AS (PARTITION BY gameid ORDER BY pos)
),

valid_runs AS (
    SELECT
        run_id,
        string_agg(_char, '')::int AS num,
        string_agg(DISTINCT gear_ids, '') AS gear_ids
    FROM runs_coded
    WHERE run_id IS NOT NULL
    GROUP BY gameid, run_id
    HAVING SUM(run_including_x) > 0
)

SELECT
(
    SELECT SUM(num)
    FROM valid_runs
    WHERE run_id IS NOT NULL
) AS ans_1,
(
    SELECT SUM(product) FROM (
        SELECT gear_ids, (array_agg(num))[1] * (array_agg(num))[2] AS product
        FROM valid_runs
        WHERE gear_ids <> ''
        GROUP BY gear_ids
        HAVING COUNT(*) = 2
    ) AS gears
) AS ans_2
