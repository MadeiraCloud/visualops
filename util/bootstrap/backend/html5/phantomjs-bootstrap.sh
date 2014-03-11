#!/bin/bash
#install nginx on CentOS
DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh
fn_vpn_support

#################################################
## Function declaration
#################################################
function quit() {
  MSG=$1
  if [ ${MODE} -eq 1 ]
  then
  #shell
    set -H
  else
  #script
    echo ":(${MSG}"
    exit
  fi
}


#install package  by yum
function yum_install() {

  PKG=$1

  echo ">Check package ${PKG}..."
  if [ `rpm -qa | grep ^${PKG}-[0-9] | wc -l` -eq 0 ] 
  then
    #need install
    yum -y install ${PKG}
  else
    echo ">${PKG} already installed:"
    rpm -qa | grep ^${PKG}[0-9]
  fi

}



#download package  and untar
function download_package() {
 
  PKG_VER=$1
  PKG_URL=$2
  RE_GET=$3 #1 true , 0 false

  cd ${PHANTOMJS}
  
  echo 
  echo "###############################################################################"
  echo "                 Download and install package ${PKG_VER}              "
  echo "###############################################################################"

  #check file exist
  if [ ! -f ./${PKG_VER}.tar.bz2 -o ${RE_GET} -eq 1 ]
  then
    #${TSOCKS} wget -c ${PKG_URL} --no-check-certificate
    wget -c ${PKG_URL} --no-check-certificate
  else 
    echo ">${PHANTOMJS}/${PKG_VER}.tar.gz already exist,skip download" 
  fi
  if [ -f ./${PKG_VER}.tar.bz2 ]
  then
    tar -xvjf ${PKG_VER}.tar.bz2
    #check tar, 0 succeed  other failed
    if [ $? -ne 0 ]
    then
      #untar failed,re-download
      rm -rf ./${PKG_VER}.tar.bz2
      download_package ${PKG_VER} ${PKG_URL} 1
    else
      echo "untar ${PKG_VER}.tar.bz2 succeed!"
    fi
  else
     quit "${PKG_VER}.tar.bz2 not exist, download failed! quit"
  fi

  if [ ! -d ${PKG_VER} ]
  then
     quit "Dir ${PKG_VER}  not exist, untar failed, quit"  
  fi  

}





#################################################
## Main
#################################################
MADEIRA=/madeira
DEPS=${MADEIRA}/deps
PHANTOMJS=${DEPS}/phantomjs
#TSOCKS=tsocks
TSOCKS=

mkdir -p $PHANTOMJS
cd $PHANTOMJS
echo $PHANTOMJS


PHANTOMJS_VER=phantomjs-1.9.1-linux-x86_64
PHANTOMJS_URL=https://phantomjs.googlecode.com/files/${PHANTOMJS_VER}.tar.bz2


#######################################
FNAME=`basename $0`
MODE=""

if [ "${FNAME}" == "phantomjs-bootstrap.sh" ]
then
  echo ">Run in script"
  MODE="0"
else
  echo ">Run in shell"
  MODE="1"
  set +H
fi

#######################################
#stop phantomjs process

############# install lib #############
yum_install tsocks
yum_install nodejs
yum_install npm
npm install coffee-script -g

#############download dependency#############

############# download nginx#############
download_package $PHANTOMJS_VER $PHANTOMJS_URL 0

############# compile & install #############
if [ -f ${PHANTOMJS}/${PHANTOMJS_VER}/bin/phantomjs ]
then
  cp ${PHANTOMJS}/${PHANTOMJS_VER}/bin/phantomjs /usr/local/bin/
  echo "Install phantomjs to /usr/local/bin/ succeed"
  echo "Please run 'phantomjs -v'"
  echo ""
  echo "cd /madeira/source/html5/phantom"
  echo "npm install"

else
  echo "Can not found ${PHANTOMJS}/${PHANTOMJS_VER}/bin/phantomjs, install phantomjs failed"
fi
