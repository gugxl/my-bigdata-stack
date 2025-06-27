# ~/my-bigdata-stack/services/zookeeper/Dockerfile
FROM ubuntu:22.04

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    wget \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

ARG ZOOKEEPER_VERSION
ENV ZOOKEEPER_HOME=/opt/zookeeper
ENV PATH=$PATH:$ZOOKEEPER_HOME/bin

COPY downloads/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz /tmp/

RUN tar -xzvf /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt/ \
    && mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin ${ZOOKEEPER_HOME} \
    && rm /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

COPY services/zookeeper/zoo.cfg ${ZOOKEEPER_HOME}/conf/

ENTRYPOINT ["zkServer.sh", "start-foreground"]