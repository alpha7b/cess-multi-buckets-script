docker stop $(docker ps -aq --filter ancestor=cesslab/cess-bucket:testnet) && docker rm $(docker ps -aq --filter ancestor=cesslab/cess-bucket:testnet)
sleep 10s
find /mnt/db1/ -type f | parallel rm
sleep 10s
ls /mnt/db1/
