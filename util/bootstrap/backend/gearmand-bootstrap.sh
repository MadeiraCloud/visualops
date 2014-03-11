#!/bin/bash

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

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


DEPLOY_ON_AWS=0
VPN_SUPPORT=""

#${DIR}/include/init-bootstrap.sh

GEARMAN_VER="gearmand-1.1.3"
GEARMAN_URL="https://launchpad.net/gearmand/1.2/1.1.3/+download/gearmand-1.1.3.tar.gz"

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

fn_yum_install libevent
fn_yum_install libevent-devel

if [ `find / -name boost | grep ^/usr/local/include | wc -l` -eq 0 ]
then
    add_source ${DIR}/include/boost-bootstrap.sh
else
    echo ">Installed boost"
fi

echo "##########################################################################################"
echo "       Installing Gearmand"
echo "##########################################################################################"

fn_download_package ${GEARMAN_VER}   ${GEARMAN_URL} 0
#mv /usr/lib64/libboost* /usr/lib
./configure --with-mysql=no --with-boost
make
make install
#mv /usr/lib/libboost* /usr/lib64
fn_check_cmd_rlt "Install  ${GEARMAN_VER}" $?


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
