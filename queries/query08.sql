-- Query 8

-- With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

-- ANSWER: 10. I used the azavea neighborhoods dataset and the University City neighborhood.

SET search_path TO public;

WITH university_city AS (
    SELECT
        geog,
        name
    FROM
        azavea.neighborhoods
    WHERE
        name = 'UNIVERSITY_CITY'
)

SELECT
    COUNT(*)
    AS count_block_groups
FROM
    census.blockgroups_2020 AS bg
INNER JOIN
    university_city AS uc
    ON ST_CONTAINS(uc.geog::geometry, bg.geog::geometry);
