# Before building this image, be sure to run __scripts__/refresh_pgdata_folder.sh

FROM postgis/postgis:17-3.5

# Copy pre-generated data into the container
COPY __pgdata__ ${PGDATA}
