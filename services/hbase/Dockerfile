FROM bigdata-hadoop-base:latest

USER root
ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=${HBASE_HOME}/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:${HBASE_HOME}/bin
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:/opt/hadoop/lib/native

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/

RUN cd /tmp && \
    tar -xzvf hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv /tmp/hbase-${HBASE_VERSION} ${HBASE_HOME} && \
    rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz && \
    mkdir -p ${HBASE_LOG_DIR} && \
    chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

USER hadoop
WORKDIR /home/hadoop

COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/

RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
