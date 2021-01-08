#!/bin/bash


####################################
##  Server0 Server1 Server2 Server3 Server4
##  p0.au   p0.dp   p0.du    p0.rl    p0.ap
##  p1.dp   p1.du   p1.rl    p1.ap    p1.au
##  ca.qu   ca.dp   ca.du    ca.rl    ca.ap
##  kafka0  kafka1  kafka2   kafka3   kafka4
##  zk0     zk1     zk2      zk3      zk4
##  order0  order1  order2   orderer3 orderer4
####################################
##  nvxchannel
##  join    join    join    join      join
##  tobcc   tobcc   tobcc   tobcc     tobcc
##  toccc   toccc   toccc   toccc     toccc
####################################

# 设置 cryptogen 所在 bin path
BIN_PATH="./bin"

# 设置配置文件所在目录
CONFIG_PATH="./config"

# 设置系统channel
SYS_CHANNEL="nvxclouds-blockchain"

# 设置代码channel
CHANNEL=nvxchannel

# 设置MSP名称
ORGMSP_0=AppUserMSP
ORGMSP_1=DataProviderMSP
ORGMSP_2=DataUserMSP
ORGMSP_3=RegulatorMSP
ORGMSP_4=AppProviderMSP

CHANNEL_APTH="channel-artifacts"

BIN_CONFIGTXGEN="${BIN_PATH}/configtxgen -configPath ${CONFIG_PATH}"

echo $PWD

if [ ! -d "./${CHANNEL_APTH}" ];then
  mkdir ./${CHANNEL_APTH}
else
  rm -rf ./${CHANNEL_APTH}
fi

if [ -d "./crypto-config" ];then
  rm -rf ./crypto-config
fi

# -configPath

# 创建组织
${BIN_PATH}/cryptogen generate --config=${CONFIG_PATH}/crypto-config.yaml

# 创建创世区块
# mkdir channel-artifacts
${BIN_CONFIGTXGEN} -profile NvxcloudsOrdererGenesis -channelID ${SYS_CHANNEL} -outputBlock ./channel-artifacts/genesis.block

# 创建 channel
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID ${CHANNEL}

# 创建ORGMSP_0 channel锚节点
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORGMSP_0}anchors.tx -channelID ${CHANNEL} -asOrg ${ORGMSP_0}

# 创建ORGMSP_1 channel锚节点
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORGMSP_1}anchors.tx -channelID ${CHANNEL} -asOrg ${ORGMSP_1}

# 创建ORGMSP_2 channel锚节点
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORGMSP_2}anchors.tx -channelID ${CHANNEL} -asOrg ${ORGMSP_2}

# 创建ORGMSP_3 channel锚节点
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORGMSP_3}anchors.tx -channelID ${CHANNEL} -asOrg ${ORGMSP_3}

# 创建ORGMSP_3 channel锚节点
${BIN_CONFIGTXGEN} -profile NvxcloudsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORGMSP_4}anchors.tx -channelID ${CHANNEL} -asOrg ${ORGMSP_4}


#if [ 1 -eq $SERVER_ID ]; then
#  echo "###### start zookeeper on ${SERVER_ID} ######"
#  docker-compose -f zk-docker.yaml
#  sleep 10s
#  echo "###### start kafka on ${SERVER_ID} ######"
#  docker-compose -f kafka-docker.yaml
#  sleep 10s
#  echo "###### start orderer on ${SERVER_ID} ######"
#  docker-compose -f orderer-docker.yaml
#  echo "###### start peer on ${SERVER_ID} ######"
#  docker-compose -f peer-docker.yaml
#  echo "###### start ca-server on ${SERVER_ID} ######"
#  docker-compose -f ca-docker.yaml
#fi
