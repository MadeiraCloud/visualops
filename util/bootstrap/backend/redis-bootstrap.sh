#!/bin/bash


MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log

mkdir -p ${MADEIRA}
mkdir -p ${CONF}
mkdir -p ${DB}
mkdir -p ${DEPS}
mkdir -p ${SRC}
mkdir -p ${LOG}


DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh
add_source ${DIR}/include/init-bootstrap.sh

DEPLOY_ON_AWS=0
VPN_SUPPORT=""


REDIS_VER="redis-2.2.14"
REDIS_URL="http://redis.googlecode.com/files/redis-2.2.14.tar.gz"
REDIS_PY_URL="git://github.com/andymccurdy/redis-py.git"

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
echo "       Installing Redis"
echo "##########################################################################################"


#Redis
fn_download_package ${REDIS_VER}   ${REDIS_URL} 0
make; make install; make test
fn_check_cmd_rlt "Install  ${REDIS_VER}" $?

sed -i -e "/^export LD_LIBRARY_PATH=/d"  ~/.bashrc
sed -i -e "/^export PYTHONPATH=/d"  ~/.bashrc
sed -i -e "/^export INSTANT_HOME=/d"  ~/.bashrc
echo >>  ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/" >>  ~/.bashrc
echo "export PYTHONPATH=${SRC}/api/Source/" >> ~/.bashrc
echo "export INSTANT_HOME=${MADEIRA}" >> ~/.bashrc
source ~/.bashrc

mkdir -p ${MADEIRA}/db/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then 
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
else 
    echo ">user 'InstantForge' already exists"
fi
chown InstantForge -R ${MADEIRA}
