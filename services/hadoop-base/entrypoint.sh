#!/bin/bash
# ~/my-bigdata-stack/services/hadoop-base/entrypoint.sh
set -e

if [ "$1" = "hdfs" ] && [ "$2" = "namenode" ]; then
    if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
        echo "Formatting NameNode..."
        $HADOOP_HOME/bin/hdfs namenode -format -force
    fi
fi

# Start SSH daemon, required by some Hadoop scripts (e.g., start-dfs.sh)
# Even if we don't use those scripts, it's good practice.
sudo service ssh start

exec "$@"