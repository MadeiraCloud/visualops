#!/bin/bash

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh
add_source ${DIR}/include/init-bootstrap.sh

GIT="root@211.98.26.6"
MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site

mkdir -p ${MADEIRA}
mkdir -p ${CONF}
mkdir -p ${DB}
mkdir -p ${DEPS}
mkdir -p ${SRC}
mkdir -p ${LOG}/scribe
mkdir -p ${SITE}/api

##git clone the repo from 26.6

cd ${SRC}
git clone ssh://${GIT}/opt/source/api.git

fn_yum_install python-devel
fn_yum_install python-setuptools

easy_install gearman
easy_install pymongo
easy_install kazoo
easy_install pycrypto
easy_install gevent

easy_install pip
pip install py_sdag2

add_source ${DIR}/include/zeromq-bootstrap.sh

pip install pyzmq

if [ `which thrift | wc -l` -eq 0 ]
then
    add_source ${DIR}/include/thrift-bootstrap.sh
else
    echo ">the thrift already installed"
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
