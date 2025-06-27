#!/bin/bash
# ~/my-bigdata-stack/services/hbase/entrypoint.sh
set -e
/opt/hadoop/bin/entrypoint.sh
until hdfs dfs -ls /; do
  echo "Waiting for HDFS..."
  sleep 5
done

exec $HBASE_HOME/bin/hbase.sh "$@"