CREATE TABLE gwolofs.advent_day1(
    field1 text
);
\COPY gwolofs.advent_day1(field1) FROM 'C:/Users/gwolofs/Downloads/advent_day1.txt' WITH (FORMAT 'text');
SELECT field1 FROM gwolofs.advent_day1;

--part 1:
SELECT SUM((digit1||digit2)::int)
FROM gwolofs.advent_day1,
LATERAL (
    SELECT
        regexp_substr(field1, '\d') AS digit1,
        regexp_substr(reverse(field1), '\d') AS digit2
) AS digits;

--part 2:
CREATE FUNCTION text_to_int(a text)
RETURNS text AS $$
DECLARE
num text;
BEGIN
    num := CASE
        WHEN a = 'one' THEN '1'
        WHEN a = 'two' THEN '2'
        WHEN a = 'three' THEN '3'
        WHEN a = 'four' THEN '4'
        WHEN a = 'five' THEN '5'
        WHEN a = 'six' THEN '6'
        WHEN a = 'seven' THEN '7'
        WHEN a = 'eight' THEN '8'
        WHEN a = 'nine' THEN '9'
        ELSE a
    END;
    return num;
END; $$
LANGUAGE plpgsql;

SELECT SUM((text_to_int(cleaned.field1) || text_to_int(cleaned.field2))::integer)
FROM gwolofs.advent_day1,
LATERAL (
    SELECT  
        regexp_substr(field1, 'one|two|three|four|five|six|seven|eight|nine|\d'::text) AS field1,
        reverse(regexp_substr(reverse(field1), reverse('one|two|three|four|five|six|seven|eight|nine|d\'))) AS field2
) AS cleaned;

DROP TABLE gwolofs.advent_day1;
DROP FUNCTION gwolofs.text_to_int;
