#!/bin/bash
# my-bigdata-stack/services/hbase/entrypoint.sh

set -e

until hdfs dfs -ls / >/dev/null 2>&1; do
  echo "Waiting for HDFS to be ready..."
  sleep 5
done
echo "HDFS is ready. Starting HBase..."

exec $HBASE_HOME/bin/hbase "$@"