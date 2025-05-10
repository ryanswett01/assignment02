-- Query 7

-- What are the bottom five neighborhoods according to your accessibility metric?

-- ANSWER: The bottom five neighborhoods are:
-- 1. Bartram Village
-- 2. Mechanicsville
-- 3. Navy Yard
-- 4. West Torresdale
-- 5. Airport

WITH wheelchair_accessible_stops AS (
    SELECT
        stops.stop_id,
        stops.stop_name,
        stops.stop_lat,
        stops.stop_lon,
        stops.wheelchair_boarding,
        st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326)::geography AS geog
    FROM
        septa.bus_stops AS stops
    WHERE
        stops.wheelchair_boarding = 1
),

neighborhood_bus_stop_access AS (
    SELECT
        neighborhoods.name AS neighborhood_name,
        count(wheelchair_accessible_stops.stop_id) AS accessible_bus_stop_count,
        count(stops.stop_id) - count(wheelchair_accessible_stops.stop_id) AS inaccessible_bus_stop_count,
        st_area(neighborhoods.geog) AS neighborhood_area
    FROM
        azavea.neighborhoods AS neighborhoods
    LEFT JOIN
        septa.bus_stops AS stops
        ON st_dwithin(stops.geog, neighborhoods.geog, 0)
    LEFT JOIN
        wheelchair_accessible_stops
        ON stops.stop_id = wheelchair_accessible_stops.stop_id
    GROUP BY
        neighborhoods.name, neighborhoods.geog
),

neighborhood_accessibility_metric AS (
    SELECT
        neighborhood_name,
        accessible_bus_stop_count,
        inaccessible_bus_stop_count,
        neighborhood_area,
        accessible_bus_stop_count / neighborhood_area AS accessibility_density
    FROM
        neighborhood_bus_stop_access
)

SELECT
    neighborhood_name,
    accessibility_density AS accessibilitydensity,
    accessible_bus_stop_count AS num_bus_stops_accessible,
    inaccessible_bus_stop_count AS num_bus_stops_inaccessible
FROM
    neighborhood_accessibility_metric
ORDER BY
    accessibility_density ASC
LIMIT 5;
