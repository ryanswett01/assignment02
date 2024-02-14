#!/bin/env bash

set -e
set -x

POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_NAME=${POSTGRES_NAME:-assignment02}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASS=${POSTGRES_PASS:-postgres}
PYTHON_COMMAND=${PYTHON_COMMAND:-python3}

SCRIPTDIR=$(readlink -f $(dirname $0))
DATADIR=$(readlink -f $(dirname $0)/../__data__)
mkdir -p ${DATADIR}

# Download and unzip gtfs data
curl -L https://github.com/septadev/GTFS/releases/download/v202402070/gtfs_public.zip > ${DATADIR}/gtfs_public.zip
unzip -o ${DATADIR}/gtfs_public.zip -d ${DATADIR}/gtfs_public
unzip -o ${DATADIR}/gtfs_public/google_bus.zip -d ${DATADIR}/google_bus
unzip -o ${DATADIR}/gtfs_public/google_rail.zip -d ${DATADIR}/google_rail

# Create a convenience function for running psql with DB credentials
function run_psql() {
  PGPASSWORD=${POSTGRES_PASS} psql \
  -h ${POSTGRES_HOST} \
  -p ${POSTGRES_PORT} \
  -U ${POSTGRES_USER} \
  -d ${POSTGRES_NAME} \
  "$@"
}

# Create a connection string for ogr2ogr
POSTGRES_CONNSTRING="host=${POSTGRES_HOST} port=${POSTGRES_PORT} dbname=${POSTGRES_NAME} user=${POSTGRES_USER} password=${POSTGRES_PASS}"

# Create database
PGPASSWORD=${POSTGRES_PASS} createdb \
  -h ${POSTGRES_HOST} \
  -p ${POSTGRES_PORT} \
  -U ${POSTGRES_USER} \
  ${POSTGRES_NAME}

# Initialize table structure
run_psql -f "${SCRIPTDIR}/create_tables.sql"

# Load trip gtfs data into database
sed -i 's/\r//g' ${DATADIR}/google_bus/stops.txt
run_psql -c "\copy septa.bus_stops FROM '${DATADIR}/google_bus/stops.txt' DELIMITER ',' CSV HEADER;"

# Use sed to replace \r\n with \n in the google_bus/routes.txt file
sed -i 's/\r//g' ${DATADIR}/google_bus/routes.txt
run_psql -c "\copy septa.bus_routes FROM '${DATADIR}/google_bus/routes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_bus/trips.txt
run_psql -c "\copy septa.bus_trips FROM '${DATADIR}/google_bus/trips.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_bus/shapes.txt
run_psql -c "\copy septa.bus_shapes FROM '${DATADIR}/google_bus/shapes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_rail/stops.txt
run_psql -c "\copy septa.rail_stops FROM '${DATADIR}/google_rail/stops.txt' DELIMITER ',' CSV HEADER;"


# Download and unzip census population data (didn't find download url)
curl -L 'https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*' > ${DATADIR}/census_population_2020.json
# unzip -o ${DATADIR}/census_population.zip -d ${DATADIR}/census_population


${PYTHON_COMMAND} <<EOF
import csv
import json
import pathlib

RAW_DATA_DIR = pathlib.Path('${DATADIR}')
PROCESSED_DATA_DIR = pathlib.Path('${DATADIR}')

with open(
    RAW_DATA_DIR / 'census_population_2020.json',
    'r', encoding='utf-8',
) as infile:
    data = json.load(infile)

with open(
    PROCESSED_DATA_DIR / 'census_population_2020.csv',
    'w', encoding='utf-8',
) as outfile:
    writer = csv.writer(outfile)
    writer.writerows([
        (row[1], row[0], row[2])
        for row in data
    ])
EOF


# load data into database
run_psql -c "\copy census.population_2020 FROM '${DATADIR}/census_population_2020.csv' DELIMITER ',' CSV HEADER;"


# Download and unzip PWD Stormwater Billing parcel data
curl -L https://opendata.arcgis.com/datasets/84baed491de44f539889f2af178ad85c_0.zip > ${DATADIR}/phl_pwd_parcels.zip
unzip -o ${DATADIR}/phl_pwd_parcels.zip -d ${DATADIR}/phl_pwd_parcels

# load parcel data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"${POSTGRES_CONNSTRING}" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/phl_pwd_parcels/PWD_PARCELS.shp"


# Download philly neighborhood data
curl -L https://github.com/azavea/geo-data/raw/9e0ac39840803d6218f4503e8a16c7aad0807de4/Neighborhoods_Philadelphia/Neighborhoods_Philadelphia.geojson > ${DATADIR}/Neighborhoods_Philadelphia.geojson
# load neighbourhoods data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"${POSTGRES_CONNSTRING}" \
    -nln azavea.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/Neighborhoods_Philadelphia.geojson"

# Download and unzip census data
curl -L https://www2.census.gov/geo/tiger/TIGER2020/BG/tl_2020_42_bg.zip > ${DATADIR}/census_blockgroups_2020.zip
unzip -o ${DATADIR}/census_blockgroups_2020.zip -d ${DATADIR}/census_blockgroups_2020
# Load census data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"${POSTGRES_CONNSTRING}" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/census_blockgroups_2020/tl_2020_42_bg.shp"



















