#!/bin/bash
#install nginx on CentOS
DIR=/madeira/util/bootstrap
source ${DIR}/include/common-bootstrap.sh
add_source ${DIR}/include/init-bootstrap.sh

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

  cd ${NGINX}
  
  echo 
  echo "###############################################################################"
  echo "                 Download and install package ${PKG_VER}              "
  echo "###############################################################################"

  #check file exist
  if [ ! -f ./${PKG_VER}.tar.gz -o ${RE_GET} -eq 1 ]
  then
    ${TSOCKS} wget ${PKG_URL} --no-check-certificate
  else 
    echo ">${NGINX}/${PKG_VER}.tar.gz already exist,skip download" 
  fi
  if [ -f ./${PKG_VER}.tar.gz ]
  then
    tar xzf ${PKG_VER}.tar.gz
    #check tar, 0 succeed  other failed
    if [ $? -ne 0 ]
    then
      #untar failed,re-download
      rm -rf ./${PKG_VER}.tar.gz
      download_package ${PKG_VER} ${PKG_URL} 1
    else
      echo "untar ${PKG_VER}.tar.gz succeed!"
    fi
  else
     quit "${PKG_VER}.tar.gz not exist, download failed! quit"
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
NGINX=${DEPS}/nginx
TSOCKS=

mkdir -p $NGINX
cd $NGINX
echo $NGINX

PCRE_VAR=pcre-8.32
PCRE_URL=http://downloads.sourceforge.net/project/pcre/pcre/8.32/pcre-8.32.tar.gz
#PCRE_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.32.tar.gz 

OPENSSL_VER=openssl-1.0.1c
OPENSSL_URL=http://www.openssl.org/source/openssl-1.0.1c.tar.gz

ZLIB_VER=zlib-1.2.8
ZLIB_URL=http://zlib.net/zlib-1.2.8.tar.gz

NGINX_VER=nginx-1.5.2
NGINX_URL=http://nginx.org/download/nginx-1.5.2.tar.gz


#######################################
FNAME=`basename $0`
MODE=""

if [ "${FNAME}" == "nginx-bootstrap.sh" ]
then
  echo ">Run in script"
  MODE="0"
else
  echo ">Run in shell"
  MODE="1"
  set +H
fi

#######################################
#stop nginx process
if [ ` chkconfig --list nginx | wc -l` -eq 1 ];then
  echo "nginx service is running,try to stop..."
  service nginx stop
fi

if [ `ps -ef  | grep "/usr/sbin/nginx" | grep -v grep | wc -l` -eq 1 ];then
 echo "nginx is running,please stop first!"
 ps -ef  | grep "/usr/sbin/nginx" | grep -v grep
 quit "quit!"
fi

############# install lib #############
yum_install gcc-c++
yum_install openssl 
yum_install openssl-devel
yum_install zlib
yum_install zlib-devel
yum_install pcre
yum_install pcre-devel
yum_install perl
yum_install perl-devel
yum_install perl-ExtUtils-Embed

#############download dependency#############
download_package $PCRE_VAR $PCRE_URL 0
download_package $OPENSSL_VER $OPENSSL_URL 0
download_package $ZLIB_VER $ZLIB_URL 0

############# download nginx#############
echo "VPN_SUPPORT:${VPN_SUPPORT}"
download_package $NGINX_VER $NGINX_URL 0
cd $NGINX_VER


############# download plugins(nginx-upstream-fair,ngx-fancyindex) #############
cd ${NGINX}/${NGINX_VER}
wget --no-check-certificate  https://github.com/gnosek/nginx-upstream-fair/archive/master.zip  -O nginx-upstream-fair-master.zip
if [ ! -f nginx-upstream-fair-master.zip ];then
  rm -rf nginx-upstream-fair-master.zip
  quit "download nginx-upstream-fair  failed,quit"
fi

wget https://github.com/aperezdc/ngx-fancyindex/archive/master.zip -O ngx-fancyindex-master.zip
if [ ! -f ngx-fancyindex-master.zip ];then
  rm -rf ngx-fancyindex-master.zip
  quit "download ngx-fancyindex  failed,quit"
fi


unzip -o nginx-upstream-fair-master.zip
if [ ! -d nginx-upstream-fair-master ];then
  rm -rf nginx-upstream-fair-master.zip
  quit "unzip nginx-upstream-fair-master.zip failed,quit"
fi
rm -rf nginx-upstream-fair
mv nginx-upstream-fair-master nginx-upstream-fair

unzip -o ngx-fancyindex-master.zip
if [ ! -d ngx-fancyindex-master ];then
  quit "untar ngx-fancyindex-master.zip failed,quit"
fi
rm -rf ngx-fancyindex
mv ngx-fancyindex-master ngx-fancyindex


############# compile & install #############
make clean

ARCH=" "
if [ "${HOSTTYPE}" == "x86_64" ]
then  
  ARCH=" "
elif [ "${HOSTTYPE}" == "i686" -o "${HOSTTYPE}" == "i386" ]
then
  ARCH=" -m32 -march=i386 "
else
  quit "configure nginx failed, unknow hosttype ${HOSTYPE}"
fi

#i386: with -m32 -march=i386 
#x86_64: without -m32 -march=i386 

./configure --user=nginx --group=nginx --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -mtune=generic -fasynchronous-unwind-tables'  --add-module=./nginx-upstream-fair --add-module=./ngx-fancyindex --with-pcre=../pcre-8.32 --with-openssl=../openssl-1.0.1c --with-zlib=../${ZLIB_VER}  ${ARCH}
if [ $? -ne 0 ];then
  quit "configure nginx failed,quit"
fi

make 
if [ $? -ne 0 ];then
  quit "make nginx failed,quit"
fi

make install
if [ $? -ne 0 ];then
  quit "make install nginx failed,quit"
fi

############# config #############
#add nginx user##
useradd -s /bin/false nginx

# install nginx pkg
#cd /tmp
#wget http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
#rpm -ivh nginx-release-centos-6-0.el6.ngx.noarch.rpm
#yum_install nginx

#create dir for "nginx http client request body temporary files"
#mkdir -p /var/lib/nginx/tmp/

#add nginx service##
#wget https://raw.github.com/gist/781487 --no-check-certificate -O /etc/init.d/nginx
#if [ ! -f /etc/init.d/nginx ];then
# quit "download nginx service config file failed,quit!"
#fi

yum_install zlib
yum_install pcre
yum_install openssl
yum_install php
yum_install php-fpm
yum_install php-xml
yum_install php-mysql
yum_install php-fpm
yum_install php-mcrypt
yum_install php-devel
yum_install php-pear
yum_install php-gd

chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx off



echo
echo "OK"

#############  end #############

mkdir -p ${MADEIRA}/db/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then 
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
else 
    echo ">user 'InstantForge' already exists"
fi
chown InstantForge -R ${MADEIRA}
chown InstantForge -R /var/log/nginx

chown root:root `which nginx`
chmod 755 `which nginx`
chmod u+s `which nginx`
