#!/bin/env bash

set -e
set -x

POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_NAME=${POSTGRES_NAME:-assignment02}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASS=${POSTGRES_PASS:-postgres}

SCRIPTDIR=$(readlink -f $(dirname $0))
ROOTDIR=$(readlink -f $(dirname $0)/..)

# Create a convenience function for running psql with DB credentials
function run_psql() {
  PGPASSWORD=${POSTGRES_PASS} psql \
  -h ${POSTGRES_HOST} \
  -p ${POSTGRES_PORT} \
  -U ${POSTGRES_USER} \
  -d ${POSTGRES_NAME} \
  "$@"
}

# Customize database structure
run_psql -f "${ROOTDIR}/db_structure.sql"
