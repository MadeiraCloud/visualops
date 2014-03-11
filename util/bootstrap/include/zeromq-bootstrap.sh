#!/bin/bash
DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log


DEPLOY_ON_AWS=0
VPN_SUPPORT=""


ZEROMQ_VER="zeromq-2.2.0"
ZEROMQ_URL="http://download.zeromq.org/zeromq-2.2.0.tar.gz"

if [ "${VPN_SUPPORT}" == "" ]
then
   #not set VPN_SUPPORT
  if [ ${DEPLOY_ON_AWS} -ne 1  ]
  then
    #not deploy on AWS
    VPN_SUPPORT=1
  else
    #deploy on AWS,skip vpn
    VPN_SUPPORT=0
  fi
fi

TSOCKS=""
if [ ${VPN_SUPPORT} -eq 1 ]
then
  TSOCKS=""
fi

echo "##########################################################################################"
echo "       Installing ZeroMQ"
echo "##########################################################################################"

cd ${DEPS}
${TSOCKS} fn_download_package ${ZEROMQ_VER}	${ZEROMQ_URL} 0
./configure
make
make install 

