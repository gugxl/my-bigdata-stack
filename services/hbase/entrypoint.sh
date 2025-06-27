#!/bin/bash
# ~/my-bigdata-stack/services/hbase/entrypoint.sh

set -e

# Wait for HDFS to be available
# A simple check: wait until the hdfs command can list the root directory.
echo "Waiting for HDFS to be ready..."
until hdfs dfs -ls /; do
  echo "HDFS not ready yet, sleeping..."
  sleep 5
done
echo "HDFS is ready."

# Execute the command passed from docker-compose
# e.g., ["master", "start"] or ["regionserver", "start"]
exec $HBASE_HOME/bin/hbase.sh "$@"