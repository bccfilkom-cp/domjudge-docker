#!/bin/sh

# Needed variables
DOMSERVER_IP_ADDR=host.docker.internal
DOMSERVER_PORT=80
DOMSERVER_COMPOSE_DIR=Documents/Uni/Organisasi/BCC/projects/domjudge-docker
NUM_OF_JUDGEHOSTS=2
DOCKER_JUDGEHOST_NETWORK=judgehostnet

# Start DOMserver Docker Compose
echo 'Starting DOMserver Docker Compose...';
cd $HOME/$DOMSERVER_COMPOSE_DIR;
docker compose up -d;

if [ "$(docker container ls | grep -c Up)" -ge 2 ]; then 
    echo 'DOMServer and MariaDB container is up already!';
else 
    echo 'Failed to start containers'; 
    exit 1;
fi

# Getting Judgehost Password
echo 'Getting judgehost password from domserver restapi.secret';
JD_PWD=$(docker exec -it domjudge-docker-domjudge-1 cat /opt/domjudge/domserver/etc/restapi.secret \
| grep default \
| awk '{print $NF}')

echo "Judgehost Password: $JD_PWD"
echo "If judgehost auth failed while registering endpoint, please update judgehost password in domjudge jury interface"

# Remove existing container
echo 'Removing existing DOMjudge judgehost daemon container...';
for ((i=0;i < $NUM_OF_JUDGEHOSTS; i++))
do
    docker rm -f dj_judgehost-$i;
done 

# Creating judgehost docker network
echo 'Creating judgehost docker network...';
docker network create -d bridge $DOCKER_JUDGEHOST_NETWORK

# Create container
echo 'Creating new DOMjudge judgehosts daemon containers...';

# If judgehost is running in the same host as domserver
# You can keep the --add-host flag and use host.docker.internal as DOMSERVER_IP_ADDR
# Otherwise, remove the flag and use the vps ip addr as DOMSERVER_IP_ADDR
for ((i=0;i < $NUM_OF_JUDGEHOSTS; i++))
do
    docker create --privileged \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    --link domserver:domserver \
    --name dj_judgehost-$i --hostname judgedaemon-$i \
    --add-host "host.docker.internal:host-gateway" \
    -e DAEMON_ID=$i --network $DOCKER_JUDGEHOST_NETWORK \
    -e CONTAINER_TIMEZONE=Asia/Jakarta \
    -e DOMSERVER_BASEURL=http://${DOMSERVER_IP_ADDR}:${DOMSERVER_PORT}/ \
    -e JUDGEDAEMON_PASSWORD=${JD_PWD}\
    domjudge/judgehost;
done 


# Start judgehost container
echo 'Waiting for DOMserver for being ready to request...';

# Changing domserver_ip_addr to localhost if domserver_ip_addr is host.docker.internal
if [ "$DOMSERVER_IP_ADDR" == "host.docker.internal" ]; then 
	DOMSERVER_IP_ADDR=localhost
fi 

echo "Sending curl request to http://$DOMSERVER_IP_ADDR:$DOMSERVER_PORT/public"

STAT_CODE=$(curl http://${DOMSERVER_IP_ADDR}:${DOMSERVER_PORT}/public -o /dev/null \
    -s -I -w "%{http_code}\n");
while [ $STAT_CODE -ne 200 ]; do
    sleep 1;
    STAT_CODE=$(curl http://${DOMSERVER_IP_ADDR}:${DOMSERVER_PORT}/public -o /dev/null \
        -s -I -w "%{http_code}\n");
done

echo 'Starting judgehosts container...';
for ((i=0;i < $NUM_OF_JUDGEHOSTS; i++))
do
    docker start dj_judgehost-$i;
done

WAIT_TIME=2
echo "Waiting to check judgehost containers"
sleep $WAIT_TIME

echo "Checking judgehost containers";

# Check if judgehost container is up or not
if [ -n "$(docker container ls | grep judgehost)" ]; then 
	echo 'Judgehost containers is up already! 🥳'
else  
	echo "Failed to start judgehost containers 😔"
	echo "Try to check judgehost container logs to see and identify the error"
fi 