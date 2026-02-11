# my-bigdata-stack/configs/hbase/hbase-env.sh
export HBASE_MANAGES_ZK=false

# JVM heap size settings
export HBASE_HEAPSIZE=4096
export HBASE_REGIONSERVER_OPTS="-Xmx4g -Xms4g"
export HBASE_MASTER_OPTS="-Xmx2g -Xms2g"