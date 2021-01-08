#!/bin/bash

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

# 检查peer节点是否加入channel
check_channel() {
  echo "==> check peer join on channel : $1"
  peer channel list
}

# 检查已安装的chaincode
check_installed_chaincode() {
  echo "==> check peer chainocde installed  : $1"
  peer chaincode list --installed
}

# 检查已实例化的chaincode
check_instantited_chaincode() {
  echo "==> check peer chainocde instantiated  : $1"
  peer chaincode list --instantiated -C ${CHANNEL}
}

# 第一次调用链码query
first_query() {
  echo "==> first query  : $1"
  peer chaincode query -n tobcc -c '{"Args":["dataProviderQuery","{\"Operation\":\"dataNodeRegistration\",\"DataNodeID\":\"dataNode1\"}"]}' -C ${CHANNEL}
  peer chaincode query -n toccc -c '{"Args":["appUserQuery","{\"Operation\":\"authorizationDataUpBlockChain\"}"]}' -C ${CHANNEL}
}

# 第一次调用链码invoke
first_invoke() {
  echo "==> first invoke  : $1"
  peer chaincode invoke -n tobcc -c '{"Args":["dataProviderInvoke","{\"Operation\":\"dataNodeRegistration\",\"DataNodeID\":\"dataNode1\",\"NodeName\":\"111\",\"TxTime\":\"20200521115623\",\"MessageHash\":\"node111\"}"]}' -C ${CHANNEL} --tls --cafile ${ORDERER_PEM}  
  peer chaincode invoke -n toccc -c '{"Args":["appUserInvoke","{\"Operation\":\"authorizationDataUpBlockChain\",\"AppUserID\":\"appUser1\",\"Balance\":\"1\",\"TxTime\":\"20200521115623\",\"MessageHash\":\"node111\"}"]}' -C ${CHANNEL} --tls --cafile ${ORDERER_PEM} 
  peer chaincode invoke -n toccc -c '{"Args":["appUserInvoke","{\"Operation\":\"authorizationDataUpBlockChain\",\"AppUserID\":\"appUser2\",\"Balance\":\"2\",\"TxTime\":\"20200521115623\",\"MessageHash\":\"node111\"}"]}' -C ${CHANNEL} --tls --cafile ${ORDERER_PEM}  
}

sleep_second() {
  echo $2
  sleep $1
}

case $SERVER_ID in
2)
  set_peer_org 0
  check_channel ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_channel ${ORG_1_PEER_1}
  
  set_peer_org 0
  check_installed_chaincode ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_installed_chaincode ${ORG_1_PEER_1}
  
  set_peer_org 0
  check_instantited_chaincode ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_instantited_chaincode ${ORG_1_PEER_1}

  set_peer_org 0
  first_invoke ${ORG_0_PEER_0}
  sleep_second 10s "==> sleep waiting for transaction write block"
  first_query ${ORG_0_PEER_0}

  set_peer_org 1
  first_query ${ORG_1_PEER_1}  
  
  ;;
0 | 1 | 3 | 4)
  set_peer_org 0
  check_channel ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_channel ${ORG_1_PEER_1}
  
  set_peer_org 0
  check_installed_chaincode ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_installed_chaincode ${ORG_1_PEER_1}
  
  set_peer_org 0
  check_instantited_chaincode ${ORG_0_PEER_0}
  
  set_peer_org 1
  check_instantited_chaincode ${ORG_1_PEER_1}
  
  sleep_second 10s "==> sleep waiting for transaction write block"

  set_peer_org 0
  first_query ${ORG_0_PEER_0}

  set_peer_org 1
  first_query ${ORG_1_PEER_1}
  ;;
esac