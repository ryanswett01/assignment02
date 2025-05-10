-- Query 2

-- Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop 
-- (Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia county)?

-- ANSWER:
-- 1. Delaware Av & Tioga St
-- 2. Delaware Av & Castor Av
-- 3. Delaware Av & Venango St
-- 4. Delaware Av & Wheatsheaf Ln
-- 5. Valley Forge Park Dr & Washington Memorial Chapel
-- 6. Southhampton Rd & Roosevelt - MBNS
-- 7. Southhampton Rd & Hank Salvatore Rd
-- 8. Charter Rd & Norcom Rd - FS

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
    HAVING sum(pop.total) > 500
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
ORDER BY pop.estimated_pop_800m ASC
LIMIT 9
