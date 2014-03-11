MADEIRA=/madeira
HG="root@211.98.26.6"
CONF=${MADEIRA}/conf
DB=${MADEIRA}/db
DEPS=${MADEIRA}/deps
SRC=${MADEIRA}/source
LOG=${MADEIRA}/log
SITE=${MADEIRA}/site


# Agent Server
mkdir -p ${SITE}/api/
cd ${SITE}/api/
mkdir -p ${SITE}/api/monitor
git clone ssh://${HG}//opt/source/monitor.git
cp ${SITE}/api/monitor/Source/AgentServer/Frequent_Action.php ${SITE}/api/monitor/index.php
cp ${SITE}/api/monitor/Source/AgentServer/Action.php ${SITE}/api/monitor/Action.php
cp ${SITE}/api/monitor/Source/Agent/Agent.sh ${SITE}/api/monitor/Agent.sh

mkdir -p ${MADEIRA}/db/journal
if [ `cat /etc/passwd | grep ^InstantForge | wc -l` -eq 0 ]
then
    useradd -s /sbin/nologin -d ${MADEIRA} -M InstantForge
    chown InstantForge -R ${MADEIRA}
else
    echo ">user 'InstantForge' already exists"
fi
