
1. 下载文件
2. 构件基础镜像
   docker-compose build base-builder hadoop-builder hbase-builder hive-builder spark-builder
 
说明：base-builder是基础镜像 包含 ubuntu jdk和基础环境
hadoop-builder 是 base-builder + hadoop



3. 构件应用镜像
   docker-compose up --build -d
4. 初始化文件路径
chmod +x init-hdfs.sh
./init-hdfs.sh

docker compose up -d historyserver


