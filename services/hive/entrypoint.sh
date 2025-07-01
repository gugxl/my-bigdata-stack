#!/bin/bash
# my-bigdata-stack\services\hive\entrypoint.sh

set -e

if [ "$1" = "metastore" ]; then
    echo "Checking Hive Metastore schema..."
    # Give postgres some time to initialize
    sleep 10
    schematool -dbType postgres -info || (echo "Schema not found. Initializing..." && schematool -dbType postgres -initSchema)
fi

echo "Starting Hive service: $1"
exec hive --service "$@"