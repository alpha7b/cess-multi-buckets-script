#!/bin/bash

# Initialize total validated space variable
total_validated_space_gib=0

# Initialize an array to hold the container names
declare -a containers

# Fill the array with container names starting with "bucket_" and sort them
readarray -t containers < <(docker ps --format '{{.Names}}' | grep '^bucket_' | sort)

# Loop through all sorted containers
for container in "${containers[@]}"; do
    # echo "Checking validated space for $container..."
    
    # Attempt to execute the command and capture its output, focusing on error catching
    output=$(docker exec $container cess-bucket --config /opt/bucket/config.yaml stat 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Failed to execute command on $container: $output"
        continue
    fi
    
    # Attempt to extract the validated space value using a more focused approach
    validated_space_gib=$(echo "$output" | grep 'validated space' | sed -n 's/.*validated space \| GiB.*//p' | tr -d -c '0-9.')

    if ! [[ $validated_space_gib =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Failed to extract validated space for $container: $validated_space_gib"
        continue
    fi
    
    echo "Validated space for $container: $validated_space_gib GiB"
    
    # Sum up to total validated space
    total_validated_space_gib=$(echo "$total_validated_space_gib + $validated_space_gib" | bc)
done

# Convert GiB to TiB (1TiB = 1024GiB)
total_validated_space_tib=$(echo "scale=2; $total_validated_space_gib / 1024" | bc)

echo "Total validated space across all containers is: $total_validated_space_tib TiB"
