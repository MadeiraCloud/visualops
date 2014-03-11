#!/bin/bash

GIT="root@211.98.26.6"
MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

mkdir -p ${MADEIRA}
mkdir -p ${CONF}
mkdir -p ${DB}
mkdir -p ${DEPS}
mkdir -p ${SRC}
mkdir -p ${LOG}/scribe
mkdir -p ${SITE}/api

##git clone the repo from 26.6
#init:add repo , check os info
add_source ${DIR}/include/init-bootstrap.sh

cd ${SRC}
git clone ssh://${GIT}/opt/source/api.git

fn_yum_install python-devel
fn_yum_install python-setuptools
easy_install gearman
easy_install jsonrpclib
easy_install pymongo
easy_install redis
easy_install py_bcrypt
easy_install pycrypto

add_source ${DIR}/include/tornado-bootstrap.sh

sed -i -e "/^export LD_LIBRARY_PATH=/d"  ~/.bashrc
sed -i -e "/^export PYTHONPATH=/d"  ~/.bashrc
sed -i -e "/^export INSTANT_HOME=/d"  ~/.bashrc
echo >>  ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/" >>  ~/.bashrc
echo "export PYTHONPATH=${SRC}/api/Source/" >> ~/.bashrc
echo "export INSTANT_HOME=${MADEIRA}" >> ~/.bashrc
source ~/.bashrc

mkdir -p ${DB}/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
else
    echo ">user 'InstantForge' already exists"
fi
chown InstantForge -R ${MADEIRA}
