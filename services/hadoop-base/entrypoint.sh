#!/bin/bash
set -e

if [ "$1" = "hdfs" ] && [ "$2" = "namenode" ]; then
    if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
        echo "Formatting NameNode..."
        $HADOOP_HOME/bin/hdfs namenode -format -force
    fi
fi

sudo service ssh start
exec "$@"