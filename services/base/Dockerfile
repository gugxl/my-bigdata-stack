# my-bigdata-stack/services/base/Dockerfile
FROM ubuntu:22.04

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 第一个 RUN 指令，用于安装软件包。注意这一段的末尾没有续行符 '\'
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk wget ssh rsync curl sudo \
  && rm -rf /var/lib/apt/lists/*

# 第二个 RUN 指令，用于创建符号链接
RUN ln -s /usr/lib/jvm/java-11-openjdk-* /usr/lib/jvm/java-11

# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-11
ENV PATH=$PATH:$JAVA_HOME/bin

# 创建用户和设置权限
RUN useradd -ms /bin/bash -G sudo hadoop
RUN echo 'hadoop ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 切换到 hadoop 用户
USER hadoop
WORKDIR /home/hadoop

# 配置 SSH 免密登录
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys