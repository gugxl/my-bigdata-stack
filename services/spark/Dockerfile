# ~/my-bigdata-stack/services/spark/Dockerfile (BETTER VERSION)
FROM bigdata_hadoop-base

ARG SPARK_VERSION
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/
RUN sudo tar -xzvf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt/ \
    && sudo mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && sudo rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && sudo chown -R hadoop:hadoop ${SPARK_HOME}

# Copy hive-site.xml to spark conf to enable hive support
COPY configs/hive/hive-site.xml ${SPARK_HOME}/conf/

USER hadoop