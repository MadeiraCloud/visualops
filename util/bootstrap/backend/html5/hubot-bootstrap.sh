#!/bin/bash
#hubot-bootstrap.sh
#
#Written by Jimmy Xu 2013-08-09
#Last modified: 2013-08-09
#
#This script support
#1.CentOS 5.x/6.x  i386/i686/x86_64
#2.Ubuntu 11.x/12.x/13.x i386/i686/x86_64
#3.Cygwin
#4.MacOSX
#5.MSysGit
#
#

STARTTIME=`date "+%Y-%m-%d %H:%M:%S"`

#################################################
## Main
#################################################
MADEIRA=/madeira
DIR=${MADEIRA}/util/bootstrap
DEPS=${MADEIRA}/deps
HUBOT_ROOT=${MADEIRA}/source/html5

#######################################
FNAME=`basename $0`
MODE=""

if [ "${FNAME}" == "hubot-bootstrap.sh" ]
then
  echo ">Run in script"
  MODE="0"
else
  echo ">Run in shell"
  MODE="1"
  set +H
fi


##Function declaration####################################

function quit(){
  MSG=$1
  if [ ${MODE} -eq 1 ]
  then
  #shell
    set -H
  else
  #script
    echo $MSG
    exit
  fi
}

function download(){
  date "+%Y-%m-%d %H:%M:%S Start download $1"
  wget -q -c $1
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


function setup_centos(){

  echo
  echo "Setup under CentOS..."
  echo

  yum_install nodejs
  yum_install npm

}



function setup_ubuntu(){

  echo
  echo "Setup under Ubuntu..."
  echo


  echo
  echo "=============================================="
  echo "Step 2. Now will download and install nodejs"
  echo ""


  nodejs --version
  if [ $? -eq 0 ]
  then
    echo "already install nodejs"

  else

    echo "now install nodejs"
    apt-get remove node
    #apt-get autoremove

    apt-get update
    apt-get install python-software-properties python g++ make
    add-apt-repository ppa:chris-lea/node.js
    apt-get update
    apt-get install nodejs
  fi

  if [ ! -f /usr/sbin/node ]
  then
    ln -s /usr/sbin/nodejs /usr/sbin/node
  fi

  if [ ! -f /usr/bin/node ]
  then
    ln -s /usr/sbin/nodejs /usr/bin/node
  fi

}


function setup_cygwin(){

  echo
  echo "Setup under cygwin..."
  echo

}
############################################


function setup_macosx(){

  echo
  echo "Setup under macosx..."
  echo

  if [  ${IS_ROOT} -ne 1 ]
  then
    # hasn't root permisson
    quit "User `who am i | awk '{print $1}'` must has root permission!"
  fi

  port
  if [ $? -eq 0 ]
  then

    echo
    echo  -e "Macports installed, please uninstall it and install Homebrew"
    echo
    echo "please run the following command:"
    echo "  port -f uninstall installed"
    echo
    echo "then run the following command:"
    echo '  rm -rf \'
    echo '    /opt/local \'
    echo '    /Applications/DarwinPorts \'
    echo '    /Applications/MacPorts \'
    echo '    /Library/LaunchDaemons/org.macports.* \'
    echo '    /Library/Receipts/DarwinPorts*.pkg \'
    echo '    /Library/Receipts/MacPorts*.pkg \'
    echo '    /Library/StartupItems/DarwinPortsStartup \'
    echo '    /Library/Tcl/darwinports1.0 \'
    echo '    /Library/Tcl/macports1.0 \'
    echo '    ~/.macports'
    echo
    echo "then run the following command:"
    echo '  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"'
    echo
    quit "Please install Homebrew, then re-execute this script!"

  else
    echo
    echo "Macports not installed,OK"
  fi

  brew --version
  if [ $? -ne 0 ]
  then
    echo
    echo "Homebrew not installed ,please install it first "
    echo
    echo "run the following command:"
    echo 'ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"'
    echo
    quit "Please install Homebrew, then re-execute this script!"
  fi

  sudo -u `who am i|awk '{print $1}'` brew install node



}

############################################


function setup_mingw32(){

  echo
  echo "Setup under MINGW32..."
  echo


  node --version
  if [ $? -eq 0 ]
  then
    echo "already install node"
  else
    echo "please download nodejs for windows from the following url, and install by manual"
    echo "http://nodejs.org/download/"
    echo "after finish the above step, please run this shell again."
    exit
  fi


}

##main##########################################
function main(){


  echo
  echo "=============================================="
  echo "Step 1. Check OS and Arch..."
  echo

  IS_ROOT=""
  #check user , must has root permission
  if [  $UID -eq 0 ]
  then
    # has root permisson
    echo "User `who am i | awk '{print $1}'` has root permission"
    IS_ROOT="1"
  else
    # hasn't root permisson
    echo "User `who am i | awk '{print $1}'` hasn't root permission"
    IS_ROOT="0"
  fi

  ##check system
  UNAME=`uname -a | awk 'BEGIN{FS="[_ ]"}{print $1}'`
  echo "You are using ${UNAME}"





  if [ "${UNAME}" == "Linux" ]
  then
   ##########Linux##########


    ##check distributor
    #DISTRIBUTOR=`lsb_release -a 2>/dev/null| grep "Distributor ID" | awk '{print $3}'`
    ##check os version
    #OSVERSION=`lsb_release -a | grep Release | awk 'BEGIN{FS="[:. \t]"}{print $3}' `
   #echo "Your OS : ${DISTRIBUTOR} ${OSVERSION}.x ${HOSTTYPE} "

    ALLOS=`cat /etc/*release | head -n 1`
    DISTRIBUTOR=`cat /etc/*release | head -n 1 | cut -d '=' -f 2| cut -d ' ' -f 1`
    OSVERSION=''

    echo "Your OS: ${ALLOS}"
    echo "Your DISTRIBUTOR: ${DISTRIBUTOR}"
    if [ "${DISTRIBUTOR}" == "CentOS" ]
    then
      echo "CentOS"
      OSVERSION=`cat /etc/*release | head -n 1 | cut -d '=' -f 2| cut -d ' ' -f 3  | awk 'BEGIN{FS="[:. \t]"}{print $1}' `
      if [ ${OSVERSION} -ne 5 -a ${OSVERSION} -ne 6 ]
      then
          quit "Only support CentOS 5.x and CentOS 6.x,Quit!"
      fi
    elif [ "${DISTRIBUTOR}" == "Amazon" ]
    then
      echo "Amazon Linux"
    elif [ "${DISTRIBUTOR}" == "Ubuntu"  ]
    then
      echo "Ubuntu"
      OSVERSION=`lsb_release -a | grep Release | awk 'BEGIN{FS="[:. \t]"}{print $3}' `
      if [ ${OSVERSION} -ne 13 -a ${OSVERSION} -ne 12 -a ${OSVERSION} -ne 11 ]
      then
                quit "Only support Ubuntu 11.x / 12.x / 13.x ,Quit!"
      fi
    else
      quit "Only support CentOS and Ubuntu,Quit!"
    fi

    ARCH=${HOSTTYPE}
    SUFFIX=""

    if [ "${HOSTTYPE}" == "x86_64" ]; then
      ARCH="x86_64"
    elif [ "${HOSTTYPE}" == "i686" -o  "${HOSTTYPE}" == "i386"  ]; then
      if [ "${OSVERSION}" == "5" ]
      then
          ARCH="i386"
      elif [ "${OSVERSION}" == "6" ]
      then
          ARCH="i686"
      fi
    fi

    if [ "${ARCH}" == "" ]
    then
      quit "${HOSTTYPE} unknown,exit!"
    fi

    case  "${OSVERSION}" in
     "5")
      SUFFIX="el${OSVERSION}.rf.${ARCH}"
      ;;
     "6")
      SUFFIX="el${OSVERSION}.rfx.${ARCH}"
      ;;
    esac

    echo ">>Pass check!"

    if [ "${DISTRIBUTOR}" == "CentOS" ]
    then
      #####CentOS#####
      setup_centos
    elif [ "${DISTRIBUTOR}" == "Amazon" ]
    then
      #####Amazon Linux as CentOS #####
      setup_centos
    else
      #####Ubuntu#####
      setup_ubuntu
    fi

  elif [ "${UNAME}" == "CYGWIN" ]
  then
    ##########Cygwin##########
    setup_cygwin

  elif [ "${UNAME}" == "Darwin" ]
  then
    ##########MacOSX##########
    setup_macosx

  elif [ "${UNAME}" == "MINGW32" ]
  then
    ##########MsysGit##########
    setup_mingw32

  else

     quit "This script do not support current system ${UNAME}"
  fi



  ############# install dependency #############

  coffee --version
  if [ $? -eq 0 ]
  then
    echo "already install coffee-script"
  else
    echo "now install coffee-script"
    npm install coffee-script -g
  fi

  redis-server --version
  if [ $? -eq 0 ]
  then
    echo "already install redis-server"
  else
    echo "now install redis-server"
    if [ "${UNAME}" == "Linux" ]
    then
      source ${DIR}/backend/redis-bootstrap.sh
    elif [ "${UNAME}" == "Darwin" ]
    then
      brew install redis
    elif [ "${UNAME}" == "MINGW32" ]
    then
      echo "please download redis server for windows from the following url and install by manual"
      echo "https://github.com/rgl/redis/downloads"
      echo "please run 'sc start redis' after install redis server"
      echo "after finish the step above, please run this shell again"
      exit
    fi


  fi

  #######################################


  ######### Set Environment variable #############

  #remove old setting
  sed -i -e "/############################## for hubot ############################/d"  ~/.bashrc
  sed -i -e "/^##hubot/d"  ~/.bashrc
  sed -i -e "/####new####/d"  ~/.bashrc
  sed -i -e "/####dev####/d"  ~/.bashrc
  sed -i -e "/###region###/d"  ~/.bashrc
  sed -i -e "/##for trello/d"  ~/.bashrc
  sed -i -e "/^export PATH=node_modules/d"  ~/.bashrc
  sed -i -e "/export HUBOT_/d"  ~/.bashrc
  sed -i -e "/export PORT=/d"  ~/.bashrc
  sed -i -e "/## for aws/d"  ~/.bashrc
  sed -i -e "/#hubot port (default 8080)/d"  ~/.bashrc

  echo "
  ############################## for hubot ############################
  ##hubot
  export PATH=node_modules/.bin:\${PATH}
  export HUBOT_AUTH_ADMIN=
  export HUBOT_LOG_LEVEL=info
  ## for aws
  ####new####
  export HUBOT_AWS_ACCESS_KEY_ID=AKIAJUQBGX5Y7HGQHLHQ
  export HUBOT_AWS_SECRET_ACCESS_KEY=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
  ####dev####
  #export HUBOT_AWS_ACCESS_KEY_ID=AKIAJLAUFM2FAOWIE4XQ
  #export HUBOT_AWS_SECRET_ACCESS_KEY=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
  ###region###
  export HUBOT_AWS_EC2_REGIONS=us-east-1,us-west-1,us-west-2,eu-west-1,ap-southeast-1,ap-southeast-2,ap-northeast-1,sa-east-1
  export HUBOT_AWS_SQS_REGIONS=
  ##for trello
  export HUBOT_TRELLO_KEY=230d5d1549f0d36447fc63a0403bdd90
  export HUBOT_TRELLO_TOKEN=84b1200eb33b81f4fc2423813d2c7f1737924f1d493236de29117c0cfc68543e
  export HUBOT_TRELLO_BOARDS=50767b57d1f2941e2e16ec3c,515b9e555f1be6a62400722d
  export HUBOT_TRELLO_NOTIFY_ROOM=campfire
  #hubot port (default 8080)
  export PORT=8888
  " >> ~/.bashrc

  ############# git clone hubot #############

  mkdir -p ${HUBOT_ROOT}
  cd ${HUBOT_ROOT}
  git clone ssh://root@211.98.26.6/opt/source/html5/hubot.git


  if [ -d ${HUBOT_ROOT}/hubot ]
  then

    chown InstantForge:InstantForge ${HUBOT_ROOT}/hubot -R

    echo "##########################################################"
    echo "please run the following command after clone hubot"
    echo "##########################################################"

    echo "source ~/.bashrc"
    echo "cd ${HUBOT_ROOT}/hubot"
    echo "npm install"
    echo "./bin/hubot"
    echo "hubot help"

  else
    quit "git clone hubot failed!"

  fi


}

#######################################
main