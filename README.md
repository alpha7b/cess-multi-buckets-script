# 使用脚本部署cess多节点

## 配置文件
按config_sample.json里的格式填写，文件名重命名为config.json

## 运行

1. 安装docker和cess客户端
```
source install_docker_cess.sh
```

2. 启动rpc节点
```
cess start
```

3. 创建文件夹及config.yaml
```
source create_config_yaml.sh
```

4. 创建docker-compose文件

watchtower容器在cess start时已经自动创建过了，需要先删掉，不然docker compose行再次创建会有冲突报错。
```
docker stop watchtower
docker rm watchtower
source create_docker_compose_yaml.sh
```

5. rpc节点同步完成后，启动docker节点

```
docker compose up -d
```

# 查看
````
# 查看container log
docker ps
docker logs <container_name> -f -n 20

# 查看bucket数据
docker exec <STORAGE_CONTAINER_NAME> cess-bucket --config /opt/bucket/config.yaml stat

# 查看bucket收益
docker exec <STORAGE_CONTAINER_NAME> cess-bucket --config /opt/bucket/config.yaml reward
```



