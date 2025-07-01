# my-bigdata-stack/services/hbase/Dockerfile

FROM bigdata-hadoop-base:latest

USER root
ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=${HBASE_HOME}/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:${HBASE_HOME}/bin

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/

# --- 这是根据你提供的准确文件列表编写的最终安装指令 ---
#
# 核心思想：
# 1. 解压 tar 包到 /tmp 目录。
# 2. 将解压后得到的目录 (例如 hbase-2.5.6) 直接重命名并移动到 /opt/hbase。
#    这是最简单、最直接、最不容易出错的方法。
# 3. 删除临时的 tar 包。
# 4. 创建日志目录，并修改所有权。
#
RUN cd /tmp && \
    tar -xzvf hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv /tmp/hbase-* ${HBASE_HOME} && \
    rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz && \
    mkdir -p ${HBASE_LOG_DIR} && \
    chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}
# --- 修改结束 ---

USER hadoop
WORKDIR /home/hadoop

COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/

RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]