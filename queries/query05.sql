-- Query 5

-- Rate neighborhoods by their bus stop accessibility for wheelchairs. 
-- Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed.

-- ANSWER: The accessibility metric I used was density of accessible stops within a neighborhood (number of accessible bus stops/neighborhood area).

WITH wheelchair_accessible_stops AS (
    SELECT
        stops.stop_id,
        stops.stop_name,
        stops.stop_lat,
        stops.stop_lon,
        stops.wheelchair_boarding,
        public.st_setsrid(public.st_makepoint(stops.stop_lon, stops.stop_lat), 4326)::public.geography AS geog
    FROM
        septa.bus_stops AS stops
    WHERE
        stops.wheelchair_boarding = 1
),

neighborhood_bus_stop_access AS (
    SELECT
        neighborhoods.name AS neighborhood_name,
        count(wheelchair_accessible_stops.stop_id) AS accessible_bus_stop_count,
        public.st_area(neighborhoods.geog) AS neighborhood_area
    FROM
        azavea.neighborhoods AS neighborhoods
    LEFT JOIN
        wheelchair_accessible_stops
        ON public.st_dwithin(
            wheelchair_accessible_stops.geog,
            neighborhoods.geog,
            0
        )
    GROUP BY
        neighborhoods.name, neighborhoods.geog
),

neighborhood_accessibility_metric AS (
    SELECT
        neighborhood_name,
        accessible_bus_stop_count,
        neighborhood_area,
        accessible_bus_stop_count / neighborhood_area AS accessibility_density
    FROM
        neighborhood_bus_stop_access
)

SELECT
    neighborhood_name,
    accessible_bus_stop_count,
    neighborhood_area,
    accessibility_density
FROM
    neighborhood_accessibility_metric
