#!/bin/bash
# my-bigdata-stack/configs/hadoop/hadoop-env.sh

# 明确告诉 Hadoop 使用从 Docker ENV 继承过来的 JAVA_HOME
export JAVA_HOME=${JAVA_HOME}