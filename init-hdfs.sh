#!/bin/bash

# my-bigdata-stack\init-hdfs.sh

echo "--- Initializing HDFS directories and permissions ---"
echo "Waiting for NameNode to be ready..."

# 等待 NameNode 启动并退出安全模式
# 我们直接在 namenode 容器内部执行检查，更可靠
until docker exec namenode hdfs dfsadmin -safemode get | grep -q "Safe mode is OFF"; do
  printf '.'
  sleep 5
done

echo -e "\nNameNode is ready. Creating HDFS directories..."

# 定义一个函数来执行 HDFS 命令，增加重试和日志
function hdfs_exec() {
  docker exec namenode hdfs dfs "$@"
}

hdfs_exec -mkdir -p /tmp && hdfs_exec -chmod 777 /tmp
hdfs_exec -mkdir -p /user/history && hdfs_exec -chmod 777 /user/history
hdfs_exec -mkdir -p /user/hive/warehouse && hdfs_exec -chmod g+w /user/hive/warehouse
hdfs_exec -mkdir -p /spark-logs && hdfs_exec -chmod 777 /spark-logs
hdfs_exec -mkdir -p /hbase && hdfs_exec -chown hadoop:hadoop /hbase
hdfs_exec -mkdir -p /user/hadoop && hdfs_exec -chown hadoop:hadoop /user/hadoop

echo "--- HDFS initialization complete. ---"