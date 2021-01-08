. ./build_env.sh

docker network create nvxclouds.com

start_zk() {
  echo "###### start zookeeper on ${SERVER_ID} ######"
  docker-compose -f zk-docker.yaml up -d
}

start_kafka() {
  echo "###### start kafka on ${SERVER_ID} ######"
  docker-compose -f kafka-docker.yaml up -d
}

start_ca() {
  echo "###### start ca-server on ${SERVER_ID} ######"
  docker-compose -f ca-docker.yaml up -d
}

start_orderer() {
  echo "###### start orderer on ${SERVER_ID} ######"
  docker-compose -f orderer-docker.yaml up -d
}

start_peer() {
  echo "###### start peer on ${SERVER_ID} ######"
  docker-compose -f peer-docker.yaml up -d
}

start_cli() {
  echo "###### start client on ${SERVER_ID} ######"
  docker-compose -f cli-docker.yaml up -d
}

case $SERVER_ID in
0 | 1 | 2 | 3 | 4)

  start_zk

  sleep 6s

  start_kafka

  sleep 10s

  start_ca

  start_orderer

  start_peer

  start_cli

  docker ps -a
  ;;
esac
