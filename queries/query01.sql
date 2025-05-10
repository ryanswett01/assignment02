-- Active: 1742525234643@@localhost@5432@ryan_data
-- Query 1

-- Which eight bus stop have the largest population within 800 meters? As a rough estimation, 
-- consider any block group that intersects the buffer as being part of the 800 meter buffer.

-- Answer:
-- 1. Lombard St & 18th St
-- 2. Rittenhouse Sq & 18th St
-- 3. Snyder Av & 19th St
-- 4. Lombard St & 19th St
-- 5. 16th & Locust St
-- 6. South St & 19th St
-- 7. 17th St & Lombard St
-- 8. Walnut St & 16th St

WITH

septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON public.st_dwithin(stops.geog, bg.geog, 800)
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        sum(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
ORDER BY pop.estimated_pop_800m DESC
LIMIT 10
