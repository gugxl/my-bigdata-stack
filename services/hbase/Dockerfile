# my-bigdata-stack/services/hbase/Dockerfile

FROM bigdata-hadoop-base:latest

USER root
ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=${HBASE_HOME}/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:${HBASE_HOME}/bin

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/

# --- 基于对 tar 包内部结构的精确了解编写的最终指令 ---
# 1. 主动创建 /opt/hbase 目录。
# 2. 解压 tar 包到 /tmp 目录。
# 3. 将解压后得到的目录里面的所有内容 (*) 移动到 /opt/hbase 中。
#    这个方法比逐个移动更简洁，也更可靠，因为它不依赖于子目录的具体名称。
# 4. 删除临时的 tar 包和解压后留下的空目录。
# 5. 创建日志目录，并修改所有权。
RUN mkdir -p ${HBASE_HOME} && \
    cd /tmp && \
    tar -xzvf hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv /tmp/hbase-*/lib/* ${HBASE_HOME}/lib && \
    mv /tmp/hbase-*/bin/* ${HBASE_HOME}/bin && \
    mv /tmp/hbase-*/conf/* ${HBASE_HOME}/conf && \
    rm -rf /tmp/hbase-* && \
    rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz && \
    mkdir -p ${HBASE_LOG_DIR} && \
    chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

USER hadoop
WORKDIR /home/hadoop

COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/

RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]