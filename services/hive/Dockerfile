# ~/my-bigdata-stack/services/hive/Dockerfile (CORRECTED)
FROM bigdata_hadoop-base

ARG HIVE_VERSION
ARG PG_JDBC_VERSION

ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH=$PATH:$HIVE_HOME/bin

COPY downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz /tmp/
COPY downloads/postgresql-${PG_JDBC_VERSION}.jar /tmp/

RUN sudo tar -xzvf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt/ \
    && sudo mv /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && sudo rm /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && sudo cp /tmp/postgresql-${PG_JDBC_VERSION}.jar ${HIVE_HOME}/lib/ \
    && sudo rm /tmp/postgresql-${PG_JDBC_VERSION}.jar \
    && sudo chown -R hadoop:hadoop ${HIVE_HOME}

USER hadoop

COPY services/hive/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]