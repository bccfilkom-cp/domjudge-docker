#!/bin/bash

# Needed variables
DOMSERVER_IP_ADDR={domserver_ip_address}
DOMSERVER_IP_CURL={domserver_ip_curl}
DOMSERVER_PORT={domserver_port}
NUM_OF_JUDGEHOSTS={num_of_judgehosts_needed}
DOCKER_JUDGEHOST_NETWORK={docker_judgehost_network}

start_domserver() {
    if [ ! -z "$(docker container ls | grep domjudge-srv)" ] || [ ! -z "$(docker container ls | grep domjudge-db)" ]; then
        echo "Container is already running"
        echo "Stopping container temporarily"
        docker compose down
    fi

    # Start DOMserver Docker Compose
    # Assuming you are running the shell script in the same dir as docker compose configuration file
    echo 'Starting DOMserver Docker Compose...';
    docker compose up -d;

    # Waiting for DOMServer
    echo 'Waiting for DOMServer...';
    sleep 10

    # Resetting Admin Password
    echo 'Reseting admin password...';
    echo 'Username: admin'
    docker exec -it domjudge-srv /opt/domjudge/domserver/webapp/bin/console domjudge:reset-user-password admin
}

create_judgehosts() {
    # Resetting Judgehost Passowrd
    JD_PWD=$(docker exec -it domjudge-srv /opt/domjudge/domserver/webapp/bin/console domjudge:reset-user-password judgehost | grep is | sed 's/.* is //' | tr -d '\r')

    JD_PWD=${JD_PWD%% *}

    echo "Judgehost Password: $JD_PWD";

    # Remove existing container
    echo 'Removing existing DOMjudge judgehost daemon container...';
    for ((i=0;i < NUM_OF_JUDGEHOSTS; i++))
    do
        docker rm -f "dj_judgehost-$i";
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
        echo "Creating dj_judgehost-$i"

        docker create --privileged \
        -v /sys/fs/cgroup:/sys/fs/cgroup \
        --link domserver:domserver \
        --name dj_judgehost-$i --hostname judgedaemon-$i \
        --add-host "host.docker.internal:host-gateway" \
        -e DAEMON_ID=$i --network "$DOCKER_JUDGEHOST_NETWORK" \
        -e CONTAINER_TIMEZONE=Asia/Jakarta \
        -e DOMSERVER_BASEURL=http://"$DOMSERVER_IP_ADDR":"$DOMSERVER_PORT"/ \
        -e JUDGEDAEMON_PASSWORD="$JD_PWD"\
        domjudge/judgehost
    done 
}

checking_domserver() {
    echo 'Waiting for DOMserver for being ready to request...';

    echo "Sending curl request to http://$DOMSERVER_IP_CURL:$DOMSERVER_PORT/public"

    STAT_CODE=$(curl http://${DOMSERVER_IP_CURL}:${DOMSERVER_PORT}/public -o /dev/null \
        -s -I -w "%{http_code}\n");
    while [ $STAT_CODE -ne 200 ]; do
        sleep 1;
        STAT_CODE=$(curl http://${DOMSERVER_IP_CURL}:${DOMSERVER_PORT}/public -o /dev/null \
            -s -I -w "%{http_code}\n");
    done

    echo "DOMserver ready!"
}

start_judgehosts() {
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
}

# dont change the orders
start_domserver
create_judgehosts
checking_domserver
start_judgehosts
