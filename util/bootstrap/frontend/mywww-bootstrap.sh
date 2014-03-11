#!/bin/bash

DIR=/madeira/util/bootstrap


GIT="root@211.98.26.6"
MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site


DEPLOY_ON_AWS=0
VPN_SUPPORT=""



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

source ${DIR}/include/common-bootstrap.sh
add_source ${DIR}/include/init-bootstrap.sh

pecl install mongo
pear channel-discover pear.zero.mq
echo "##########################################################################################"
echo "       Install libzmq"
echo "##########################################################################################"

mkdir -p ${DEPS}
cd ${DEPS}
${TSOCKS} git clone https://github.com/zeromq/libzmq.git
cd libzmq
./autogen.sh
./configure
make
make install
echo "extension=zmq.so" >> /etc/php.ini

pecl install pear.zero.mq/zmq-beta
pecl install channel://pecl.php.net/msgpack-0.5.3
echo "extension=msgpack.so" >> /etc/php.ini


${DIR}/include/aws-php-sdk-bootstrap.sh
${DIR}/include/php-redis-driver-bootstrap.sh
${DIR}/include/ide-bootstrap.sh
${DIR}/include/zeromq-bootstrap.sh


${TSOCKS} git clone ssh://${GIT}//opt/source/web.git ${MADEIRA}/source/web
##cp ${SRC}/Vulcan/Util/script/* ${SITE}/download/setup/

mkdir -p ${MADEIRA}/db/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then 
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
    chown InstantForge -R ${MADEIRA}
else 
    echo ">user 'InstantForge' already exists"
fi

