-- Query 4

-- Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

-- ANSWER: The two routes with the longest trips are Route 130 and Route 128.

WITH route_trip_lengths AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        t.trip_id,
        public.ST_MakeLine(
            public.ST_SetSRID(public.ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat), 4326)
            ORDER BY s.shape_pt_sequence
        ) AS trip_geometry,
        ROUND(
            public.ST_Length(
                public.ST_MakeLine(
                    public.ST_SetSRID(public.ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat), 4326)
                    ORDER BY s.shape_pt_sequence
                )::public.geography
            )
        ) AS trip_length
    FROM
        septa.bus_routes AS r
    INNER JOIN
        septa.bus_trips AS t ON r.route_id = t.route_id
    INNER JOIN
        septa.bus_shapes AS s ON t.shape_id = s.shape_id
    GROUP BY
        r.route_short_name, t.trip_headsign, t.trip_id
)

SELECT DISTINCT ON (rtl.trip_length)
    rtl.route_short_name,
    rtl.trip_headsign,
    rtl.trip_geometry::public.geography AS shape_geog,
    rtl.trip_length::numeric AS shape_length
FROM
    route_trip_lengths AS rtl
ORDER BY
    rtl.trip_length DESC
LIMIT 2;
