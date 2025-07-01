# my-bigdata-stack\services\spark\Dockerfile
FROM bigdata-hadoop-base:latest

USER root
ARG SPARK_VERSION
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/

RUN tar -xzvf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && chown -R hadoop:hadoop ${SPARK_HOME}

USER hadoop
WORKDIR /home/hadoop