#!/bin/bash
##
## Deployment script
## By Thibault BRONCHAIN for MadeiraCloud
##


######################
# GLOBAL DEFINITIONS #
######################

CURRENT=${PWD}

GIT="root@211.98.26.6"
MADEIRA=/madeira
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site
UTIL=${MADEIRA}/util
DIR=${UTIL}/bootstrap
API=${DIR}/backend
FRONT=${DIR}/frontend
INC=${DIR}/include

SGIT="ssh://${GIT}/opt/source"
SAPI=api
SDEVOPS=devops
SDNS=dns
SDOCS=docs
SIDE=ide
SMONITOR=monitor
SWEB=web

MARK="/tmp/madeira.mark.d"


#################
# SIDE FUNTIONS #
#################

function delete_marks() {
    rm -rf ${MARK}
}

function add_once() {
    cd ${DIR}
    source $1/$2 $3
    touch "${MARK}/${2}.mark"
    cd ${DIR}
}

function del_startup() {
    for service in "$@" ; do
	chkconfig $service off
    done
}

function stop_services() {
    for service in "$@" ; do
	killall -9 $service
    done
}

function git_init() {
    if [ -f "${MARK}/${1}.git.mark" ] ; then
	return
    fi
    mkdir -p "${SRC}/${1}"
    if [ ! -d "${SRC}/${1}/.git" ] ; then
	git clone "${SGIT}/${1}.git" "${SRC}/${1}"
    else
	cd "${SRC}/${1}" && git pull
    fi
    touch "${MARK}/${1}.git.mark"
    cd "${SRC}/${1}"
    git checkout ${2}
    cd -
}

###################
# ACTION FUNTIONS #
###################

function deploy_api() {
    # init and clone
    git_init ${SAPI} ${1}

    # setup
    if [ `which thrift | wc -l` -eq 0 ] ; then
	add_once ${INC} thrift-bootstrap.sh
    fi
    add_once ${API} mongodb-bootstrap.sh rock
    add_once ${API} zookeeper-bootstrap.sh
    add_once ${API} scribe-bootstrap.sh
    add_once ${API} redis-bootstrap.sh
    add_once ${API} gearmand-bootstrap.sh
    add_once ${API} karajan-bootstrap.sh
    add_once ${API} requestworker-bootstrap.sh
    add_once ${API} appservice-bootstrap.sh # install tornado

    # remove startup process
    stop_services mongod
    del_startup mongod
}

function deploy_ide() {
    # init and clone
    git_init ${SIDE} ${1}

    # deploy ide
    cd ${MADEIRA}/site
    rm -rf ide.*
    mkdir -p ide.tmp
    cd ide.tmp
    scp ${GIT}:/data/release/beta/ide/pugna-latest.7z .
    if [ ! -f pugna-latest.7z ] ; then
	scp root@211.98.26.6:/data/release/beta/ide/pugna-latest.7z .
    fi
    7za x pugna-latest.7z
    cd ..
    cp www/favicon.ico ide.tmp
    chmod u+x -R ide.tmp ; chown InstantForge:InstantForge -R ide.tmp
    mv ide ide.bak; mv ide.tmp ide

    # setup
    add_once ${API} nginx-bootstrap.sh

    # remove startup process
    stop_services nginx
    del_startup nginx
}

function deploy_monitor() {
    # init and clone
    git_init ${SMONITOR} ${1}

    # setup
    add_once ${API} nginx-bootstrap.sh
    add_once ${API} mysql-bootstrap.sh
    add_once ${FRONT} monitor-bootstrap.sh

    # remove startup process
    stop_services nginx mysqld
    del_startup nginx mysqld
}

function deploy_web() {
    # init and clone
    git_init ${SWEB} ${1}

    # setup
    add_once ${API} nginx-bootstrap.sh
    add_once ${API} mysql-bootstrap.sh
    add_once ${FRONT} mywww-bootstrap.sh

    # remove startup process
    stop_services nginx mysqld
    del_startup nginx mysqld
}

function deploy_all() {
    # init and clone
    git_init ${SAPI} ${1}
    git_init ${SIDE} ${1}
    git_init ${SMONITOR} ${1}
    git_init ${SWEB} ${1}

    deploy_api ${1}
    deploy_ide ${1}
    deploy_monitor ${1}
    deploy_web ${1}
}


#################
# OPTION PARSER #
#################

case "$1" in
    'api')
	echo "Deploying API services"
	sleep 1
	action='deploy_api'
	;;
    'ide')
	echo "Deploying IDE services"
	sleep 1
	action='deploy_ide'
	;;
    'monitor')
	echo "Deploying monitoring services"
	sleep 1
	action='deploy_api'
	;;
    'global' | 'www' | 'my' | 'web')
	echo "Deploying global services"
	sleep 1
	action='deploy_web'
	;;
    'all')
	echo "Deploying all services"
	sleep 1
	action='deploy_all'
	;;
    *)
	echo "Syntax error."
	echo "Usage: $0 {api,ide,monitor,global|www|my|web,all} [branch]"
	exit 1
	;;
esac


################
# INIT ACTIONS #
################

# remove old marks
delete_marks

# ensure directories
mkdir -p ${MADEIRA}
mkdir -p ${CONF}
mkdir -p ${DB}
mkdir -p ${DEPS}
mkdir -p ${SRC}
mkdir -p ${LOG}
mkdir -p ${SITE}
mkdir -p ${MARK}


#############
# EXECUTION #
#############

# include common stuff
add_once ${INC} common-bootstrap.sh
add_once ${INC} init-bootstrap.sh
add_once ${INC} boost-bootstrap.sh

# main execution
if [ -n $2 ] ; then
    branch=${2}
else
    branch="master"
fi

$action ${branch}


###############
# END ACTIONS #
###############

# comon end
add_once ${DIR}/supervisord supervisord-bootstrap.sh

# launch
supervisorctl shutdown all
sleep 1
supervisord -c ${CONF}/supervisord.conf
sleep 15
supervisorctl status
echo "status at 15sec from beginning, press y to wait one more minute, any key to finish"
read check
if [ $check == "y" ] ; then
    sleep 60
    supervisorctl status
fi

# remove created marks
delete_marks
echo "Done."
