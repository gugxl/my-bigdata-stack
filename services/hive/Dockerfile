# ~/my-bigdata-stack/services/hive/Dockerfile
FROM bigdata_hadoop:latest

USER root

ARG HIVE_VERSION
ARG PG_JDBC_VERSION
ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH=$PATH:$HIVE_HOME/bin

COPY downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz /tmp/
COPY downloads/postgresql-${PG_JDBC_VERSION}.jar /tmp/
COPY --chown=hadoop:hadoop services/hadoop-base/entrypoint.sh /opt/hadoop/bin/

RUN tar -xzvf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv /tmp/postgresql-${PG_JDBC_VERSION}.jar ${HIVE_HOME}/lib/ \
    && ln -s /opt/hadoop/etc/hadoop /opt/hive/conf/hadoop \
    && chown -R hadoop:hadoop ${HIVE_HOME}

USER hadoop

COPY --chown=hadoop:hadoop services/hive/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]