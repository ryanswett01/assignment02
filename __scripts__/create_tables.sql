create schema if not exists septa;
create schema if not exists phl;
create schema if not exists azavea;
create schema if not exists census;

drop table if exists septa.bus_stops;
create table septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);

drop table if exists septa.bus_routes;

create table septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);

drop table if exists septa.bus_trips;
create table septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

drop table if exists septa.rail_stops;
create table septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);


create extension if not exists postgis;
