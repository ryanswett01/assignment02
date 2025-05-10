-- Active: 1742525234643@@localhost@5432@ryan_data
-- Query 3

-- Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
-- The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

-- ANSWER: The top three parcel addresses with the farthest bus stops are:
-- 1. 768 Sant George's Rd (799.46 m)
-- 2. 420 Rex Ave (798.31 m)
-- 3. 434 W Chestnut Hill Ave (796.44 m)

CREATE INDEX IF NOT EXISTS idx_pwd_parcels_geog ON phl.pwd_parcels USING gist(geog);
CREATE INDEX IF NOT EXISTS idx_bus_stops_geog ON septa.bus_stops USING gist(geog);

SELECT 
    p.address AS parcel_address, 
    b.stop_name AS stop_name, 
    ROUND(public.ST_Distance(p.geog, b.geog)::numeric, 2) AS distance
FROM 
    phl.pwd_parcels p
CROSS JOIN LATERAL (
    SELECT 
        b.stop_name, 
        b.geog, 
        b.stop_id, 
        public.ST_Distance(p.geog, b.geog) AS dist  
    FROM 
        septa.bus_stops b
    WHERE 
        public.ST_DWithin(p.geog, b.geog, 800)  
    ORDER BY 
        dist  
    LIMIT 1  
) b
ORDER BY 
    distance DESC;
