#!/bin/bash
##
## Deployment init script
## By Thibault BRONCHAIN for MadeiraCloud
##

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

SGIT="ssh://root@211.98.26.6/opt/source"
MADEIRA="/madeira"
UTILS="${MADEIRA}/util/bootstrap"
SETUP="deploy.sh"
PKG="git emacs-nox"

if [ $# -eq 0 ]; then
    echo "Syntax error"
    echo "Usage: $0 {api,ide,monitor,global|www|my|web,all} [branch]"
    exit
fi

git_key
yum -y install ${PKG}
if [ ! -d "${MADEIRA}/.git" ] ; then
    git clone "${SGIT}/${MADEIRA}.git" "${MADEIRA}"
else
    cd "${MADEIRA}" && git pull
fi
cd ${UTILS}
. ${SETUP} $1 $2
