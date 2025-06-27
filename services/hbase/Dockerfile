FROM bigdata-hadoop-base:latest

USER root
ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=/opt/hbase/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/

RUN tar -xzvf /tmp/hbase-${HBASE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz \
    && mkdir -p ${HBASE_LOG_DIR} \
    && chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

USER hadoop
WORKDIR /home/hadoop

COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/

RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]