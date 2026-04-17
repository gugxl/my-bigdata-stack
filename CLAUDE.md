# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized big data stack built with Docker Compose, providing a complete development environment for Apache Hadoop ecosystem components including HDFS, YARN, HBase, Hive, Spark, Kafka, Flink, and Airflow.

## Architecture

The system follows a layered architecture with service dependencies:

```
┌─────────────────────────────────────────────────┐
│                   Airflow                       │ (Workflow orchestration)
├─────────────────────────────────────────────────┤
│               Spark                             │ (Big data compute engine)
├─────────────────────────────────────────────────┤
│         HBase            Hive                   │ (NoSQL DB, Data warehouse)
├─────────────────────────────────────────────────┤
│         Kafka            Flink                  │ (Streaming & messaging)
├─────────────────────────────────────────────────┤
│                   YARN                          │ (Resource manager)
├─────────────────────────────────────────────────┤
│                   HDFS                          │ (Distributed storage)
├─────────────────────────────────────────────────┤
│          ZooKeeper       PostgreSQL             │ (Coordination & metastore)
└─────────────────────────────────────────────────┘
```

## Build System

The project uses a multi-stage Docker build approach:

### Builder Images (used only for building)
- `base-builder` → creates `my-bigdata-base:latest`
- `hadoop-builder` → creates `bigdata-hadoop-base:latest` 
- `hbase-builder` → creates `bigdata-hbase:latest`
- `hive-builder` → creates `bigdata-hive:latest`
- `spark-builder` → creates `bigdata-spark:latest`

### Build Commands

**Full build (recommended for first time):**
```bash
# Build all images in dependency order
./rebuild.sh
```

**Manual build steps:**
```bash
# 1. Build base image first
docker compose --profile build build base-builder --no-cache

# 2. Build component images (requires base image)
docker compose --profile build build hadoop-builder --no-cache
docker compose --profile build build hbase-builder --no-cache  
docker compose --profile build build hive-builder --no-cache
docker compose --profile build build spark-builder --no-cache
```

**Rebuild specific component:**
```bash
./rebuild.sh -s hadoop-builder
```

## Service Management

### Start/Stop Services
```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View service status
docker compose ps
```

### Required Initialization

**HDFS initialization (required after first build):**
```bash
# Make script executable and run
chmod +x init-hdfs.sh
./init-hdfs.sh

# Start history server after HDFS init
docker compose up -d historyserver
```

**Airflow initialization (if using Airflow):**
```bash
# 1. Generate Fernet key
docker compose run --rm airflow-webserver python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# 2. Update .env with AIRFLOW__CORE__FERNET_KEY

# 3. Initialize database  
docker compose run --rm airflow-webserver airflow db init

# 4. Create admin user
docker compose run --rm airflow-webserver airflow users create \
  --username admin --firstname Air --lastname Flow --role Admin \
  --email admin@example.com --password admin

# 5. Restart services
docker compose up -d
```

## Network & Ports

All services run on `bigdata-net` bridge network. Key web UIs:

- **Hadoop NameNode**: http://localhost:9870
- **YARN ResourceManager**: http://localhost:8088  
- **YARN History Server**: http://localhost:19888
- **HBase Master**: http://localhost:16010
- **Hive HiveServer2**: http://localhost:10002
- **Flink Dashboard**: http://localhost:8081
- **Airflow**: http://localhost:8080 (admin/admin)
- **PostgreSQL**: localhost:15432

## Common Development Tasks

### Working with Hadoop/HDFS
```bash
# Check HDFS status
docker exec namenode hdfs dfsadmin -report

# List HDFS directories  
docker exec namenode hdfs dfs -ls /

# Upload file to HDFS
docker exec namenode hdfs dfs -put /local/path /hdfs/path
```

### Working with HBase
```bash
# Enter HBase shell
docker exec -it hbase-master hbase shell

# Check HBase status
docker exec hbase-master hbase status
```

### Working with Hive
```bash
# Connect to Hive via beeline
docker exec -it hive-server beeline -u "jdbc:hive2://hive-server:10000"

# Check metastore connection
docker logs hive-metastore
```

### Working with Spark
```bash
# Start Spark shell
docker exec -it spark-client spark-shell

# Submit Spark job
docker exec spark-client spark-submit /path/to/job.py
```

### Working with Kafka
```bash
# Create test topic
docker exec kafka kafka-topics.sh --bootstrap-server kafka:9092 \
  --create --topic test-topic --partitions 1 --replication-factor 1

# List topics
docker exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
```

## Troubleshooting

### Service Dependencies
Services have strict startup dependencies. If a service fails to start:
1. Check if dependent services are healthy: `docker compose ps`
2. Review logs: `docker compose logs <service-name>`
3. Verify initialization completed (especially HDFS)

### Common Issues
- **HDFS SafeMode**: Wait for `hdfs dfsadmin -safemode get` to show "OFF" before accessing HDFS
- **Hive Metastore**: Ensure PostgreSQL is ready before starting Hive services  
- **Resource Limits**: Big data components are memory-intensive; ensure Docker has adequate resources

### Log Inspection
```bash
# View logs for specific service
docker compose logs -f <service-name>

# View logs for all services
docker compose logs -f

# Container shell access
docker exec -it <container-name> bash
```

## Configuration

### Environment Variables
Key variables in `.env`:
- Component versions (HADOOP_VERSION, SPARK_VERSION, etc.)
- PostgreSQL metastore credentials
- Service-specific configurations

### Config Files
- `configs/hadoop/`: Core Hadoop configuration files
- `configs/hive/`: Hive configuration and logging
- `configs/spark/`: Spark defaults

## Data Persistence

The following volumes persist data:
- `hadoop_namenode_data`, `hadoop_datanode_data`: HDFS data
- `hbase_data`: HBase tables
- `postgres_metastore_data`: Hive metastore
- `zookeeper_data`: ZooKeeper state

## Development Workflow

1. **Initial Setup**: `./rebuild.sh` → `./init-hdfs.sh` → verify web UIs
2. **Code Changes**: Rebuild affected service → restart → test
3. **Data Reset**: `docker compose down --volumes` to clear all data
4. **Clean Rebuild**: `./rebuild.sh -f` for complete environment reset

## Downloads Directory

Pre-downloaded binaries in `downloads/`:
- hadoop-3.3.6.tar.gz
- hbase-2.5.6-bin.tar.gz  
- apache-hive-4.0.1-bin.tar.gz
- spark-3.5.0-bin-hadoop3.tgz
- postgresql-42.7.1.jar

These are used during Docker image builds and should not be modified.