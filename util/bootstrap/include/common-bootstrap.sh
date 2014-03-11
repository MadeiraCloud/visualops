#!/bin/bash  
#Amazon Linux AMI x86_64,CentOS 5.x/6.x
#

if [ -f "${MARK}/${0}.mark" ]
then
    return
fi

#sudo su -
MADEIRA=/madeira
DEPS=${MADEIRA}/deps
REPL=${DEPS}/repl

mkdir -p ${REPL}

#enable vpn
#1 enable,     0 disable,  "" autoset by DEPLOY_ON_AWS(disable for aws,enable for other)
 VPN_SUPPORT=""

#remove deps/ dir after finish
#1 true  ,    0 false
  RM_DEPS=0

DEPLOY_ON_AWS=0

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

#################################
FNAME=`basename $0`
MODE=""

if [ "${FNAME}" == "bootstrap.sh" ]
then
  echo ">Run in script"
  MODE="0"
else
  echo ">Run in shell"
  MODE="1"
  set +H
fi


#########################################################################
# Constant Declaration
#########################################################################
#ansi color
B_TAG="\033"
H="[1"
H0="[0"
H1="[1"
E_TAG="\033[0m"
gray="2"
red="31"
green="32"
yellow="33"
blue="34"
purple="35"
cyan="36"
white="37"
black="40"

B="${B_TAG}${H};${white};${black}m"
E="${E_TAG}"

Ht="[7"
Bt="${B_TAG}${Ht};${white};${black}m"
Et="${E_TAG}"

H7="[0"             
B7="${B_TAG}${H};${green};${black}m"
E7="${E_TAG}"

#################################################
## Function declaration
#################################################
function fn_quit() {
  MSG=$1
  if [ ${MODE} -eq 1 ]
  then
  #shell
    set -H
  else
  #script
    echo " ${MSG} "
    exit
  fi
}

function add_source() {
    DSTATUS=${PWD}
    source $1
    cd $DSTATUS
}

function fn_vpn_support() {
#invoke when VPN_SUPPORT is 1

  PEM_FILE="singapore-vpn.pem"

  if [ -d ~/.ssh -a -f ~/.ssh/config -a -f ~/.ssh/${PEM_FILE} ]
  then
     echo ">vpn config OK"
     if [ `ps -ef | grep "ssh aws" | grep -v grep | wc -l` -ne 1 ]
     then
       fn_quit "please run 'ssh aws' in another terminal"
     fi
  else
    echo ">vpn not config,generate vpn config now..."
    
    mkdir -p ~/.ssh
    if [ ! -d ~/.ssh ]
    then
      fn_quit "~/.ssh can not be created,create vpn config failed!"
    fi
    cd ~/.ssh
  
    #gen config
    echo "Host aws
HostName 54.251.112.141
User ec2-user
IdentityFile ~/.ssh/${PEM_FILE}
CompressionLevel 6
DynamicForward localhost:3128" > config 

   #gen  ${PEM_FILE}
   echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAgxUK710gEfUON1Lnw8eF3glP7W+3cYBzyIlXkPbAD2F3cGo7nNfeE7A/g/nL
68SU+8MCPotJCG9CF6xQrfgDLhm1BDg8eA2/hwqxOZjgRG9nZfPGY+Bw/XGxM4t7mDneLkMQ5n8N
yeiZujwtiQUuh6EPVeN/LWf9JqxqP1ZUsLV8apeI9AQEDpACqquEEYKbsv+C4+xXwb6eSMxppoox
8DPQoI0jEYiwoNm/gcJhsu441ZOIxv6uUBsyYZw2tW/o8t42cz05I8PcLFLtc574Tw04jwvVibNC
NU2bQ5t2798SbEXPqduz4jwcLcNOimVSCJEFL/YtWy9r65Pmsi8upQIDAQABAoIBABawfcQRCowR
LvTElPl+f91/HyaqP8aVxXTg0Rd2nqgK5vG+cbMkanxd9aCSjImy7Vbm2myZD3s2RupyGUUDuQkx
yfOBCHZ/arelUif2Hlu6LNuo5p5DK0uzckjJzAr9eUfos/Qx6eEZMgLah8c/7l3rswva5Rim91rK
XVm5R8+OWidJJ9tEwVgKBK4AOs+Rzsr+HclTcXREA9NMK7Baz7xg1Sr9je2h0fYga5LfOmP/nWri
Mr/CnhuOKmUwyxGsEFZzUsJvMi6gtAW1wQmQ3m4r7e2xjblpZ3QUcZBSXjmGKZdEne/eJvpndkFp
KuPVt74x/70JUfhy11SB5quoncECgYEA2i4pmcdAdR7urvgGyTvBtlcKI1f0WqHq1vV+K4u5qViZ
H2TJTCijgqf4+291bBK2U0wAO6GYzOgS/w4KRf8H5dwacdSj0/9/jhiRGgFGdnSG4SzbhWY5+G5h
fUFzKBbl5EIZIhxOgcaPyY2uw5/p5RjZ56skV/vxvjxdsKFvLlMCgYEAmc3d4sxvJNpufWa1I+lT
46BFVUTPTjEJCOAfr+u6gZHQdQdZHzuWHS78K0OGEhPlik9zlJgZBTGYIkfDZro3lUQtWrINjlpc
zE7Alym6LWJqRAeSRFY5W+MttHfHNmMqNz/hGLCp7U+z4+/j4aQPNCjn6BoZWR+VbIaQOhegYCcC
gYEAhVq70KNJ0YxjhQxSUYM1xnZy2uFymEbpXBPW11Ti2RAvH1Ih+2vHbR+v/jbFBZZ2XHlSlyAR
XgTnP3/cZaYYtLUQcMzwia5bz4VSgxuObu6QVmdtkZ7HBgKpkb6EXVeJkjeYVxIIJigwUJhJ3oYK
lx3WalRftWtn+ce52DED3MMCgYA2ImKVwDTieMto8eyRzj9LoA6nO4fn0pSGfjRI/CRyFHuVpVd2
CcgFT5NMOwEGfeBN9TcONxafYFxWvIGHN8X2kL+R65ef4ihFdPaOfg5ciQY0GaIe0WZw9B4TJhGF
EBQ8zAwTX6L/twzvDnFb6x260ycE56LCXr5+K0K6X7SAAwKBgQDaCZwwyZeb0c7lnXFjeX1H+p1Z
nTIwb/OfqaNX05QxHtTXAkhdX4gdJq3okdAnGpplGEzoaJqS7VXMXfu1xrP/5J/7n8wZkndA2HFD
I51kkrwTSdN79WEw8coAtK7OKIOPztkJBAVWFETnKr+6BJzhPTGkdU5anSql+XBhjz+q+g==
-----END RSA PRIVATE KEY-----" > ${PEM_FILE}
    chmod 600 ${PEM_FILE}
    yum -y install tsocks
    echo "server = 127.0.0.1
server_type = 5
server_port = 3128" > /etc/tsocks.conf

    fn_quit "config vpn ok, please run 'ssh aws' in another terminal"

  fi

}



function fn_add_rpmforge() {
#invoke when DEPLOY_ON_AWS is not 1

    OS_VER=`cat  /etc/system-release | awk -F" release " '{print $2}' | awk -F"." '{print $1 }'`

    if [ ${OS_VER} -ne 5 -a ${OS_VER} -ne 6 ]
    then
      fn_quit "Just support CentOS 5.x and 6.x"
    fi

    ARCH=${HOSTTYPE}
    if [ "${HOSTTYPE}" == "x86_64" ]
    then  
      ARCH="x86_64"
    elif [ "${HOSTTYPE}" == "i686" -o "${HOSTTYPE}" == "i386" ]
    then
       case ${OS_VER}  in
          5)  ARCH="i386" 
                ;;
          6)  ARCH="i686" 
                ;;
       esac
    else
      fn_quit "unknow hosttype ${HOSTYPE}"
    fi

    if [ `rpm -qa | grep rpmforge-release | wc -l` -eq 0 ]
    then
      #rpmforge not installed
     
      RPMFORGE="rpmforge-release-0.5.2-2.el${OS_VER}.rf.${ARCH}.rpm"
      RPMFORGE_URL="http://pkgs.repoforge.org/rpmforge-release/${RPMFORGE}"
      
      echo ">Download and install ${RPMFORGE} ..."
      wget ${RPMFORGE_URL} --no-check-certificate -q
      if [ -f ${RPMFORGE} ]
      then
        rpm -ivh ${RPMFORGE}
      else
        fn_quit ">${RPMFORGE} download failed!"
      fi
    else
      #rpmforge installed
      echo ">rpmforge installed already"
    fi
}

function fn_add_epel_repo() {
    OS_VER=`cat  /etc/system-release | awk -F" release " '{print $2}' | awk -F"." '{print $1 }'`

    if [ ${OS_VER} -ne 5 -a ${OS_VER} -ne 6 ]
    then
      fn_quit "Just support CentOS 5.x and 6.x"
    fi
    ARCH=${HOSTTYPE}
    if [ "${HOSTTYPE}" == "x86_64" ]
    then  
      ARCH="x86_64"
    elif [ "${HOSTTYPE}" == "i686" -o "${HOSTTYPE}" == "i386" ]
    then
       case ${OS_VER}  in
          5)  ARCH="i386"
                ;;
          6)  ARCH="i686"
                ;;
       esac
    else
      fn_quit "unknow hosttype ${HOSTYPE}"
    fi

    NEED_INSTALL=0  # 0 no need install 1 new install 2 re-install
    if [ `rpm -qa | grep epel-release | wc -l` -eq 0 ]
    then
      echo "EPEL repo is not installed ,need install."
      NEED_INSTALL=1
    else
      if [ ! -f "/etc/yum.repos.d/epel.repo" ]
      then
        echo ">epel repo installed already,but /etc/yum.repos.d/epel.repo is not exist, need re-install "
        NEED_INSTALL=2
      else
        echo ">epel repo installed already"
      fi
    fi 

    case ${OS_VER} in
       6) EPELREPO_URL="http://dl.fedoraproject.org/pub/epel/${OS_VER}/${ARCH}/epel-release-6-8.noarch.rpm -O ${REPL}/epel-release-6-8.noarch.rpm"
          EPELREPO="epel-release-6-8.noarch"
          REMI_URL="http://rpms.famillecollet.com/enterprise/remi-release-${OS_VER}.rpm -O /${REPL}/remi-release-${OS_VER}.rpm"
          REMI="remi-release-${OS_VER}"
             ;;
       5) EPELREPO_URL="http://dl.fedoraproject.org/pub/epel/${OS_VER}/${ARCH}/epel-release-5-4.noarch.rpm -O ${REPL}/epel-release-5-4.noarch.rpm "
          EPELREPO="epel-release-5-4.noarch.rpm"
          REMI_URL="http://rpms.famillecollet.com/enterprise/remi-release-${OS_VER}.rpm -O /${REPL}/remi-release-${OS_VER}.rpm"
          REMI="remi-release-${OS_VER}"
             ;;
      *)  fn_show_message e "This script is for CentOS 5 and 6"
          return 1
    esac

    #un-install first
    if [ $NEED_INSTALL -eq 2 ]
    then
      echo "Uninstall ${EPELREPO} and ${REMI} ..." 
      rpm -e ${REMI}
      rpm -e ${EPELREPO}
    fi

    EPELREPO=${REPL}/${EPELREPO}.rpm
    REMI=${REPL}/${REMI}.rpm

    if [ $NEED_INSTALL -eq 1 -o $NEED_INSTALL -eq 2 ]
    then

      echo ">Download and install ${EPELREPO} ..."
      wget ${EPELREPO_URL} --no-check-certificate 
      if [ -f ${EPELREPO} ]
      then
        rpm -Uvh ${EPELREPO}
        if [ $? -eq 0 ]
        then
          fn_show_message i "Install ${EPELREPO} succeed! "
        else 
          fn_show_message e "Install ${EPELREPO} failed! " 
        fi
      else
        fn_quit ">${EPELREPO} download failed!"
      fi

      echo ">Download and install ${REMI} ..."
      wget ${REMI_URL} --no-check-certificate 
      if [ -f ${REMI} ]
      then
        rpm -Uvh ${REMI}
        if [ $? -eq 0 ]
        then
          fn_show_message i "Install ${REMI} succeed! "
        else 
          fn_show_message e "Install ${REMI} failed! " 
        fi
      else
        fn_quit ">${REMI} download failed!"
      fi

    fi
}

function fn_add_centalt_repo() {
    OS_VER=`cat  /etc/system-release | awk -F" release " '{print $2}' | awk -F"." '{print $1 }'`

    if [ ${OS_VER} -ne 5 -a ${OS_VER} -ne 6 ]
    then
      fn_quit "Just support CentOS 5.x and 6.x"
    fi
    ARCH=${HOSTTYPE}
    if [ "${HOSTTYPE}" == "x86_64" ]
    then
      ARCH="x86_64"
    elif [ "${HOSTTYPE}" == "i686" -o "${HOSTTYPE}" == "i386" ]
    then
       case ${OS_VER}  in
          5)  ARCH="i386"
                ;;
          6)  ARCH="i686"
                ;;
       esac
    else
      fn_quit "unknow hosttype ${HOSTYPE}"
    fi

    if [ `rpm -qa | grep centalt-release | wc -l` -eq 0 ]
    then
      #centalt repo  not installed
      case ${OS_VER} in
         6) CENTALT_URL="http://centos.alt.ru/repository/centos/${OS_VER}/${ARCH}/centalt-release-6-1.noarch.rpm"
            CENTALT="centalt-release-6-1.noarch.rpm"
               ;;
         5) CENTALT_URL="http://centos.alt.ru/repository/centos/${OS_VER}/${ARCH}/centalt-release-5-3.noarch.rpm"
            CENTALT="centalt-release-5-3.noarch.rpm"
               ;;
      esac
      echo ">Download and install ${CENTALT} ..."
      wget ${CENTALT_URL} --no-check-certificate -q
      if [ -f ${CENTALT} ]
      then
        rpm -ivh ${CENTALT}
      else
        fn_quit ">${CENTALT} download failed!"
      fi
    else
      echo ">centalt repo installed already"
    fi
}

function fn_add_163_repo() {

    OS_VER=`cat  /etc/system-release | awk -F" release " '{print $2}' | awk -F"." '{print $1 }'`

    if [ ${OS_VER} -ne 5 -a ${OS_VER} -ne 6 ]
    then
      fn_quit "Just support CentOS 5.x and 6.x"
    fi

    REPO163="CentOS${OS_VER}-Base-163.repo"
    if [ ! -f /etc/yum.repos.d/${REPO163} ]
    then
        echo   

        echo ">Download CentOS${OS_VER}-Base-163.repo"
        wget   http://mirrors.163.com/.help/${REPO163}  --no-check-certificate -q  -O /etc/yum.repos.d/${REPO163}
        if [ -f /etc/yum.repos.d/${REPO163} ]
        then
          echo ">Generate yum cache"
          yum makecache
        else
          fn_quit "download http://mirrors.163.com/.help/${REPO163} failed!quit"
        fi
    else
        echo ">${REPO163} already exist,skip!"

    fi
}

function fn_checkos() {

  OS=`cat  /etc/system-release | awk -F" release " '{print $1}'`
  if  [ "${OS}" != "CentOS"  -a   "${OS}" != "Amazon Linux AMI"  ]
  then
    fn_quit "This script can only run on CentOS or Amazon Linux AMI,quit"
  fi

  if [ ${VPN_SUPPORT} -eq 1 ]
  then
    echo ">Add vpn support..."
    fn_vpn_support
  fi
 
  if [ ${DEPLOY_ON_AWS} -ne 1 ]
  then

    echo ">Check rpmforge repo..."
    fn_add_rpmforge

    echo ">Check 163 mirror repo..."
    fn_add_163_repo
fi
 

}




function fn_killall() {
  #kill all
  rm -rf ${DB}/mongod.lock
  ps -ef | grep -E "AppService|scribed|Karajan|mongod|redis-server|gearmand|supervisord" | grep -v "grep" | grep -v "supervisord-bootstrap" | awk '{system("kill -9 "$2)}'
}

function fn_showall() {
#show all
  ps -ef | grep -E "AppService|scribed|Karajan|mongod|redis-server|gearmand|upervisord" | grep -v "grep" | grep -v "supervisord-bootstrap"

}

#######################################
# Usage: fn_show_message e "some error"
#######################################
function fn_show_message() {

  lvl=${1:-u}
  msg=$2
  COLOR=${white}
  LEVEL=""
  case $lvl in
      i)  LEVEL="INFO:    "
          COLOR=${green}
      ;;
      w)  LEVEL="WARNING: "
          COLOR=${yellow}
      ;;
      e)  LEVEL="ERROR:   "
          COLOR=${red}
      ;;
      *)  LEVEL="UNKNOW:  "
          COLOR=${blue}
      ;;
  esac

  msg="${B_TAG}${H};${COLOR};${black}m ${LEVEL}${msg} ${E_TAG}"
  echo -e "$(date +%Y/%m/%d\ %H:%M:%S) : $msg"

}

function fn_check_exist() {
  which $1 1>/dev/null 2>/dev/null
  if [ $? -eq 0 ]
  then
    echo 'true'
  else
    echo 'false'
  fi
}

function fn_check_python26() {

  if [ "`fn_check_exist python26`" == "false" ]
  then
   #python26 not exist
   if [ "`fn_check_exist python2.6`" == "true" ]
   then
    #python2.6 exist
    echo ">Create soft link python26 to python2.6..."
    ln -s `which python2.6` /usr/bin/python26
   elif [ "`fn_check_exist python`" == "false" ]
   then
    #python not exist
    fn_quit "Require python26, Please run 'yum -y install python' to install python first!"
   else 
    #python exist,check version
    PYTHON_VER=`python -V 2>&1 | awk 'BEGIN{FS="[ .]"}{print $2$3}'`
    if [ "${PYTHON_VER}" == "26"  ]
    then
      #python version is 2.6 
      ln -s `which python` /usr/bin/python26
    else
      #python version is not 2.6
      fn_quit "Require python26, Current version is ${PYTHON_VER},please install python26"
    fi  
   fi

  fi

  if [ "`fn_check_exist python26`" == "false" ]
  then
   fn_quit "python26 not exist!please install python26 first!"
  else
   echo ">Check python26 OK"
  fi

}

function fn_add_nginx() {

  echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
  echo ">Add nginx yum repo succeed!"
}

function fn_add_10gen() {

  ARCH=${HOSTTYPE}
  if [ "${HOSTTYPE}" == "x86_64" ]
  then	
    ARCH="x86_64"
  elif [ "${HOSTTYPE}" == "i686" -o "${HOSTTYPE}" == "i386" ]
  then
    ARCH="i686"
  else
    fn_quit "Add 10gen failed, unknow hosttype ${HOSTYPE}"
  fi

  echo "[10gen]
name=10gen Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/${ARCH}
gpgcheck=0
enabled=1" > /etc/yum.repos.d/10gen.repo
  echo ">Add 10gen yum repo succeed!"
}

function fn_yum_install () {

  PKG=$1

  echo -n ">Check package ${PKG}..."
  if [ `rpm -qa | grep ^${PKG}-[0-9] | wc -l` -eq 0 ]
  then
    #need install
    echo -e "${B_TAG}${H};${yellow};${black}m     \tnot installed,now will install ${PKG} ${E_TAG}"
    yum -y install ${PKG}
    if [  $? -ne 0 ]
    then
      echo 
      fn_show_message e "yum install package ${PKG} error"
      fn_quit "Quit for fn_yum_install ${PKG}"
      echo 
    else
      echo -e "${B_TAG}${H};${green};${black}m     \t Install ${PKG} succeed ${E_TAG}"  
    fi
  else
    echo -e "${B_TAG}${H};${green};${black}m     \tinstalled ${E_TAG}"
    rpm -qa | grep ^${PKG}[0-9]
  fi

 

}


function fn_check_cmd_rlt() {

  CMD=$1
  RLT=$2

  if [ ${RLT} -ne 0 ]
  then
    fn_quit "Command run fail: ${CMD}"
  fi

}

#download package  and untar
function fn_download_package() {
 
  PKG_VER=$1
  PKG_URL=$2
  RE_GET=$3 #1 true , 0 false

  cd ${DEPS}
  
  echo 
  echo "###############################################################################"
  echo "                 Download and install package ${PKG_VER}              "
  echo "###############################################################################"

  #check file exist
  if [ ! -f ./${PKG_VER}.tar.gz -o ${RE_GET} -eq 1 ]
  then
    ${TSOCKS} wget ${PKG_URL} --no-check-certificate
  else 
    echo ">${DEPS}/${PKG_VER}.tar.gz already exist,skip download" 
  fi
  if [ -f ./${PKG_VER}.tar.gz ]
  then
    tar xzf ${PKG_VER}.tar.gz
    #check tar, 0 succeed  other failed
    if [ $? -ne 0 ]
    then
      #untar failed,re-download
      rm -rf ./${PKG_VER}.tar.gz
      fn_download_package ${PKG_VER} ${PKG_URL} 1
    else
      echo "untar ${PKG_VER}.tar.gz succeed!"
    fi
  else
     fn_quit "${PKG_VER}.tar.gz not exist, download failed! quit"
  fi

  if [ ! -d ${PKG_VER} ]
  then
     fn_quit "Dir ${PKG_VER}  not exist, untar failed, quit"  
  fi  

  cd ${PKG_VER} 

}





