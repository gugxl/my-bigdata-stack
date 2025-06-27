#!/bin/bash
# ~/my-bigdata-stack/services/hadoop-base/entrypoint.sh

set -e

# Format NameNode if not formatted
if [ "$1" = "hdfs" ] && [ "$2" = "namenode" ]; then
    if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
        echo "Formatting NameNode..."
        $HADOOP_HOME/bin/hdfs namenode -format -force
    fi
fi

# Start SSH daemon for cluster management scripts
sudo service ssh start

# Execute the command passed to the container
exec "$@"