#!/bin/bash

# 定义输出文件名
output="docker-compose.yaml"

# 开始写入docker-compose文件的基本信息
cat > $output <<EOF
version: '3'
name: cess-storage
services:
EOF

# 读取每个db和其下的disk
jq -r '.dbs | to_entries[] | .key as $db | .value[] | "\($db)/\(.)"' config.json | while read path; do
    disk=$(basename $path)
    bucket_number=$(echo $disk | grep -o -E '[0-9]+')
    container_name="bucket_$bucket_number"
    db_folder=$(dirname $path | tr -d './')

    # 写入每个bucket的配置到docker-compose.yaml
    cat >> $output <<EOF
  $container_name:
    image: 'cesslab/cess-bucket:testnet'
    network_mode: host
    restart: always
    volumes:
      - '/mnt/$path/bucket:/opt/bucket'
      - '/mnt/$path/storage/:/opt/bucket-disk'
    command:
      - run
      - '-c'
      - /opt/bucket/config.yaml
    logging:
      driver: json-file
      options:
        max-size: 500m
    container_name: $container_name

EOF
done

# # 添加watchtower服务至docker-compose.yaml
# cat >> $output <<EOF
#   watchtower:
#     image: containrrr/watchtower
#     container_name: watchtower
#     network_mode: host
#     restart: always
#     volumes:
#       - '/var/run/docker.sock:/var/run/docker.sock'
#     command:
#       - '--cleanup'
#       - '--interval'
#       - '300'
#       - '--enable-lifecycle-hooks'
#       - chain
#       - bucket
#     logging:
#       driver: json-file
#       options:
#         max-size: 100m
#         max-file: '7'
# EOF

echo "docker-compose.yaml has been generated."

# # 删除watchtower容器，避免compose出错
# docker stop watchtower
# docker rm watchtower

# 启动compose
docker compose up -d
