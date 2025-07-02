# my-bigdata-stack/services/base/Dockerfile
FROM ubuntu:22.04

# 1. 设置 TZ 环境变量，很多程序会直接读取这个变量
ENV TZ=Asia/Shanghai

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 2. 在一个 RUN 指令中，以非交互式方式安装依赖并设定操作系统时区
RUN apt-get update && \
    # 设置 DEBIAN_FRONTEND=noninteractive 来避免 tzdata 的交互式弹窗
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openjdk-11-jdk wget ssh rsync curl sudo tzdata && \
    # 再次确认时区设置，确保它被持久化
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # 清理 apt 缓存
    rm -rf /var/lib/apt/lists/*

# ---- 后面的内容保持不变 ----

# 设置 JAVA_HOME, PATH
# 注意：我们不再需要 JAVA_OPTS 或 JAVA_TOOL_OPTIONS 来单独设置时区
# 因为一个正确设置了时区的操作系统，其上启动的 JVM 默认会继承该时区
RUN ln -s /usr/lib/jvm/java-11-openjdk-* /usr/lib/jvm/java-11
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