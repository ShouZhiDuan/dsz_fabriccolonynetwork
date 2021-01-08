#!/bin/bash

################################################
# 在 ~/.bash_profile 中设置
# export SERVER_ID=0 (按照机器排序加1)
################################################
export IP_0="192.168.10.21"
export IP_1="192.168.10.22"
export IP_2="192.168.10.23"
export IP_3="192.168.10.24"
export IP_4="192.168.10.25"

IDS=(0 1 2 3 4)

# 设置当前docker network
export NETWORKMODE="nvxclouds.com"
export SYS_CHANNEL="nvxclouds-blockchain"

export CHANNEL="nvxchannel"
export CCID="tobcc"

# 设置镜像的版本
export IMAGE_TAG="1.4.6"

# 设置 zk hostname
export ZK_0_HOST="zk${IDS[0]}"
export ZK_1_HOST="zk${IDS[1]}"
export ZK_2_HOST="zk${IDS[2]}"
export ZK_3_HOST="zk${IDS[3]}"
export ZK_4_HOST="zk${IDS[4]}"

# zookeeper servers
export ZOO_SERVERS="server.${IDS[0]}=${ZK_0_HOST}:2888:3888 server.${IDS[1]}=${ZK_1_HOST}:2888:3888 server.${IDS[2]}=${ZK_2_HOST}:2888:3888 server.${IDS[3]}=${ZK_3_HOST}:2888:3888 server.${IDS[4]}=${ZK_4_HOST}:2888:3888"

# zookeeper host
export ZOO_HOST="zk${SERVER_ID}"

export KAFKA_0_HOST="kafka${IDS[0]}"
export KAFKA_1_HOST="kafka${IDS[1]}"
export KAFKA_2_HOST="kafka${IDS[2]}"
export KAFKA_3_HOST="kafka${IDS[3]}"
export KAFKA_4_HOST="kafka${IDS[4]}"

export KAFKA_HOST="kafka${SERVER_ID}"

# for orderers
export ORDERER_0_HOST="orderer${IDS[0]}.${NETWORKMODE}"
export ORDERER_1_HOST="orderer${IDS[1]}.${NETWORKMODE}"
export ORDERER_2_HOST="orderer${IDS[2]}.${NETWORKMODE}"
export ORDERER_3_HOST="orderer${IDS[3]}.${NETWORKMODE}"
export ORDERER_4_HOST="orderer${IDS[4]}.${NETWORKMODE}"
 
export GENESIS_BLOCK="../channel-artifacts/genesis.block"
export ORDERER_HOST="orderer${SERVER_ID}"

export ORDERER_MSP="../crypto-config/ordererOrganizations/${NETWORKMODE}/orderers/${ORDERER_HOST}.${NETWORKMODE}/msp"
export ORDERER_TLS="../crypto-config/ordererOrganizations/${NETWORKMODE}/orderers/${ORDERER_HOST}.${NETWORKMODE}/tls"
# for cli
# export ORDERER_PEM="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${NETWORKMODE}/orderers/orderer0.${NETWORKMODE}/msp/tlscacerts/tlsca.${NETWORKMODE}-cert.pem"

export AU_MSP=AppUserMSP
export DP_MSP=DataProviderMSP
export DU_MSP=DataUserMSP
export RL_MSP=RegulatorMSP
export AP_MSP=AppProviderMSP

export AU_HOST="appuser.nvxclouds.com"
export DP_HOST="dataprovider.nvxclouds.com"
export DU_HOST="datauser.nvxclouds.com"
export RL_HOST="regulator.nvxclouds.com"
export AP_HOST="appprovider.nvxclouds.com"

# for peers
echo "setting env for : $SERVER_ID"

case $SERVER_ID in
0)
  # export ORDERER_HOST=${ORDERER_0_HOST}
  export KAFKA_ADVERTISED=${IP_0}
  export ORG_0_HOST=${AU_HOST}
  export ORG_1_HOST=${DP_HOST}

  export ORG_0_MSP=${AU_MSP}
  export ORG_1_MSP=${DP_MSP}

  export ORG_0_PEER_0="peer0.${ORG_0_HOST}"
  export ORG_0_PEER_0_HOST="${ORG_0_PEER_0}:${IP_0}"
  export ORG_0_PEER_1="peer1.${ORG_0_HOST}"
  export ORG_0_PEER_1_HOST="${ORG_0_PEER_1}:${IP_4}"

  export ORG_1_PEER_0="peer0.${ORG_1_HOST}"
  export ORG_1_PEER_0_HOST="${ORG_1_PEER_0}:${IP_1}"
  export ORG_1_PEER_1="peer1.${ORG_1_HOST}"
  export ORG_1_PEER_1_HOST="${ORG_1_PEER_1}:${IP_0}"

;;
1)
  # export ORDERER_HOST=${ORDERER_1_HOST}
  export KAFKA_ADVERTISED=${IP_1}
  export ORG_0_HOST=${DP_HOST}
  export ORG_1_HOST=${DU_HOST}

  export ORG_0_MSP=${DP_MSP}
  export ORG_1_MSP=${DU_MSP}

  #
  export ORG_0_PEER_0="peer0.${ORG_0_HOST}"
  export ORG_0_PEER_0_HOST="${ORG_0_PEER_0}:${IP_1}"
  export ORG_0_PEER_1="peer1.${ORG_0_HOST}"
  export ORG_0_PEER_1_HOST="${ORG_0_PEER_1}:${IP_0}"

  export ORG_1_PEER_0="peer0.${ORG_1_HOST}"
  export ORG_1_PEER_0_HOST="${ORG_1_PEER_0}:${IP_2}"
  export ORG_1_PEER_1="peer1.${ORG_1_HOST}"
  export ORG_1_PEER_1_HOST="${ORG_1_PEER_1}:${IP_1}"

;;
2)
  # export ORDERER_HOST=${ORDERER_2_HOST}
  export KAFKA_ADVERTISED=${IP_2}
  export ORG_0_HOST=${DU_HOST}
  export ORG_1_HOST=${RL_HOST}

  export ORG_0_MSP=${DU_MSP}
  export ORG_1_MSP=${RL_MSP}

  export ORG_0_PEER_0="peer0.${ORG_0_HOST}"
  export ORG_0_PEER_0_HOST="${ORG_0_PEER_0}:${IP_2}"
  export ORG_0_PEER_1="peer1.${ORG_0_HOST}"
  export ORG_0_PEER_1_HOST="${ORG_0_PEER_1}:${IP_1}"

  export ORG_1_PEER_0="peer0.${ORG_1_HOST}"
  export ORG_1_PEER_0_HOST="${ORG_1_PEER_0}:${IP_3}"
  export ORG_1_PEER_1="peer1.${ORG_1_HOST}"
  export ORG_1_PEER_1_HOST="${ORG_1_PEER_1}:${IP_2}"

;;
3)
  # export ORDERER_HOST=${ORDERER_3_HOST}
  export KAFKA_ADVERTISED=${IP_3}
  export ORG_0_HOST=${RL_HOST}
  export ORG_1_HOST=${AP_HOST}

  export ORG_0_MSP=${RL_MSP}
  export ORG_1_MSP=${AP_MSP}

  export ORG_0_PEER_0="peer0.${ORG_0_HOST}"
  export ORG_0_PEER_0_HOST="${ORG_0_PEER_0}:${IP_3}"
  export ORG_0_PEER_1="peer1.${ORG_0_HOST}"
  export ORG_0_PEER_1_HOST="${ORG_0_PEER_1}:${IP_2}"

  export ORG_1_PEER_0="peer0.${ORG_1_HOST}"
  export ORG_1_PEER_0_HOST="${ORG_1_PEER_0}:${IP_4}"
  export ORG_1_PEER_1="peer1.${ORG_1_HOST}"
  export ORG_1_PEER_1_HOST="${ORG_1_PEER_1}:${IP_3}"

;;
4)
  # export ORDERER_HOST=${ORDERER_4_HOST}
  export KAFKA_ADVERTISED=${IP_4}
  export ORG_0_HOST=${AP_HOST}
  export ORG_1_HOST=${AU_HOST}

  export ORG_0_MSP=${AP_MSP}
  export ORG_1_MSP=${AU_MSP}

  export ORG_0_PEER_0="peer0.${ORG_0_HOST}"
  export ORG_0_PEER_0_HOST="${ORG_0_PEER_0}:${IP_4}"
  export ORG_0_PEER_1="peer1.${ORG_0_HOST}"
  export ORG_0_PEER_1_HOST="${ORG_0_PEER_1}:${IP_3}"

  export ORG_1_PEER_0="peer0.${ORG_1_HOST}"
  export ORG_1_PEER_0_HOST="${ORG_1_PEER_0}:${IP_0}"
  export ORG_1_PEER_1="peer1.${ORG_1_HOST}"
  export ORG_1_PEER_1_HOST="${ORG_1_PEER_1}:${IP_4}"

;;
esac

#如果${ORG_0_HOST}值为空，需要手动设置$SERVER_ID的值为0,1,2,3,4
export CA_KEY=$(cd crypto-config/peerOrganizations/${ORG_0_HOST}/ca && ls *_sk)

