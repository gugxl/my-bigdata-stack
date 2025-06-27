# ~/my-bigdata-stack/services/hbase/Dockerfile (CORRECTED)
FROM bigdata_hadoop-base
# Use the image we just named

ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=/opt/hbase/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/
RUN sudo tar -xzvf /tmp/hbase-${HBASE_VERSION}-bin.tar.gz -C /opt/ \
    && sudo mv /opt/hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && sudo rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz \
    && sudo mkdir -p ${HBASE_LOG_DIR} \
    && sudo chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

USER hadoop

COPY services/hbase/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]