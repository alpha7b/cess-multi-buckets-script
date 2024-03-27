#!/bin/bash

# 安装docker
sudo apt-get update
sudo apt-get install ca-certificates curl tree
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 删除旧的cess文件及服务
cess stop
cess down

# 删除docker镜像
docker rmi cesslab/cess-bucket:testnet || true
docker rmi cesslab/config-gen:testnet || true
docker rmi cesslab/cess-chain:testnet || true
docker rmi containrrr/watchtower || true

# 删除cess文件
rm -rf /cess || true
rm -rf /mnt/db* || true
rm -rf /mnt/disk* || true
rm -rf /opt/cess || true

# 安装cess客户端
cd / && mkdir cess && cd /cess
wget https://github.com/CESSProject/cess-nodeadm/archive/v0.5.5.tar.gz
tar -xvf v0.5.5.tar.gz
cd cess-nodeadm-0.5.5/
./install.sh

# 启动配置及cess chain
echo -e "rpcnode\n\n\n" | sudo cess config set
sudo cess start
