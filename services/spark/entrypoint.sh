#!/bin/bash
# my-bigdata-stack/services/spark/entrypoint.sh
set -e

echo "Executing command: $@"
# 执行 docker-compose.yml 中定义的 command
exec "$@"