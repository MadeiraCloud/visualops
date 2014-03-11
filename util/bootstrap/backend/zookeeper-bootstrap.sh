#!/bin/bash

MADEIRA=/madeira
DEPS=${MADEIRA}/deps
DIR=${MADEIRA}/util/bootstrap

mkdir -p ${DEPS}
mkdir -p ${DIR}

source ${DIR}/include/common-bootstrap.sh

fn_yum_install wget
fn_yum_install java

ZOOKEEPER_VER="zookeeper-3.4.5"
#ZOOKEEPER_URL="http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz"
ZOOKEEPER_URL="http://www.apache.org/dist/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz"

cd ${DEPS}
wget -c ${ZOOKEEPER_URL}
tar zxvf ${ZOOKEEPER_VER}.tar.gz
mv ${ZOOKEEPER_VER} zookeeper

mkdir -p ${MADEIRA}/log/zookeeper

if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then 
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
else 
    echo ">user 'InstantForge' already exists"
fi

chown -R InstantForge ${MADEIRA}/log/zookeeper
