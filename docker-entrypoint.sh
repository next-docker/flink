#!/bin/sh

### If unspecified, the hostname of the container is taken as the JobManager address
JOB_MANAGER_RPC_ADDRESS=${JOB_MANAGER_RPC_ADDRESS:-$(hostname -f)}
JOB_MANAGER_RPC_PORT=${JOB_MANAGER_RPC_PORT:-6123}
JOB_MANAGER_WEB_PORT=${JOB_MANAGER_WEB_PORT:-8081}
JOB_MANAGER_HEAP_MB=${JOB_MANAGER_HEAP_MB:-1025}
JOB_MANAGER_WEB_SUBMIT_ENABLED=${JOB_MANAGER_WEB_SUBMIT_ENABLED:-true}
TASK_MANAGER_TASK_SLOTS=${TASK_MANAGER_TASK_SLOTS:-$(grep -c ^processor /proc/cpuinfo)}
TASK_MANAGER_HEAP_MB=${TASK_MANAGER_HEAP_MB:-2049}
###
echo JOB_MANAGER_RPC_ADDRESS=$JOB_MANAGER_RPC_ADDRESS
echo JOB_MANAGER_RPC_PORT=$JOB_MANAGER_RPC_PORT
echo JOB_MANAGER_WEB_PORT=$JOB_MANAGER_WEB_PORT
echo JOB_MANAGER_HEAP_MB=$JOB_MANAGER_HEAP_MB
echo JOB_MANAGER_WEB_SUBMIT_ENABLED=$JOB_MANAGER_WEB_SUBMIT_ENABLED
echo TASK_MANAGER_TASK_SLOTS=$TASK_MANAGER_TASK_SLOTS
echo TASK_MANAGER_HEAP_MB=$TASK_MANAGER_HEAP_MB
echo Running : $1

ls -lrt  /etc/init.d/
/etc/init.d/ssh start

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "Usage: $(basename $0) (jobmanager|taskmanager)"
    exit 0
elif [ "$1" = "jobmanager" ]; then
    echo "Starting Job Manager"
    sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/jobmanager.rpc.port: 6123/jobmanager.rpc.port: ${JOB_MANAGER_RPC_PORT}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/jobmanager.web.port: 8081/jobmanager.web.port: ${JOB_MANAGER_WEB_PORT}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/jobmanager.heap.mb: 256/jobmanager.heap.mb: ${JOB_MANAGER_HEAP_MB}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/#jobmanager.web.submit.enable: false/jobmanager.web.submit.enable: ${JOB_MANAGER_WEB_SUBMIT_ENABLED}/g" $FLINK_HOME/conf/flink-conf.yaml

    echo "config file: " && grep '^[^\n#]' $FLINK_HOME/conf/flink-conf.yaml
    exec $FLINK_HOME/bin/jobmanager.sh start-foreground cluster
elif [ "$1" = "taskmanager" ]; then

    sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: ${TASK_MANAGER_TASK_SLOTS}/g" $FLINK_HOME/conf/flink-conf.yaml
    sed -i -e "s/taskmanager.heap.mb: 512/taskmanager.heap.mb: ${TASK_MANAGER_HEAP_MB}/g" $FLINK_HOME/conf/flink-conf.yaml

    echo "Starting Task Manager"
    echo "config file: " && grep '^[^\n#]' $FLINK_HOME/conf/flink-conf.yaml
    exec $FLINK_HOME/bin/taskmanager.sh start-foreground
fi

exec "$@"
