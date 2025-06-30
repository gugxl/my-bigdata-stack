
1. 下载文件
2. 构件基础镜像
   docker-compose build base-builder hadoop-builder hbase-builder hive-builder spark-builder
 
说明：base-builder是基础镜像 包含 ubuntu jdk和基础环境
hadoop-builder 是 base-builder + hadoop


3. 构件应用镜像
   docker compose up -d


启动

当namenode启动之后执行
./init-hdfs.sh 
脚本

