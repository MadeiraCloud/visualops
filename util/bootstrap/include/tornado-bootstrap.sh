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


TORNADO_VER="tornado-2.1.1"
TORNADO_URL="https://github.com/downloads/facebook/tornado/tornado-2.1.1.tar.gz"

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
echo "       Installing Tornado"
echo "##########################################################################################"



# Tornado
fn_download_package ${TORNADO_VER}   ${TORNADO_URL} 0
python setup.py build
python setup.py install
fn_check_cmd_rlt "Install  ${TORNADO_VER}" $?

# TornadoRPC
cd ${SRC}/api/Util/tornadorpc
python setup.py build
python setup.py install
fn_check_cmd_rlt "Install  tornadorpc" $?

