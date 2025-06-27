# ~/my-bigdata-stack/services/hive/Dockerfile
FROM bigdata_hadoop-base

# --- Hive Installation ---
ARG HIVE_VERSION=3.1.3
ARG PG_JDBC_VERSION=42.7.1

ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH=$PATH:$HIVE_HOME/bin

COPY ../../downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz /tmp/
COPY ../../downloads/postgresql-${PG_JDBC_VERSION}.jar /tmp/

RUN tar -xzvf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && cp /tmp/postgresql-${PG_JDBC_VERSION}.jar ${HIVE_HOME}/lib/ \
    && rm /tmp/postgresql-${PG_JDBC_VERSION}.jar \
    && chown -R hadoop:hadoop ${HIVE_HOME}

USER hadoop

COPY entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]