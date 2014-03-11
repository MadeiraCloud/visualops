#!/bin/bash

if [ -f "${MARK}/${0}.mark" ]
then
    echo "exit boost"
    return
fi
echo "get boost"

DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh


MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site

echo "${DEPS}"

BOOST_VER="boost_1_45_0"
BOOST_DIR=${MADEIRA}/util/boostrpm/rpm
#BOOST_URL="http://ncu.dl.sourceforge.net/project/boost/boost/1.45.0/boost_1_45_0.tar.gz"

if [ `uname -r | grep 'amzn' | wc -l` = 1 ]
then
    echo "Platform = amazon Linux"
    BOOST_FILES='*.amzn1.x86_64.rpm'
else
    echo "Platform = CentOS 6"
    BOOST_FILES='*.el6.x86_64.rpm'
fi

FOUND_GCC=`yum search gcc46 | grep 'gcc46.' | grep -v "grep"  | wc -l`
if [ ${FOUND_GCC} -eq 0 ]
then
  #not found
  fn_yum_install gcc
  fn_yum_install gcc-c++
else
  fn_yum_install gcc46
  fn_yum_install gcc46-c++
fi

fn_yum_install zlib-devel
fn_yum_install bzip2-devel
fn_yum_install libstdc++ libstdc++-devel
fn_yum_install libicu


echo "##########################################################################################"
echo "       Installing Boost"
echo "##########################################################################################"
#install Boost
cd ${BOOST_DIR}
#fn_download_package ${BOOST_VER}   ${BOOST_URL} 0
#./bootstrap.sh
#./bjam
#./bjam install
#fn_check_cmd_rlt "Install  ${BOOST_VER}" $?

#rpm -i `find . -type f -name ${BOOST_FILES}`
rpm -i ${BOOST_FILES}
