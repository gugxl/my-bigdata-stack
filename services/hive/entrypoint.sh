#!/bin/bash
# ~/my-bigdata-stack/services/hive/entrypoint.sh

set -e

COMMAND=$1

# Initialize Metastore schema if not already initialized
if [ "$COMMAND" = "metastore" ]; then
    echo "Checking Hive Metastore schema..."
    schematool -dbType postgres -info || (echo "Schema not found. Initializing..." && schematool -dbType postgres -initSchema)
fi

# Start the requested service
echo "Starting Hive $COMMAND..."
exec hive --service $COMMAND