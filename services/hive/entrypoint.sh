#!/bin/bash
# ~/my-bigdata-stack/services/hive/entrypoint.sh
set -e
/opt/hadoop/bin/entrypoint.sh

if [ "$1" = "metastore" ]; then
    schematool -dbType postgres -info || schematool -dbType postgres -initSchema
fi

exec hive --service "$@"