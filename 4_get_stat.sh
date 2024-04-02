#!/bin/bash

# 初始化总验证空间变量
total_validated_space_gib=0

# 遍历所有以bucket_开头的容器
for container in $(docker ps --format '{{.Names}}' | grep '^bucket_'); do
    echo "Checking validated space for $container..."
    
    # 使用docker exec获取容器的validated space，并尝试捕捉可能的错误
    output=$(docker exec $container cess-bucket --config /opt/bucket/config.yaml stat 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Failed to execute command on $container: $output"
        continue
    fi
    
    validated_space_gib=$(echo "$output" | grep 'validated space' | sed -n 's/.*validated space.*\([0-9]*\.[0-9]*\).*GiB.*/\1/p')
    if [ -z "$validated_space_gib" ]; then
        echo "Failed to extract validated space for $container"
        continue
    fi
    
    echo "Validated space for $container: $validated_space_gib GiB"
    
    # 累加到总验证空间
    total_validated_space_gib=$(echo "$total_validated_space_gib + $validated_space_gib" | bc)
done

# 将GiB转换为TiB（1TiB = 1024GiB）
total_validated_space_tib=$(echo "scale=2; $total_validated_space_gib / 1024" | bc)

echo "Total validated space across all containers is: $total_validated_space_tib TiB"
