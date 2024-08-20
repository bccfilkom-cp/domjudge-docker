<div align="center">
<img src="https://www.domjudge.org/DOMjudgelogo.svg" width="100px" style="background-color:white;">
<h1>DOMJudge Docker Config</h1>
</div>

## ⚙️ How to use

1. Copy the environment files
```zsh
cp .env.example .env
cp .db.env.example .db.env  
```

2. Configure the environment variables in those files

3. Make the shell script to be executeable by running this command

```zsh
chmod +x prepare-contest-env.sh
```

4. Fill needed variables in the shell script

5. Run the shell script
```zsh
./prepare-contest-env.sh
```

## 📝 NOTES
1. Use ```host.docker.internal``` as ```DOMSERVER_IP_ADDR``` in shell script if you intend to run the judgehost in the same host as the domserver

2. If the judgehost is running on different host than the domserver, then you can't instantly run the shell script since the script expects you to run judgehost on the same host as the domserver.

3. If judgehost failed to start and the container logs said auth failed, then you need to change judgehost account password in domjudge jury interface and restart the judgehost container

4. To reset admin's password, you can execute the bellow command
```zsh
docker exec -it YOUR_DOMSERVER_CONTAINER_NAME /opt/domjudge/domserver/webapp/bin/console domjudge:reset-user-password admin
```
