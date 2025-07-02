
# 1. 下载文件

```bash
wget https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz
wget https://archive.apache.org/dist/hbase/2.5.6/hbase-2.5.6-bin.tar.gz
wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
```
# 2. 构件镜像
## 2.1 构建基础层镜像（所有服务的依赖）
```bash
docker-compose --profile build build
```

说明：base-builder是基础镜像 包含 ubuntu jdk和基础环境

## 2.3 并行构建HBase/Hive/Spark镜像（无相互依赖）
docker-compose build --parallel hbase-builder hive-builder spark-builder

# 3. 启动容器
   docker-compose up -d
# 4. 初始化文件路径
chmod +x init-hdfs.sh
./init-hdfs.sh

docker compose up -d historyserver


