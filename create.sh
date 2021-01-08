#!/bin/bash

# 该脚本在容器外执行，创建完channel后需要将生成的jhdch.block拷贝到其他三台服务器
#export CHANNEL=jhdch
#export CCID=jhdcc

# 设置 peer 和 org
set_peer_org() {
  case $1 in
  0)
    ADDRESS="CORE_PEER_ADDRESS=${ORG_0_PEER_0}"
    LOCALMSPID="CORE_PEER_LOCALMSPID=${ORG_0_PEER_0_MSP}"
    CERTFILE="CORE_PEER_TLS_CERT_FILE=${ORG_0_PEER_0_CERT}"
    KEYFILE="CORE_PEER_TLS_KEY_FILE=${ORG_0_PEER_0_KEY}"
    ROOTCERTFILE="CORE_PEER_TLS_ROOTCERT_FILE=${ORG_0_PEER_0_CA}"
    MSPCONFIGPATH="CORE_PEER_MSPCONFIGPATH=${ORG_0_PEER_0_ADMIN}"
  ;;
  1)
    ADDRESS="CORE_PEER_ADDRESS=${ORG_1_PEER_1}"
    LOCALMSPID="CORE_PEER_LOCALMSPID=${ORG_1_PEER_1_MSP}"
    CERTFILE="CORE_PEER_TLS_CERT_FILE=${ORG_1_PEER_1_CERT}"
    KEYFILE="CORE_PEER_TLS_KEY_FILE=${ORG_1_PEER_1_KEY}"
    ROOTCERTFILE="CORE_PEER_TLS_ROOTCERT_FILE=${ORG_1_PEER_1_CA}"
    MSPCONFIGPATH="CORE_PEER_MSPCONFIGPATH=${ORG_1_PEER_1_ADMIN}"
  ;;
  esac
}

create_channel() {
  set_peer_org 0 
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer channel create -o ${ORDERER_HOST} -c ${CHANNEL} -f ./channel-artifacts/channel.tx --tls true --cafile ${ORDERER_PEM}
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} cp -r jhdch.block ./channel-artifacts
}

join_channel() {
  set_peer_org 0
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer channel join -b ${CHANNEL}.block
  set_peer_org 1
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer channel join -b ${CHANNEL}.block
}

install_ptcc{
  set_peer_org 0
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer chaincode install -n ptcc -v 1.0 -p chaincode/jhd-chaincode/ptcc
  set_peer_org 1
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer chaincode install -n ptcc -v 1.0 -p chaincode/jhd-chaincode/ptcc
}

install_pfcc{
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer chaincode install -n pfcc -v 1.0 -p chaincode/jhd-chaincode/pfcc
}

init_chaincode() {
  set_peer_org 0
  # peer chaincode instantiate -o ${ORDERER_HOST} --tls true --cafile ${ORDERER_PEM} -C ${CHANNEL} -n ${CCID} -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('${ORG_0_PEER_0_MSP}.peer')"
  # TODO(instantiate other chaincode)
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer chaincode instantiate -o ${ORDERER_HOST} -C ${CHANNEL} -n pfcc -v 1.0 -c '{"Args":[]}' -P "OR ('PFMSP.peer')" --tls true --cafile ${ORDERER_PEM}
  docker exec -e ${ADDRESS} -e ${LOCALMSPID} -e ${CERTFILE}  -e ${KEYFILE} -e ${ROOTCERTFILE} -e ${MSPCONFIGPATH} peer chaincode instantiate -o ${ORDERER_HOST} -C ${CHANNEL} -n ptcc -v 1.0 -c '{"Args":[]}' -P "OR ('PFMSP.peer','SMCTMSP.peer','MCTMSP.peer','CSTMSP.peer')" --tls true --cafile ${ORDERER_PEM}
}

scp_jhdchBlock() {
    expect -c "
    set timeout 1200;
    spawn scp /usr/local/share/fabric/channel-artifacts/jhdch.block $1:/usr/local/share/fabric/channel-artifacts;
    expect {
        *password:* {
            send @WSX4rfv\r;
        }
    }
    expect {
        *password:* {
            send @WSX4rfv\r;
        }
    }
    interact
    "
    return $?
}

IPS="172.17.76.63 172.17.76.64 172.17.76.65"
# create channle
# 只在第一台机器上执行create
case $SERVER_ID in
0)
  create_channel
  echo "create channel"

  join_channel
  echo "join channel"

  for i in ${IPS}
  do
    scp_jhdchBlock litao01@$i
    echo "### scp jhdch.block to $i"
  done
;;
*)
  # 该时间根据scp到63,64,65服务器的时间来定，需要先拷贝完之后才能执行join操作
  sleep 15

  join_channel
  echo "join channel"
;;
esac

# 所有节点安装ptcc
install_ptcc

# 只有server0 peer0 和 server3 peer1 安装pfcc
case $SERVER_ID in
0)
  set_peer_org 0
  install_pfcc
;;
3)
  set_peer_org 1 
  install_pfcc
;;
esac

# 实例化chaincode
case $SERVER_ID in
0)
  init_chaincode
;;
esac