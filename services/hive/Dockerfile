FROM bigdata-hadoop-base:latest

USER root
ARG HIVE_VERSION
ARG PG_JDBC_VERSION
ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH=$PATH:$HIVE_HOME/bin

COPY downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz /tmp/
COPY downloads/postgresql-${PG_JDBC_VERSION}.jar /tmp/

RUN tar -xzvf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv /tmp/postgresql-${PG_JDBC_VERSION}.jar ${HIVE_HOME}/lib/ \
    && chown -R hadoop:hadoop ${HIVE_HOME}

USER hadoop
WORKDIR /home/hadoop

COPY --chown=hadoop:hadoop services/hive/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]