FROM my-bigdata-base:latest

ARG HADOOP_VERSION

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native
ENV HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib/native"
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

USER root

# 安装压缩与加密依赖库
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libsnappy1v5 \
        libsnappy-dev \
        libzstd1 \
        libbz2-1.0 \
        libssl3 \
        libisal2 \
        liblz4-1 \
        liblz4-dev && \
    rm -rf /var/lib/apt/lists/* && \
    echo "export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:\$LD_LIBRARY_PATH" >> /etc/profile

# 解压 Hadoop 并配置本地库
COPY --chown=hadoop:hadoop downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/

RUN tar -xzvf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ && \
    mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop-${HADOOP_VERSION}.tar.gz && \
    mkdir -p ${HADOOP_HOME}/data/namenode ${HADOOP_HOME}/data/datanode ${HADOOP_LOG_DIR} /var/run/hadoop && \
    chown -R hadoop:hadoop /opt/hadoop* ${HADOOP_LOG_DIR} /var/run/hadoop && \
    ln -sf /usr/lib/x86_64-linux-gnu/libsnappy.so.1 ${HADOOP_HOME}/lib/native/libsnappy.so.1 && \
    ln -sf /usr/lib/x86_64-linux-gnu/liblz4.so.1 ${HADOOP_HOME}/lib/native/liblz4.so.1 && \
    ln -sf /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/libcrypto.so && \
    ln -sf /usr/lib/x86_64-linux-gnu/libisal.so.2 ${HADOOP_HOME}/lib/native/libisal.so.2

# 使用 snappy-java 替代 Hadoop 本地库
ENV HADOOP_OPTS="${HADOOP_OPTS} -Dorg.xerial.snappy.use.systemlib=true"

# 配置动态库路径
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:${HADOOP_HOME}/lib/native
# 启动脚本
COPY --chown=hadoop:hadoop services/hadoop-base/entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
