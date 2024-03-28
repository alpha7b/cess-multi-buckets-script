# 使用脚本部署cess多节点

## 下载脚本到节点服务器
```
git clone https://github.com/alpha7b/cess-multi-buckets-script.git
```

## 准备
1. 准备好钱包及测试币
2. 将config_sample.json重命名为config.json，里面信息按需要填写

## 运行

1. 安装docker和cess客户端
```
source 1_docker_cess.sh
```

2. 创建文件夹及config.yaml
```
source 1_config_yaml.sh
```

3. 创建docker-compose

```
source 3_docker_compose.sh
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



