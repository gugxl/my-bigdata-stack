# ~/my-bigdata-stack/services/base/Dockerfile
FROM ubuntu:22.04

# Change the software source to a faster mirror in China.
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# Install all common dependencies. This layer will be cached.
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    wget \
    ssh \
    rsync \
    curl \
    sudo \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Create a standard user 'hadoop' with passwordless sudo.
RUN useradd -ms /bin/bash -G sudo hadoop
RUN echo 'hadoop ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER hadoop
WORKDIR /home/hadoop

# Set up passwordless SSH for the hadoop user.
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys