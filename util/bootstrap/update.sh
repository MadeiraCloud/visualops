#!/bin/bash
##
## Update script
## By Thibault BRONCHAIN for MadeiraCloud
##

######################
# GLOBAL DEFINITIONS #
######################

CURRENT=${PWD}

IDE_PATH="/data/release/beta/ide"
IDE_FILE="pugna-latest.7z"

GIT="root@211.98.26.6"
SGIT="ssh://${GIT}/opt/source"
GIT_SSH="${CURRENT}/git.ssh.sh"

LOC=/
MADEIRASRC=madeira
MADEIRA="${LOC}${MADEIRASRC}"
SRC=${MADEIRA}/source
SOURCES=(api devops dns docs ide monitor web)

BRANCH=master


#############
# FUNCTIONS #
#############

function update_ide() {
    # deploy ide
    cd ${MADEIRA}/site
    rm -rf ide.*
    mkdir -p ide.tmp
    cd ide.tmp
    scp ${GIT}:${IDE_PATH}/${IDE_FILE} ./
    if [ -f ${IDE_FILE} ]; then
	7za x ${IDE_FILE}
	cd ..
	cp www/favicon.ico ide.tmp
	chmod u+x -R ide.tmp ; chown InstantForge:InstantForge -R ide.tmp
	mv ide ide.bak; mv ide.tmp ide
    fi
}

function git_get() {
    mkdir -p "${1}/${2}"
    if [ ! -d "${1}/${2}/.git" ] ; then
	git clone "${SGIT}/${2}.git" "${1}/${2}"
    else
	cd "${1}/${2}" && git pull
    fi

    cd "${1}/${2}"
    git checkout ${3}
    cd -
}

function git_key() {
    KEY="/root/.ssh/keys/git"
    SSH_FILE="/tmp/git_ssh.sh"
    if [ -f ${KEY} ]; then
	echo '#!/bin/bash' > ${SSH_FILE}
	echo 'exec /usr/bin/ssh -i /root/.ssh/keys/git "$@"' >> ${SSH_FILE}
	chmod +x ${SSH_FILE}
	export GIT_SSH="${SSH_FILE}"
    fi
}


########
# MAIN #
########

cd ${LOC}
git_key
git_get ${LOC} ${MADEIRASRC} ${BRANCH}

for S in "${SOURCES[@]}"
do
    git_get ${SRC} ${S} ${BRANCH}
    if [ ${S} == "ide" ]; then
	update_ide
    fi
done
