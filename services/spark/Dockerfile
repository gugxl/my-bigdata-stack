# ~/my-bigdata-stack/services/spark/Dockerfile
FROM bigdata_hadoop:latest

USER root

ARG SPARK_VERSION
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/
COPY --chown=hadoop:hadoop services/hadoop-base/entrypoint.sh /opt/hadoop/bin/

RUN tar -xzvf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && ln -s /opt/hadoop/etc/hadoop /opt/spark/conf/hadoop \
    && chown -R hadoop:hadoop ${SPARK_HOME}

USER hadoop
WORKDIR /home/hadoop