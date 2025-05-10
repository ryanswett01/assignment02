-- Query 9

-- With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. 
-- ST_MakePoint() and functions like that are not allowed.

-- ANSWER: GEOID 421010369021 (I found an address close to Meyerson because Meyerson's address was not in the block group dataset for some reason)

SET search_path TO public;

WITH meyerson_parcel AS (
    SELECT p.geog::geometry AS parcel_geom
    FROM
        phl.pwd_parcels AS p
    WHERE
        p.address = '221 S 34TH ST'
    LIMIT 1
)

SELECT bg.geoid
FROM
    census.blockgroups_2020 AS bg
INNER JOIN
    meyerson_parcel AS mp
    ON ST_INTERSECTS(mp.parcel_geom, bg.geog::geometry);
