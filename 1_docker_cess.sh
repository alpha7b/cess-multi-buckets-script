#!/bin/bash

# 从config.json读取并创建文件夹结构
jq -r '.dbs | to_entries[] | .key as $db | .value[] | "\($db)/\(.)"' config.json | while read line; do
    # 使用绝对路径创建文件夹
    mkdir -p "/mnt/${line}/bucket" "/mnt/${line}/storage"
    if [ ! -d "/mnt/${line}/bucket" ]; then
        echo "创建目录失败：/mnt/${line}/bucket"
        exit 1
    fi
    if [ ! -d "/mnt/${line}/storage" ]; then
        echo "创建目录失败：/mnt/${line}/storage"
        exit 1
    fi
done

# 定义配置文件内容函数
create_config_yaml() {
  local full_disk_path="/mnt/$1" # 使用绝对路径
  local disk_name=$(basename $full_disk_path) # 从完整路径中提取disk名称
  local mnemonic=$(jq -r ".mnemonics.${disk_name}" config.json) # 使用提取的disk名称从config.json中读取助记词
  local settings=$(jq -r ".settings" config.json) # 从config.json读取设置
  local earnings_acc=$(echo $settings | jq -r ".EarningsAcc")
  local use_space=$(echo $settings | jq -r ".UseSpace")
  local use_cpu=$(echo $settings | jq -r ".UseCpu")
  local port_number=$((4000 + ${disk_name##*disk})) # 使用 disk 编号来动态设置端口号，注意这里改为使用 ${disk_name##*disk} 来提取编号
  echo $port_number
  
  cat > "${full_disk_path}/bucket/config.yaml" << EOF
# The rpc endpoint of the chain node
Rpc:
  - "ws://127.0.0.1:9944/"
  - "wss://testnet-rpc0.cess.cloud/ws/"
  - "wss://testnet-rpc1.cess.cloud/ws/"
  - "wss://testnet-rpc2.cess.cloud/ws/"
# Bootstrap Nodes
Boot:
  - "_dnsaddr.boot-bucket-testnet.cess.cloud"
# Signature account mnemonic
Mnemonic: "${mnemonic}"
# Staking account
StakingAcc: ""
# Earnings account
EarningsAcc: "${earnings_acc}"
# Service workspace
Workspace: "/opt/bucket-disk"
# P2P communication port
Port: ${port_number}
# Maximum space used, the unit is GiB
UseSpace: ${use_space}
# Number of cpu's used
UseCpu: ${use_cpu}
# Priority tee list address
TeeList:
  - "127.0.0.1:8080"
  - "127.0.0.1:8081"
EOF
}

# 循环创建config.yaml文件
jq -r '.dbs | to_entries[] | .key as $db | .value[] | "\($db)/\(.)"' config.json | while read line; do
    create_config_yaml $line
done

echo "文件夹、文件创建完毕，config.yaml已填充。"

tree /mnt
