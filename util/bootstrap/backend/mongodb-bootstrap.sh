#!/bin/bash


DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh

MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
LOCK=${MADEIRA}/lock
ROCKMONGO_WWW=/var/www/rockmongo

mkdir -p ${MADEIRA}
mkdir -p ${CONF}
mkdir -p ${DB}
mkdir -p ${DEPS}
mkdir -p ${SRC}
mkdir -p ${LOG}
mkdir -p ${LOCK}
mkdir -p ${DB}/mongos

CONFIGSERV="localhost:8291"
CLUSTERSERV="localhost:8290"
CLUSTERDB="forge"

DEPLOY_ON_AWS=0
VPN_SUPPORT=""

ROCKMONGO_VER="rockmongo-v1.1.4.zip"
ROCKMONGO_URL="http://cloud.github.com/downloads/iwind/rockmongo/rockmongo-v1.1.4.zip"

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


CHOICE="y"
if [ $1 != "rock" ]; then
#choice for install rockmong or not
    echo
    echo -e "Are you sure to install rockmongo?(y for yes,other for no):"
    read CHOICE
fi

####################################################
function install_rockmongo() {

  #rockmongo
  if [ -f rockmongo-v1.1.4.zip ]
  then
   rm rockmongo-v1.1.4.zip -rf
  fi
  ${TSOCKS} wget ${ROCKMONGO_URL}   --no-check-certificate
  if [ -f ${ROCKMONGO_VER} ]
  then
    unzip -o ${ROCKMONGO_VER}
    if [ -d ${ROCKMONGO_WWW} ]
    then
      rm ${ROCKMONGO_WWW} -rf
    fi
    mv rockmongo-master ${ROCKMONGO_WWW}
    sed -i -e "s/27017/8290/g" ${ROCKMONGO_WWW}/config.php
    sed -i -e "s/\"admin\";/\"instant\";/g" ${ROCKMONGO_WWW}/config.php

    if [ -f /etc/httpd/conf/httpd.conf ]
    then

      #1.Listen
      sed -i "/^Listen/c Listen 8080" /etc/httpd/conf/httpd.conf    

      #ServerName
      IP=`/sbin/ifconfig eth0 | awk -F'[ :]+' '/inet addr/{print $4}'`
      sed -i "/^ServerName/c ServerName ${IP}:8080" /etc/httpd/conf/httpd.conf    

      #3.Directory
      FOUND=`cat /etc/httpd/conf/httpd.conf | grep "Alias /rockmongo \"${ROCKMONGO_WWW}\"" | wc -l`
      if [ ${FOUND} -eq 0 ]
      then
        echo '
  Alias /rockmongo "/var/www/rockmongo"
  <Directory "/var/www/rockmongo">
      Options Indexes MultiViews
      AllowOverride None
      Order allow,deny
      Allow from all
  </Directory>' >> /etc/httpd/conf/httpd.conf


      fi
    else
      echo "Not found /etc/httpd/conf/httpd.conf !"
    fi
  else 
    fn_quit "Download ${ROCKMONGO_URL} failed,quit"
  fi

}

function fn_10gen_add () {
echo -n 'Adding MongoDB repo ...  '
TMP_PROC_TYPE=`uname -p`
echo "
[10gen]
name=10gen Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/${TMP_PROC_TYPE}
gpgcheck=0
enabled=1" > /etc/yum.repos.d/10gen.repo
echo '[DONE]'
}

echo "##########################################################################################"
echo "       Installing Mongodb"
echo "##########################################################################################"
#add_source ${DIR}/include/init-bootstrap.sh

#mongodb
fn_10gen_add
fn_yum_install mongo-10gen 
fn_yum_install mongo-10gen-server
#check_result $? "yum install mongodb"

mkdir -p ${DEPS}
cd ${DEPS}

#rockmongo
if [ "${CHOICE}" == "y" ]
then
  echo "##########################################################################################"
  echo "       Installing Rockmongo"
  echo "##########################################################################################"
  install_rockmongo
else
  echo "##########################################################################################"
  echo "       Skip Install Rockmongo"
  echo "##########################################################################################"
fi

mkdir -p /data/db

# -------------- Configuration --------------
# mongodb
ulimit -f 				# (file size): unlimited
ulimit -t 				# (cpu time): unlimited
ulimit -v 				# (virtual memory): unlimited
ulimit -n 64000			# (open files): 64000
ulimit -m				# (memory size): unlimited
ulimit -u 32000			# (processes/threads): 32000

mkdir -p ${MADEIRA}/db/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then 
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
    chown InstantForge -R ${MADEIRA}
else 
    echo ">user 'InstantForge' already exists"
fi

echo "###########################################"
echo "# Check mongodb #"
whereis mongo mongod
mongo --version
mongod --version
echo "###########################################"

echo "###########################################"
echo "# Configure mongos #"
echo "###########################################"

sed -i.bak "s/configdb=.*/configdb=${CONFIGSERV}/g" ${CONF}/mongos.conf
mv ${CONF}/mongos.conf.bak /tmp/

LOCALCFG=`echo ${CONFIGSERV} | grep -e 'localhost' -e '127.0.0.1' | wc -l`
LOCALCLS=`echo ${CLUSTERSERV} | grep -e 'localhost' -e '127.0.0.1' | wc -l`

if [ ${LOCALCFG} -eq 1 ]; then
    mongod -f ${CONF}/mongod-config.conf --smallfiles --fork
fi
if [ ${LOCALCLS} -eq 1 ]; then
    mongod -f ${CONF}/mongod.conf --smallfiles --fork
fi
mongos -f ${CONF}/mongos.conf --fork

mongo --host localhost --port 8292 <<EOF
sh.addShard( "${CLUSTERSERV}" )
sh.enableSharding("${CLUSTERDB}")
EOF

kill -9 `cat ${LOCK}/mongos.pid`
if [ ${LOCALCLS} -eq 1 ]; then
    kill -9 `cat ${LOCK}/mongod.pid`
fi
if [ ${LOCALCFG} -eq 1 ]; then
    kill -9 `cat ${LOCK}/mongod-config.pid`
fi
