#!/bin/bash
echo "--- Initializing HDFS directories and permissions ---"

# 等待 NameNode 启动并退出安全模式
echo "Waiting for NameNode to exit safe mode..."
until docker exec namenode hdfs dfsadmin -safemode get | grep "Safe mode is OFF"; do
  sleep 5
done

echo "NameNode is ready. Creating HDFS directories..."

docker exec namenode hdfs dfs -mkdir -p /tmp
docker exec namenode hdfs dfs -chmod 777 /tmp

docker exec namenode hdfs dfs -mkdir -p /user/history
docker exec namenode hdfs dfs -chmod 777 /user/history

docker exec namenode hdfs dfs -mkdir -p /user/hive/warehouse
docker exec namenode hdfs dfs -chmod g+w /user/hive/warehouse

docker exec namenode hdfs dfs -mkdir -p /spark-logs
docker exec namenode hdfs dfs -chmod 777 /spark-logs

docker exec namenode hdfs dfs -mkdir -p /hbase
docker exec namenode hdfs dfs -chown hadoop:hadoop /hbase

docker exec namenode hdfs dfs -mkdir -p /user
docker exec namenode hdfs dfs -chown hadoop:hadoop /user

echo "--- HDFS initialization complete. ---"