#!/bin/bash
# http://cw.hubwiz.com/card/c/fabric-command-manual/1/1/1/
#peer chaincode install -n tobcc -v 1.1 -p github.com/hyperledger/fabric/examples/chaincode/go/mycc2.0
#peer chaincode upgrade -o ${ORDERER_HOST} -C ${CHANNEL} -n tobcc  -v 1.1 -c '{"Args":[]}' -P 'OR(“DataUserMSP.peer”，“DataProviderMSP.peer”，“RegulatorMSP.peer”，“AppProviderMSP.peer”)' --tls --cafile ${ORDERER_PEM}
#peer chaincode upgrade -o ${ORDERER_HOST} -C ${CHANNEL} -n toccc  -v 1.1 -c '{"Args":[]}' -P 'OR(“AppUserMSP.peer”，“DataUserMSP.peer”)' --tls --cafile ${ORDERER_PEM}
# peer chaincode package ccpack.out -n tobcc -p chaincode/nvxclouds_chaincode/tobcc -v 1.1 -s -S
# peer chaincode install -n tobcc -v 1.0 -p chaincode/nvxclouds_chaincode/tobcc

export CHANNEL=nvxchannel

#peer chaincode list --installed
#peer chaincode list --instantiated -C ${CHANNEL}

# 设置 peer 和 org
set_peer_org() {
  case $1 in
  0)
  export CHANNEL="nvxchannel"
  export CORE_PEER_ADDRESS=${ORG_0_PEER_0}
  export CORE_PEER_LOCALMSPID=${ORG_0_PEER_0_MSP}
  export CORE_PEER_TLS_CERT_FILE=${ORG_0_PEER_0_CERT}
  export CORE_PEER_TLS_KEY_FILE=${ORG_0_PEER_0_KEY}
  export CORE_PEER_TLS_ROOTCERT_FILE=${ORG_0_PEER_0_CA}
  export CORE_PEER_MSPCONFIGPATH=${ORG_0_PEER_0_ADMIN}
  export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="nvxclouds.com"
  export ORDERER_HOST="orderer${SERVER_ID}.nvxclouds.com:7050"
;;
1)
  export CHANNEL="nvxchannel"
  export CORE_PEER_ADDRESS=${ORG_1_PEER_1}
  export CORE_PEER_LOCALMSPID=${ORG_1_PEER_1_MSP}
  export CORE_PEER_TLS_CERT_FILE=${ORG_1_PEER_1_CERT}
  export CORE_PEER_TLS_KEY_FILE=${ORG_1_PEER_1_KEY}
  export CORE_PEER_TLS_ROOTCERT_FILE=${ORG_1_PEER_1_CA}
  export CORE_PEER_MSPCONFIGPATH=${ORG_1_PEER_1_ADMIN}
  export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="nvxclouds.com"
  export ORDERER_HOST="orderer${SERVER_ID}.nvxclouds.com:7050"
;;
  esac
}

# 加入 channel
join_channel() {
  echo "==> join channel on Server $SERVER_ID"
  set_peer_org 0
  peer channel join -b ${CHANNEL}.block
  set_peer_org 1
  peer channel join -b ${CHANNEL}.block
}

# 获取channel block文件
fetch_channel() {
  echo "==> fetch channel block on Server $SERVER_ID"
  peer channel fetch oldest ${CHANNEL}.block -o ${ORDERER_HOST} -c ${CHANNEL} --tls --cafile ${ORDERER_PEM}
}

# 更新锚节点
update_channel() {
  echo "==> update peer anchors on $1"
  set_peer_org 0
  peer channel update -o ${ORDERER_HOST} -c ${CHANNEL} -f ../channel-artifacts/$1anchors.tx --tls true --cafile ${ORDERER_PEM}
}

# 安装 tobcc 链码
install_tobcc() {
  echo "==> install tobcc chaincode on Server $SERVER_ID"
  peer chaincode install -n tobcc -v 1.0 -p chaincode/nvxclouds_chaincode/tobcc
}

# 安装 toccc 链码
install_toccc() {
  echo "==> install toccc chaincode on Server $SERVER_ID"
  peer chaincode install -n toccc -v 1.0 -p chaincode/nvxclouds_chaincode/toccc
}

sleep_second() {
  echo $2
  sleep $1
}

case $SERVER_ID in
2)
  echo "==> create channel on Server $SERVER_ID"
  set_peer_org 0
  # 只在 server0 创建channel
  peer channel create -o ${ORDERER_HOST} -c ${CHANNEL} -f ../channel-artifacts/channel.tx --tls true --cafile ${ORDERER_PEM} -t 60s

  join_channel

  # update_channel

  sleep_second 15s "==> sleep waiting for other server join channel or update peer anchors"

  # peer0.platform 安装 两套链码
  set_peer_org 0
  install_tobcc
  install_toccc

  set_peer_org 1
  install_tobcc
  install_toccc


  sleep_second 10s "==> sleep waiting for other peers installed chaincode"
  set_peer_org 0
  echo "==> instantiate tobcc"
  peer chaincode instantiate -o ${ORDERER_HOST} -C ${CHANNEL} -n tobcc  -v 1.0 -c '{"Args":[]}' -P 'OR("DataUserMSP.peer","DataProviderMSP.peer","RegulatorMSP.peer","AppProviderMSP.peer")' --tls --cafile ${ORDERER_PEM}
  echo "==> instantiate toccc"
  peer chaincode instantiate -o ${ORDERER_HOST} -C ${CHANNEL} -n toccc  -v 1.0 -c '{"Args":[]}' -P 'OR("AppUserMSP.peer","DataUserMSP.peer")' --tls --cafile ${ORDERER_PEM}
  
  update_channel DataUserMSP
  update_channel AppUserMSP
  update_channel DataProviderMSP
  update_channel AppProviderMSP
  update_channel RegulatorMSP
  
  echo "All success!"
  peer chaincode list --installed 
  peer chaincode list --instantiated -C ${CHANNEL}
  ;;
0 | 1 | 3 | 4)
  sleep_second 10s "==> sleep 15s for waiting create channel"

  fetch_channel

  join_channel

  sleep_second 15s "==> sleep waiting for other server join channel or update peer anchors"

  set_peer_org 0
  install_toccc
  install_tobcc

  set_peer_org 1
  install_toccc
  install_tobcc

  ;;
esac
