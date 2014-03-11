#!/bin/bash

if [ -f "${MARK}/${0}.mark" ]
then
    return
fi

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log


THRIFT_VER="thrift-0.5.0"
THRIFT_URL="http://archive.apache.org/dist/incubator/thrift/0.5.0-incubating/thrift-0.5.0.tar.gz"

## install boost
if [ `find / -name boost | grep ^/usr/include | wc -l` -eq 0 ]
then
    echo ">Installing boost"
    add_source ${DIR}/include/boost-bootstrap.sh
else
    echo ">Installed boost"
fi

fn_yum_install libevent
fn_yum_install libevent-devel
fn_yum_install ruby-devel

echo "##########################################################################################"
echo "       Installing Thrift"
echo "##########################################################################################"
#install Thrift 
fn_download_package ${THRIFT_VER}   ${THRIFT_URL} 0
#DISTRIBUTOR=`cat /etc/system-release | head -n 1 | cut -d ' ' -f 1`
./configure
#if [ $DISTRIBUTOR == "Amazon" ] ; then
#    mv /usr/lib64/libboost* /usr/lib
#fi
make
make install
cd lib/py/
python26 setup.py install
cd ../../contrib/fb303
./bootstrap.sh
make
make install
cd py
python26 setup.py install
#if [ $DISTRIBUTOR == "Amazon" ] ; then
#    mv /usr/lib/libboost* /usr/lib64
#fi
fn_check_cmd_rlt "Install  ${THRIFT_VER}" $?
