# my-bigdata-stack/services/base/Dockerfile

# 使用官方 ubuntu:22.04 镜像
FROM ubuntu:22.04

# 1. 设置环境变量，方便后续引用
ENV TZ=Asia/Shanghai

# 2. 【优化点】将换源、安装依赖和清理缓存合并到同一个 RUN 指令中
#    这可以减少镜像层数，并确保缓存逻辑正确
RUN \
    # 【关键修改】使用更全面的 sed 命令，将所有可能的官方源（包括 ports.ubuntu.com）一次性替换
    sed -i 's/archive.ubuntu.com\|security.ubuntu.com\|ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    \
    # 更新软件源列表并安装必要的软件包
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        wget \
        ssh \
        rsync \
        net-tools \
        curl \
        sudo \
        tzdata && \
    \
    # 设置并持久化时区
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    \
    # 清理 apt 缓存，减小镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 后面的内容保持不变 ----

# 设置 JAVA_HOME, PATH
RUN ln -s /usr/lib/jvm/java-17-openjdk-* /usr/lib/jvm/java-17
ENV JAVA_HOME=/usr/lib/jvm/java-17
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