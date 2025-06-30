#!/bin/bash
set -e

# 将Hadoop的配置文件链接到Spark的conf目录
echo "Linking Hadoop configuration to Spark..."
ln -sf /etc/hadoop/core-site.xml ${SPARK_CONF_DIR}/core-site.xml
ln -sf /etc/hadoop/hdfs-site.xml ${SPARK_CONF_DIR}/hdfs-site.xml
ln -sf /etc/hadoop/yarn-site.xml ${SPARK_CONF_DIR}/yarn-site.xml

echo "Executing command: $@"
# 执行 docker-compose.yml 中定义的 command
exec "$@"