#!/bin/bash

# Needed variables
DOMSERVER_IP_ADDR=
DOMSERVER_PORT=
NUM_OF_JUDGEHOSTS=                                                                                                              
DOCKER_JUDGEHOST_NETWORK=
JUDGE_USER=
JUDGE_PASS=

# Run this on separate host than DOMserver
for ((i=0;i < $NUM_OF_JUDGEHOSTS; i++))
do
    echo "Creating dj_judgehost-$i"

    docker create --privileged \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    --link domserver:domserver \
    --name dj_judgehost-$i --hostname judgedaemon-$i \
    --add-host "host.docker.internal:host-gateway" \
    -e DAEMON_ID=$i --network "$DOCKER_JUDGEHOST_NETWORK" \
    -e CONTAINER_TIMEZONE=Asia/Jakarta \
    -e DOMSERVER_BASEURL=http://"$DOMSERVER_IP_ADDR":"$DOMSERVER_PORT"/ \
    -e JUDGEDAEMON_USERNAME="$JUDGE_USER" \
    -e JUDGEDAEMON_PASSWORD="$JUDGE_PASS"\
    domjudge/judgehost

    docker start dj_judgehost-$i;
done                                                       