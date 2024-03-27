#!/bin/bash

## 删除cess服务
cess stop
cess down

## 删除docker镜像
docker rmi cesslab/cess-bucket:testnet || true
docker rmi cesslab/config-gen:testnet || true
docker rmi cesslab/cess-chain:testnet || true
docker rmi containrrr/watchtower || true

## 删除cess文件
rm -rf /cess || true
rm -rf /mnt/db* || true
rm -rf /mnt/disk* || true
rm -rf /opt/cess || true

