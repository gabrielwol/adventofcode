

WITH seeds AS (
    SELECT seed FROM (VALUES 
                     (4106085912), (135215567), (529248892), (159537194), (1281459911), (114322341), (1857095529), (814584370), (2999858074), (50388481), (3362084117), (37744902), (3471634344), (240133599), (3737494864), (346615684), (1585884643), (142273098), (917169654), (286257440)
                     ) AS seeds(seed)
),
   
seed_to_soil AS (
    SELECT DISTINCT ON (seed) seed, soil
    FROM (
        SELECT seed, seed - src_start + dst_start AS soil, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN seeds
        WHERE category = 'seed-to-soil'
            AND seed >= src_start
            AND seed < src_start + len
        UNION
        SELECT seed, seed AS soil, 2 as priority
        FROM seeds
    ) AS t
    ORDER BY seed, priority
),

soil_to_fertilizer AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer
    FROM (
        SELECT seed, soil, soil - src_start + dst_start AS fertilizer, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN seed_to_soil
        WHERE category = 'soil-to-fertilizer'
            AND soil >= src_start
            AND soil < src_start + len
        UNION
        SELECT seed, soil, soil AS fertilizer, 2 as priority
        FROM seed_to_soil
    ) AS t
    ORDER BY seed, priority
),

fertilizer_to_water AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer, water
    FROM (
        SELECT seed, soil, fertilizer, fertilizer - src_start + dst_start AS water, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN soil_to_fertilizer
        WHERE category = 'fertilizer-to-water'
            AND fertilizer >= src_start
            AND fertilizer < src_start + len
        UNION
        SELECT seed, soil, fertilizer, fertilizer AS water, 2 as priority
        FROM soil_to_fertilizer
    ) AS t
    ORDER BY seed, priority
), 

water_to_light AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer, water, light
    FROM (
        SELECT seed, soil, fertilizer, water, water - src_start + dst_start AS light, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN fertilizer_to_water
        WHERE category = 'water-to-light'
            AND water >= src_start
            AND water < src_start + len
        UNION
        SELECT seed, soil, fertilizer, water, water AS light, 2 as priority
        FROM fertilizer_to_water
    ) AS t
    ORDER BY seed, priority
), 

light_to_temperature AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer, water, light, temperature
    FROM (
        SELECT seed, soil, fertilizer, water, light, light - src_start + dst_start AS temperature, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN water_to_light
        WHERE category = 'light-to-temperature'
            AND light >= src_start
            AND light < src_start + len
        UNION
        SELECT seed, soil, fertilizer, water, light, light AS temperature, 2 as priority
        FROM water_to_light
    ) AS t
    ORDER BY seed, priority
), 

temperature_to_humidity AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer, water, light, temperature, humidity
    FROM (
        SELECT seed, soil, fertilizer, water, light, temperature, temperature - src_start + dst_start AS humidity, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN light_to_temperature
        WHERE category = 'temperature-to-humidity'
            AND temperature >= src_start
            AND temperature < src_start + len
        UNION
        SELECT seed, soil, fertilizer, water, light, temperature, temperature AS humidity, 2 as priority
        FROM light_to_temperature
    ) AS t
    ORDER BY seed, priority
),

humidity_to_location AS (
    SELECT DISTINCT ON (seed) seed, soil, fertilizer, water, light, temperature, humidity, location
    FROM (
        SELECT seed, soil, fertilizer, water, light, temperature, humidity, humidity - src_start + dst_start AS location, 1 AS priority
        FROM gwolofs.advent_day5
        CROSS JOIN temperature_to_humidity
        WHERE category = 'humidity-to-location'
            AND humidity >= src_start
            AND humidity < src_start + len
        UNION
        SELECT seed, soil, fertilizer, water, light, temperature, humidity, humidity AS location, 2 as priority
        FROM temperature_to_humidity
    ) AS t
    ORDER BY seed, priority
)

--answer 1 (324724204)
SELECT MIN(location) FROM humidity_to_location
