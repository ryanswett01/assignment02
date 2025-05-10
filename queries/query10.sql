-- Query 10

-- You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. 
-- Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. 
-- Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

-- ANSWER: the top stop_desc value reads "882 meters E of LOGAN_SQUARE"

SET search_path TO public;

SELECT
    r.stop_id,
    r.stop_name,
    r.stop_lon,
    r.stop_lat,
    CASE
        WHEN nn.name IS NOT NULL
            THEN
                CONCAT(
                    ROUND(nn.dist), ' meters ',
                    CASE
                        WHEN nn.azimuth BETWEEN 0 AND 22.5 THEN 'N'
                        WHEN nn.azimuth > 22.5 AND nn.azimuth <= 67.5 THEN 'NE'
                        WHEN nn.azimuth > 67.5 AND nn.azimuth <= 112.5 THEN 'E'
                        WHEN nn.azimuth > 112.5 AND nn.azimuth <= 157.5 THEN 'SE'
                        WHEN nn.azimuth > 157.5 AND nn.azimuth <= 202.5 THEN 'S'
                        WHEN nn.azimuth > 202.5 AND nn.azimuth <= 247.5 THEN 'SW'
                        WHEN nn.azimuth > 247.5 AND nn.azimuth <= 292.5 THEN 'W'
                        WHEN nn.azimuth > 292.5 AND nn.azimuth <= 337.5 THEN 'NW'
                        WHEN nn.azimuth > 337.5 AND nn.azimuth <= 360 THEN 'N'
                        ELSE 'Unknown'
                    END,
                    ' of ', nn.name
                )
        WHEN pp.address IS NOT NULL
            THEN
                CONCAT(
                    ROUND(pp.dist), ' meters from the nearest parcel at ',
                    pp.address
                )
        ELSE
            'No contextual info available'
    END AS stop_desc
FROM
    septa.rail_stops AS r

LEFT JOIN LATERAL (
    SELECT
        n.name,
        ST_DISTANCE(r.geog, ST_CENTROID(n.geog)) AS dist,
        DEGREES(ST_AZIMUTH(r.geog::geometry, ST_CENTROID(n.geog)::geometry)) AS azimuth
    FROM phl.neighborhoods AS n
    ORDER BY r.geog <-> ST_CENTROID(n.geog)
    LIMIT 1
) AS nn ON TRUE


LEFT JOIN LATERAL (
    SELECT
        p.address,
        ST_DISTANCE(r.geog, ST_CENTROID(p.geog)) AS dist
    FROM phl.pwd_parcels AS p
    ORDER BY r.geog <-> ST_CENTROID(p.geog)
    LIMIT 1
) AS pp ON TRUE

LIMIT 10;
