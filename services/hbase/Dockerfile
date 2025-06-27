# ~/my-bigdata-stack/services/hbase/Dockerfile
FROM my-bigdata-base:latest

USER root

ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=/opt/hbase/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/
COPY --chown=hadoop:hadoop services/hadoop-base/entrypoint.sh /opt/hadoop/bin/

RUN tar -xzvf /tmp/hbase-${HBASE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz \
    && mkdir -p ${HBASE_LOG_DIR} \
    && ln -s /opt/hadoop/etc/hadoop /opt/hbase/conf/hadoop \
    && chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

USER hadoop

COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]