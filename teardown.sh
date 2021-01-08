
echo "remove images and volume from running list"
docker rm -f `docker ps -aq`

rm -rf ../fabric/*
rm -rf ../github.com/hyperledger

docker volume prune
