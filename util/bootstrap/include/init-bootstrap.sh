#!/bin/bash
#Amazon Linux AMI x86_64, centos 5.x/6.x
#

if [ -f "${MARK}/${0}.mark" ]
then
    return
fi

#sudo su-
DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

DEPLOY_ON_AWS=0
VPN_SUPPORT=""

if [ "${VPN_SUPPORT}" == "" ]
then
    #not set VPN_SUPPORT
    if [ ${DEPLOY_ON_AWS} -ne 1 ]
    then
        #not deploy on AWS
        VPN_SUPPORT=1
    else
        #deply on AWS, skip vpn
        VPN_SUPPORT=0
    fi
fi

TSOCKS=""
if [ ${VPN_SUPPORT} -eq 1 ]
then
    TSOCKS=""
fi

fn_yum_install git
fn_yum_install wget
fn_yum_install yum-plugin-priorities

fn_add_rpmforge
fn_add_epel_repo
fn_add_centalt_repo 
#fn_add_163_repo
fn_add_10gen
##fn_add_nginx

echo "##########################################################################################"
echo "       Install dependency packages"
echo "##########################################################################################"
# -------------- Dependency --------------
fn_yum_install patch
fn_yum_install tsocks
fn_yum_install gmp-devel
fn_yum_install uuid-devel 
fn_yum_install libuuid-devel
fn_yum_install autoconf
fn_yum_install make
fn_yum_install automake
fn_yum_install libtool
fn_yum_install tcl
fn_yum_install gcc-c++
OS=`cat  /etc/system-release | awk -F" release " '{print $1}'`
if  [ "${OS}" == "Amazon Linux AMI"  ]
then
  fn_yum_install python26-devel
  DPREV=${PWD}
  cd /tmp
  wget http://downloads.sourceforge.net/project/p7zip/p7zip/9.20.1/p7zip_9.20.1_src_all.tar.bz2
  tar xfj p7zip_9.20.1_src_all.tar.bz2
  cd p7zip_9.20.1
  cp makefile.linux_amd64 Makefile
  make
  make install
  cd $DPREV
  export PATH="${PATH}:/usr/local/bin/"
else
  fn_yum_install python-devel
  fn_yum_install p7zip
fi
fn_yum_install unzip

#other
fn_yum_install httpd
fn_yum_install python-setuptools

#check os
echo "##########################################################################################"
echo "       Checkint the os information"
echo "##########################################################################################"
fn_checkos

#check python26
fn_check_python26


#kill all process
fn_killall

