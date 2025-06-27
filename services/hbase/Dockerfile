# ~/my-bigdata-stack/services/hbase/Dockerfile (CORRECTED)
FROM bigdata_hadoop-base:latest
# <--- Inherit from the image that HAS Hadoop

USER root
# Switch to root to install software

# --- HBase Installation ---
# ARG/ENV declarations remain the same
ARG HBASE_VERSION
ENV HBASE_HOME=/opt/hbase
ENV HBASE_CONF_DIR=/opt/hbase/conf
ENV HBASE_LOG_DIR=/var/log/hbase
ENV PATH=$PATH:$HBASE_HOME/bin

# COPY binaries from the build context
COPY downloads/hbase-${HBASE_VERSION}-bin.tar.gz /tmp/

RUN tar -xzvf /tmp/hbase-${HBASE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/hbase-${HBASE_VERSION} ${HBASE_HOME} \
    && rm /tmp/hbase-${HBASE_VERSION}-bin.tar.gz \
    && mkdir -p ${HBASE_LOG_DIR} \
    && chown -R hadoop:hadoop ${HBASE_HOME} ${HBASE_LOG_DIR}

# Switch back to the 'hadoop' user
USER hadoop

# COPY entrypoint script
COPY --chown=hadoop:hadoop services/hbase/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]