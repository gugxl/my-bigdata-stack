# ~/my-bigdata-stack/services/hadoop-base/Dockerfile
FROM my-bigdata-base:latest

ARG HADOOP_VERSION
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

COPY --chown=hadoop:hadoop downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/

RUN sudo tar -xzvf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ \
    && sudo mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && sudo rm /tmp/hadoop-${HADOOP_VERSION}.tar.gz \
    && sudo mkdir -p ${HADOOP_HOME}/data/namenode \
    && sudo mkdir -p ${HADOOP_HOME}/data/datanode \
    && sudo mkdir -p ${HADOOP_LOG_DIR} \
    && sudo mkdir -p /var/run/hadoop \
    && sudo chown -R hadoop:hadoop /opt/hadoop* ${HADOOP_LOG_DIR} /var/run/hadoop

COPY --chown=hadoop:hadoop services/hadoop-base/entrypoint.sh /opt/
ENTRYPOINT ["/opt/entrypoint.sh"]