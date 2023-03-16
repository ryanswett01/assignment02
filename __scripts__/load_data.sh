#!/bin/env bash

set -e
set -x

SCRIPTDIR=$(readlink -f $(dirname $0))
DATADIR=$(readlink -f $(dirname $0)/../__data__)
mkdir -p ${DATADIR}

# Download and unzip trip data
# curl -L https://bicycletransit.wpenginepowered.com/wp-content/uploads/2022/12/indego-trips-2022-q3.zip > ${DATADIR}/indego-trips-2022-q3.zip
# unzip -o ${DATADIR}/indego-trips-2022-q3.zip -d ${DATADIR}

# curl -L https://bicycletransit.wpenginepowered.com/wp-content/uploads/2021/10/indego-trips-2021-q3.zip > ${DATADIR}/indego-trips-2021-q3.zip
# unzip -o ${DATADIR}/indego-trips-2021-q3.zip -d ${DATADIR}


# Download and unzip gtfs data
curl -L https://github.com/septadev/GTFS/releases/download/v202302261/gtfs_public.zip > ${DATADIR}/gtfs_public.zip
unzip -o ${DATADIR}/gtfs_public.zip -d ${DATADIR}/gtfs_public
unzip -o ${DATADIR}/gtfs_public/google_bus.zip -d google_bus
unzip -o ${DATADIR}/gtfs_public/google_rail.zip -d google_rail

# Create database and initialize table structure
PGPASSWORD=postgres createdb \
  -h localhost \
  -p 5432 \
  -U postgres \
  musa_509
PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -f "${SCRIPTDIR}/create_tables.sql"

# Load trip gtfs data into database
PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy septa.bus_stops FROM '${DATADIR}/google_bus/stops.txt' DELIMITER ',' CSV HEADER;"

PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy septa.bus_routes FROM '${DATADIR}/google_bus/routes.txt' DELIMITER ',' CSV HEADER;"

PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy septa.bus_trips FROM '${DATADIR}/google_bus/trips.txt' DELIMITER ',' CSV HEADER;"


PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy septa.bus_shapes FROM '${DATADIR}/google_bus/shapes.txt' DELIMITER ',' CSV HEADER;"

PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy septa.rail_stops FROM '${DATADIR}/google_rail/stops.txt' DELIMITER ',' CSV HEADER;"


# Download and unzip census population data (didn't find download url)
curl -L 'https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*' > ${DATADIR}/census_population_2020.json
# unzip -o ${DATADIR}/census_population.zip -d ${DATADIR}/census_population


python -c <<EOF
import csv
import json
import pathlib
​
RAW_DATA_DIR = pathlib.Path('${DATADIR}')
PROCESSED_DATA_DIR = pathlib.Path('${DATADIR}')
​
with open(
    RAW_DATA_DIR / 'census_population_2020.json',
    'r', encoding='utf-8',
) as infile:
    data = json.load(infile)
​
with open(
    PROCESSED_DATA_DIR / 'census_population_2020.csv',
    'w', encoding='utf-8',
) as outfile:
    writer = csv.writer(outfile)
    writer.writerows(data)
EOF


# load data into database
PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d musa_509 \
  -c "\copy census.population_2020. FROM '${DATADIR}/census_population_2020.csv' DELIMITER ',' CSV HEADER;"


# Download and unzip pwd parcel data
curl -L https://opendata.arcgis.com/datasets/84baed491de44f539889f2af178ad85c_0.zip > ${DATADIR}/phl_pwd_parcels.zip
unzip -o ${DATADIR}/phl_pwd_parcels.zip -d ${DATADIR}/phl_pwd_parcels

# load parcel data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/phl_pwd_parcels/PWD_PARCELS.shp"


# Download philly neighborhood data
curl -L https://github.com/azavea/geo-data/blob/9e0ac39840803d6218f4503e8a16c7aad0807de4/Neighborhoods_Philadelphia/Neighborhoods_Philadelphia.geojson > ${DATADIR}/Neighborhoods_Philadelphia.geojson
# load neighbourhoods data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
    -nln azavea.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/Neighborhoods_Philadelphia.geojson"

# Download and unzip census data
curl -L https://www2.census.gov/geo/tiger/TIGER2020/BG/tl_2020_42_bg.zip
 > ${DATADIR}/census_blockgroups_2020.zip
unzip -o ${DATADIR}/census_blockgroups_2020.zip -d ${DATADIR}/census_blockgroups_2020
# Load census data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/census_blockgroups_2020/tl_2020_42_bg.shp"



















