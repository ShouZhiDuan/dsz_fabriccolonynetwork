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

echo "Choose peer:"   
echo "0) ${ORG_0_PEER_0}"
echo "1) ${ORG_1_PEER_1}"
read Keypress  
case  "$Keypress"  in   
  0) 
    set_peer_org 0
    ;;  
  1) 
    set_peer_org 1
    ;;   
  *) 
    set_peer_org 0
    ;;  
esac
echo $CORE_PEER_ADDRESS
