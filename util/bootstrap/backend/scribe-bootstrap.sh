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

add_source ${DIR}/include/init-bootstrap.sh

SCRIBE_VER=""
SCRIBE_URL="git://github.com/facebook/scribe.git"

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

if [ `which thrift | wc -l` -eq 0 ]
then
    add_source ${DIR}/include/thrift-bootstrap.sh
else
    echo ">the thrift already installed"
fi

echo "##########################################################################################"
echo "       Installing Scribe"
echo "##########################################################################################"

#cp bootstrap.sh.patch ${DEPS}/scribe/src

cd ${DEPS}
${TSOCKS} git clone git://github.com/facebook/scribe.git
if [ -d scribe ];then
  cd scribe
  DISTRIBUTOR=`cat /etc/system-release | head -n 1 | cut -d ' ' -f 1`
  if [ $DISTRIBUTOR == "Amazon" ] ; then
      #  patch -i bootstrap.sh.patch bootstrap.sh
      ./bootstrap.sh --with-boost-filesystem="boost_filesystem" --with-boost-system="boost_system"
      #  sed -i.bak "s/BOOST_LDFLAGS = -L\/usr\/lib/BOOST_LDFLAGS = -L\/usr\/lib64/g" src/Makefile
#      mv /usr/lib64/libboost* /usr/lib
  elif [ $DISTRIBUTOR == "CentOS" ] ; then
      ./bootstrap.sh --with-boost-filesystem=boost_filesystem
  else
      ./bootstrap.sh
  fi
  make
  make install
#  if [ $DISTRIBUTOR == "Amazon" ] ; then
#      mv /usr/lib/libboost* /usr/lib64
#  fi
  cd lib/py/
  python setup.py install
  fn_check_cmd_rlt "Install  scribe" $?
fi

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
