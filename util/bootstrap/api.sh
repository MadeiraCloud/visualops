
GIT="ssh://root@211.98.26.6/opt/source"
MADEIRA=/madeira
SRC=${MADEIRA}/source

mkdir -p ${SRC}

git clone ${GIT}/api.git ${SRC}/api

# tornado
# redis
# gearman
# mongo
# scribe
# zookeeper
