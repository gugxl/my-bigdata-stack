# ~/my-bigdata-stack/services/hadoop-base/Dockerfile
FROM ubuntu:22.04

# --- Basic dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    wget \
    ssh \
    rsync \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# --- Hadoop Installation ---
ARG HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

COPY ../../downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/
RUN tar -xzvf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm /tmp/hadoop-${HADOOP_VERSION}.tar.gz \
    && mkdir -p ${HADOOP_HOME}/data/namenode \
    && mkdir -p ${HADOOP_HOME}/data/datanode \
    && mkdir -p ${HADOOP_LOG_DIR} \
    && mkdir -p /var/run/hadoop

# Add hadoop user and group for permissions
RUN groupadd -r hadoop --gid=1000 && useradd -r -g hadoop --uid=1000 -d ${HADOOP_HOME} hadoop
RUN chown -R hadoop:hadoop ${HADOOP_HOME} ${HADOOP_LOG_DIR} /var/run/hadoop

USER hadoop

# SSH config for passwordless login
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

COPY entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]