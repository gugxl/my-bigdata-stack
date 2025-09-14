
# 大数据环境搭建指南：基于 Docker 构建 Hadoop、Hive、HBase、Flink、Kafka 等服务

## 一、引言

在大数据领域，搭建一个包含 Hadoop、Hive、HBase、Flink、Kafka 等服务的开发环境是进行数据处理和分析的基础。本文将详细介绍如何使用 Docker 和 Docker Compose 来搭建这样一个大数据环境，同时还会提供验证各个服务是否正常运行的方法。

## 二、项目概述

本项目通过 Docker Compose 来管理多个大数据服务的容器化部署，涉及的服务包括 ZooKeeper、Postgresql、HDFS、YARN、HBase、Hive、Spark、**Kafka、Flink** 和 **Airflow** 等。每个服务都有对应的 Docker 镜像，并且可以通过配置文件进行定制化。

## 三、搭建步骤

### 3.1 下载文件

首先，我们需要下载所需的大数据组件包和 JDBC 驱动。可以使用以下命令进行下载：

```bash
wget https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz
wget https://archive.apache.org/dist/hbase/2.5.6/hbase-2.5.6-bin.tar.gz
wget https://archive.apache.org/dist/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz
wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
```

### 3.2 构建镜像

#### 3.2.1 构建基础层镜像

基础层镜像包含了所有服务的依赖，使用以下命令构建：

```bash
docker compose --profile build build base-builder --no-cache
```

说明：`base-builder` 是基础镜像，包含 Ubuntu、JDK 和基础环境。

#### 3.2.2 构建 HBase/Hive/Spark 镜像

```bash
docker compose --profile build build hadoop-builder --no-cache
docker compose --profile build build hbase-builder --no-cache
docker compose --profile build build hive-builder --no-cache
docker compose --profile build build spark-builder --no-cache
```

### 3.3 启动容器

使用以下命令启动所有服务的容器：

```bash
docker compose up -d
```

### 3.4 初始化文件路径

在启动容器后，需要对 HDFS 进行初始化，包括创建必要的目录和设置权限。执行以下脚本：

```bash
chmod +x init-hdfs.sh
./init-hdfs.sh
docker compose up -d historyserver
```


### 3.4.1初始化 airflow
首先创建密钥
```bash
docker compose run --rm airflow-webserver python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```
将生成的密钥配置到AIRFLOW__CORE__FERNET_KEY 参数上注意有两个地方

初始化数据库
```bash
docker compose run --rm airflow-webserver airflow db init 
```
重新启动
```http request
docker compose up -d 
```

### 3.5 Spark 客户端（spark-client）服务搭建

`spark-client` 服务依赖于 `hiveserver2` 和 `hbase-master` 服务，在上述服务启动并验证正常后，`spark-client` 会自动启动。以下是其相关配置说明：

- **依赖服务**：`hiveserver2` 和 `hbase-master` 服务。
- **配置挂载**：在 `docker-compose.yml` 中，将以下配置文件挂载到 `spark-client` 容器内：
  - `./configs/spark:/opt/spark/conf`：Spark 相关配置文件。
  - `./configs/hadoop:/etc/hadoop`：Hadoop 相关配置文件。
  - `./configs/hive:/opt/hive/conf`：Hive 相关配置文件。
- **启动命令**：`docker compose` 启动时，`spark-client` 的启动命令为 `tail -f /dev/null`，保持容器处于运行状态。

**重要：Airflow 首次启动初始化**

首次启动 Airflow 前，需要先初始化其数据库。请按顺序执行以下命令：

```bash
# 1. 确保 PostgreSQL 容器已启动
docker compose up -d postgres-metastore

# 2. 初始化数据库并创建管理员用户。请将 'admin' 和 'your_password' 替换为你自己的用户名和密码
docker compose run --rm airflow-scheduler bash -c "airflow db init && airflow users create --username admin --password your_password --firstname admin --lastname admin --role Admin --email admin@example.com"
```

完成初始化后，你就可以启动完整的 Airflow 服务了。

## 四、服务验证

为了确保每个服务都正常运行，我们需要按照服务依赖的从底层到上层的顺序进行验证。

### 4.1 第一层：基础协调与数据库服务

#### 4.1.1 ZooKeeper

- **容器状态**：`docker compose ps zookeeper`，状态应为 `Up`。
- **日志检查**：`docker compose logs zookeeper`，寻找 `binding to port 0.0.0.0/0.0.0.0:2181`，且日志中不应有任何 `ERROR` 或 `Exception`。
- **端口连接**：从终端执行 `echo "ruok" | nc localhost 2181`，如果返回 `imok`，则表示 ZooKeeper 服务完全正常。

#### 4.1.2 PostgreSQL

- **容器状态**：`docker compose ps postgres-metastore`，状态应为 `Up`。
- **日志检查**：`docker compose logs postgres-metastore`，寻找 `database system is ready to accept connections`。

### 4.2 第二层：核心存储 (HDFS)

#### 4.2.1 NameNode

- **容器状态**：`docker compose ps namenode`，状态应为 `Up (healthy)`。
- **日志检查**：`docker compose logs namenode`，首次启动会有 `STARTUP_MSG: Starting NameNode` 和 `successfully formatted` 的日志；正常运行时，日志不应有 `ERROR` 或 `Exception`，寻找 `Serving GSSAPI ...` 和 `IPC Server handler ...` 等信息。
- **Web UI**：在浏览器中访问 [http://localhost:9870](https://www.google.com/search?q=http://localhost:9870)，能看到 HDFS 的管理界面，在 "Datanodes" 标签页下应能看到活动的 DataNode。

#### 4.2.2 DataNode

- **容器状态**：`docker compose ps datanode`，状态应为 `Up`。
- **日志检查**：`docker compose logs datanode`，寻找 `STARTUP_MSG: Starting DataNode` 或 `Block pool ... registered with namenode`。
- **NameNode Web UI 确认**：访问 [http://localhost:9870/dfshealth.html\#tab-datanode](https://www.google.com/search?q=http://localhost:9870/dfshealth.html%23tab-datanode)，能看到至少一个 "Live" 的 DataNode，并且它的状态是 "In Service"。

### 4.3 第三层：资源调度 (YARN)

#### 4.3.1 ResourceManager

- **容器状态**：`docker compose ps resourcemanager`，状态应为 `Up (healthy)`。
- **日志检查**：`docker compose logs resourcemanager`，寻找 `STARTUP_MSG: Starting ResourceManager` 和 `Transitioned to active state`，日志中不应再有关于队列初始化失败的错误。
- **Web UI**：在浏览器中访问 [http://localhost:8088](https://www.google.com/search?q=http://localhost:8088)，能看到 YARN 的管理界面，在 "Nodes" 标签页下应能看到活动的 NodeManager，在 "Scheduler" 菜单下应能看到配置的 `root.default` 队列。

#### 4.3.2 NodeManager

- **容器状态**：`docker compose ps nodemanager`，状态应为 `Up`。
- **日志检查**：`docker compose logs nodemanager`，寻找 `STARTUP_MSG: Starting NodeManager` 和 `Registered with ResourceManager as nodemanager`。
- **ResourceManager Web UI 确认**：访问 [http://localhost:8088/cluster/nodes](https://www.google.com/search?q=http://localhost:8088/cluster/nodes)，能看到至少一个状态为 "RUNNING" 的节点。

#### 4.3.3 HistoryServer

- **容器状态**：`docker compose ps historyserver`，状态应为 `Up`。
- **日志检查**：`docker compose logs historyserver`，寻找 `STARTUP_MSG: Starting JobHistoryServer` 和 `JobHistoryServer metrics system started`。
- **Web UI**：在浏览器中访问 [http://localhost:19888](https://www.google.com/search?q=http://localhost:19888)，能看到 "JobHistory" 的界面，即使里面没有任何作业记录。

### 4.4 第四层及以上：应用层 (HBase, Hive, Spark, Kafka, Flink, Airflow)

#### 4.4.1 Kafka

- **容器状态**：`docker compose ps kafka`，状态应为 `Up`。
- **日志检查**：`docker compose logs kafka`，寻找 `Kafka Server started`。
- **功能验证**：进入 Kafka 容器，尝试创建一个主题并列出所有主题：
  ```bash
  docker exec -it kafka kafka-topics.sh --bootstrap-server kafka:9092 --create --topic test-topic --partitions 1 --replication-factor 1
  docker exec -it kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
  ```
  如果能看到 `test-topic`，则表示 Kafka 服务正常。

#### 4.4.2 HBase Master

- **容器状态**：`docker compose ps hbase-master`，状态应为 `Up`。
- **日志检查**：`docker compose logs hbase-master`，寻找 `Master has completed initialization`。
- **Web UI**：访问 [http://localhost:16010](https://www.google.com/search?q=http://localhost:16010)，能看到 HBase Master 的 UI，并且在 "Region Servers" 部分能看到活动的 RegionServer。

#### 4.4.3 Hive Metastore

- **容器状态**：`docker compose ps hive-metastore`，状态应为 `Up`。
- **日志检查**：`docker compose logs hive-metastore`，寻找 `Starting Hive Metastore Server` 和 `Opened a connection to metastore`，并且不应有连接 `postgres-metastore` 失败的错误，首次启动会有 `schemaTool` 相关的日志。

#### 4.4.4 HiveServer2

- **容器状态**：`docker compose ps hiveserver2`，状态应为 `Up`。
- **日志检查**：`docker compose logs hiveserver2`，寻找 `Starting HiveServer2` 和 `HiveServer2 is started`。
- **Web UI**：访问 [http://localhost:10002](https://www.google.com/search?q=http://localhost:10002)，能看到 HiveServer2 的 Web UI。

#### 4.4.5 Spark 客户端（spark-client）

- **容器状态**：`docker compose ps spark-client`，状态应为 `Up`。
- **进入容器验证**：可以使用以下命令进入 `spark-client` 容器：
  ```bash
  docker exec -it spark-client bash
  ```
  进入容器后，可以尝试执行一些简单的 Spark 命令，例如启动 Spark Shell：
  ```bash
  spark-shell
  ```
  如果能够正常启动 Spark Shell，则说明 `spark-client` 服务正常。

#### 4.4.6 Flink

- **容器状态**：`docker compose ps flink-jobmanager` 和 `docker compose ps flink-taskmanager`，状态应均为 `Up`。
- **日志检查**：`docker compose logs flink-jobmanager`，寻找 `Starting Flink jobmanager process`。`docker compose logs flink-taskmanager`，寻找 `Registered with JobManager`。
- **Web UI**：访问 [http://localhost:8081](https://www.google.com/search?q=http://localhost:8081)，能看到 Flink 的 Web UI。

#### 4.4.7 Airflow

- **容器状态**：`docker compose ps airflow-webserver` 和 `docker compose ps airflow-scheduler`，状态应均为 `Up`。
- **Web UI**：访问 [http://localhost:8080](https://www.google.com/search?q=http://localhost:8080)，能看到 Airflow 的登录界面。使用之前创建的管理员账户登录。

## 五、清理

清理容器和扩展卷

```bash
docker compose down --volumes --remove-orphans
```

移除构建中使用的容器

```bash
docker compose --profile build down --volumes
```

删除镜像

```bash
docker rmi -f $(docker images -q bigdata-hadoop-base)
docker rmi -f $(docker images -q bigdata-hive)
docker rmi -f $(docker images -q bigdata-hbase)
docker rmi -f $(docker images -q bigdata-spark)
docker rmi -f $(docker images -q my-bigdata-base)
```

## 六、总结

通过以上步骤，我们成功地使用 Docker 和 Docker Compose 搭建了一个包含多个大数据服务的开发环境，并验证了每个服务的正常运行。这种容器化的部署方式不仅方便快捷，而且易于管理和维护。希望本文能对大数据开发者有所帮助。

## 七、注意事项

- 确保你的系统已经安装了 Docker 和 Docker Compose。
- 在构建镜像和启动容器时，可能需要一些时间，请耐心等待。
- 如果在验证过程中发现某个服务出现问题，可以查看相应的日志文件进行排查。