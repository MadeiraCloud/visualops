#!/bin/bash

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh
add_source ${DIR}/include/init-bootstrap.sh

MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log

fn_yum_install wget
fn_yum_install python-setuptools


echo "##########################################################################################"
echo "       Installing Supervisord"
echo "##########################################################################################"

easy_install supervisor
echo_supervisord_conf > /etc/supervisord.conf

#cd ${DEPS}

#wget -c http://pypi.python.org/packages/source/m/mr.rubber/mr.rubber-1.0dev.tar.gz
#tar zxvf mr.rubber-1.0dev.tar.gz
cd /madeira/util/bootstrap/supervisord/mr.rubber-1.0dev
python setup.py build
python setup.py install
