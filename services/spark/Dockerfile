# ~/my-bigdata-stack/services/spark/Dockerfile
FROM bigdata_hadoop-base

# --- Spark Installation ---
ARG SPARK_VERSION=3.5.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

COPY ../../downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/
RUN tar -xzvf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && chown -R hadoop:hadoop ${SPARK_HOME}

# Copy hive-site.xml to spark conf to enable hive support
COPY ../../configs/hive/hive-site.xml ${SPARK_HOME}/conf/

USER hadoop