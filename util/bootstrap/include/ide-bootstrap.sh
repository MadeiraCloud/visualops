MADEIRA=/madeira
GIT="root@211.98.26.6"
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site

mkdir -p ${SITE}/ide

# IDE
cd ${SITE}/ide/
git clone ssh://${GIT}//opt/source/ide.git
