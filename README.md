
# 大数据环境搭建指南：基于 Docker 构建 Hadoop、Hive、HBase、Flink、Kafka 等服务

## 一、引言

在大数据领域，搭建一个包含 Hadoop、Hive、HBase、Flink、Kafka 等服务的开发环境，是进行数据处理和分析的基础。本文将介绍如何使用 **Docker + Docker Compose** 搭建这样一个环境，并提供验证方法。

---

## 二、项目概述

本项目通过 Docker Compose 管理多个大数据服务的容器化部署，涉及的组件包括：

* **协调与数据库**：ZooKeeper、PostgreSQL
* **存储与计算框架**：HDFS、YARN
* **上层大数据组件**：HBase、Hive、Spark
* **实时处理组件**：Kafka、Flink
* **调度与任务编排**：Airflow

---

## 三、环境搭建步骤

### 3.1 下载依赖文件

```bash
wget https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz
wget https://archive.apache.org/dist/hbase/2.5.6/hbase-2.5.6-bin.tar.gz
wget https://archive.apache.org/dist/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
```
放到downloads文件夹下

### 3.2 构建镜像

#### 3.2.1 构建基础镜像

```bash
docker compose --profile build build base-builder --no-cache
```

#### 3.2.2 构建组件镜像

```bash
docker compose --profile build build hadoop-builder --no-cache
docker compose --profile build build hbase-builder --no-cache
docker compose --profile build build hive-builder --no-cache
docker compose --profile build build spark-builder --no-cache
```

### 3.3 启动容器

```bash
docker compose up -d
```

### 3.4 初始化配置

#### 3.4.1 初始化 HDFS

```bash
chmod +x init-hdfs.sh
./init-hdfs.sh
docker compose up -d historyserver
```

#### 3.4.2 初始化 Airflow

1. 生成加密密钥：

   ```bash
   docker compose run --rm airflow-webserver python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
   ```

   将密钥配置到 `AIRFLOW__CORE__FERNET_KEY`（需配置在多个位置）。

2. 初始化数据库：

   ```bash
   docker compose run --rm airflow-webserver airflow db init 
   ```

3. 创建管理员账号：

   ```bash
   docker compose run --rm airflow-webserver      airflow users create        --username admin --firstname Air --lastname Flow --role Admin --email admin@example.com    --password admin
   ```

4. 重启服务：

   ```bash
   docker compose up -d
   ```

---

## 四、服务验证步骤

### 4.1 基础层：协调与数据库

#### ZooKeeper

* 检查状态：

  ```bash
  docker compose ps zookeeper
  ```
* 健康检测：

  ```bash
  echo "ruok" | nc localhost 2181
  ```

  返回 `imok` 表示正常。

#### PostgreSQL

* 确认日志中有 `database system is ready to accept connections`。

---

### 4.2 存储层：HDFS

#### NameNode

* Web UI：[http://localhost:9870](http://localhost:9870)

#### DataNode

* Web UI：[http://localhost:9870/dfshealth.html#tab-datanode](http://localhost:9870/dfshealth.html#tab-datanode)

---

### 4.3 资源调度层：YARN

#### ResourceManager

* Web UI：[http://localhost:8088](http://localhost:8088)

#### NodeManager

* Web UI：[http://localhost:8088/cluster/nodes](http://localhost:8088/cluster/nodes)

#### HistoryServer

* Web UI：[http://localhost:19888](http://localhost:19888)

---

### 4.4 应用层：大数据与实时计算

#### Kafka

* 创建测试 Topic：

  ```bash
  docker exec -it kafka kafka-topics.sh --bootstrap-server kafka:9092 --create --topic test-topic --partitions 1 --replication-factor 1
  docker exec -it kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
  ```

#### HBase Master

* Web UI：[http://localhost:16010](http://localhost:16010)

#### Hive

* **Metastore 日志检查**：确认连接 `postgres-metastore` 正常
* **HiveServer2 Web UI**：[http://localhost:10002](http://localhost:10002)

#### Spark 客户端

* 启动 Spark Shell：

  ```bash
  docker exec -it spark-client spark-shell
  ```

#### Flink

* Web UI：[http://localhost:8081](http://localhost:8081)

#### Airflow

* Web UI：[http://localhost:8080](http://localhost:8080)
* 使用 **admin/admin** 登录

---

## 五、清理环境

```bash
# 停止容器并清理数据卷
docker compose down --volumes --remove-orphans

# 移除构建时的容器
docker compose --profile build down --volumes

# 删除镜像
docker rmi -f $(docker images -q bigdata-hadoop-base)
docker rmi -f $(docker images -q bigdata-hive)
docker rmi -f $(docker images -q bigdata-hbase)
docker rmi -f $(docker images -q bigdata-spark)
docker rmi -f $(docker images -q my-bigdata-base)
```

---

## 六、总结

通过以上步骤，我们基于 **Docker + Docker Compose** 搭建了一个完整的大数据开发环境，并验证了各组件的正常运行。这种容器化方式方便快捷，适合开发和测试使用。

---

## 七、注意事项

* 确保系统已安装 **Docker 和 Docker Compose**。
* 构建镜像和启动容器需要一定时间，请耐心等待。
* 如果某个服务未正常启动，请查看对应容器日志排查问题。


[wiki](https://deepwiki.com/gugxl/my-bigdata-stack)