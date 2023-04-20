#!/bin/sh

# Needed variables
DOMSERVER_IP_ADDR={domserver_ip_address}
JD_PWD={put_account_judgehost_password}
DOMSERVER_PORT={your_domserver_port}

# Start DOMserver Docker Compose
echo 'Starting DOMserver Docker Compose...';
# cd $HOME/bcc_cp;
# docker compose start;

# Remove existing container
echo 'Removing existing DOMjudge judgehost daemon container...';
# docker rm -f dj_judgehost-0;

# Create container
echo 'Creating new DOMjudge judgehost daemon containers...';
docker create --privileged \
-v /sys/fs/cgroup:/sys/fs/cgroup \
--name dj_judgehost-0 --hostname judgedaemon-0 \
-e DAEMON_ID=0 --network bcc_cp_default \
-e CONTAINER_TIMEZONE=Asia/Jakarta \
-e DOMSERVER_BASEURL=http://${DOMSERVER_IP_ADDR}:${DOMSERVER_PORT}/ \
-e JUDGEDAEMON_PASSWORD=${JD_PWD}\
domjudge/judgehost;

# Start judgehost container
echo 'Waiting for DOMserver for being ready to request...';

STAT_CODE=$(curl http://${DOMSERVER_IP_ADDR}:55555/public -o /dev/null \
	-s -I -w "%{http_code}\n");
while [ $STAT_CODE -ne 200 ]; do
	sleep 1;
	STAT_CODE=$(curl http://${DOMSERVER_IP_ADDR}:55555/public -o /dev/null \
		-s -I -w "%{http_code}\n");
done

echo 'Starting judgehost container...';
docker start dj_judgehost-0;

