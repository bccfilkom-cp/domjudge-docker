<div align="center">
<img src="https://www.domjudge.org/DOMjudgelogo.svg" width="100px" style="background-color:white;">
<h1>DOMJudge Docker Config</h1>
</div>

## ⚙️ How to use

There are two ways how to setup domjudge docker   

1. [✨ Basic Setup](#-basic-setup)   
2. [🔥 Ansible Setup](#-ansible-setup)

### ✨ Basic Setup

Basic setup needs you to install the docker already in the vps or the machine that you intend to host as the domserver and judgehost and also needs you to enable the cgroup already

1. Clone this repository
```zsh
https://github.com/bccfilkom-cp/domjudge-docker.git #https
git@github.com:bccfilkom-cp/domjudge-docker.git #ssh
```

2. Copy the environment files
```zsh
cp .env.example .env
cp .db.env.example .db.env  
```

3. Configure the environment variables in those files

4. Make the shell script to be executeable by running this command

```zsh
chmod +x prepare-contest-env.sh
```

5. Fill needed variables in the shell script

6. Run the shell script
```zsh
./prepare-contest-env.sh
```
### 🔥 Ansible Setup
With ansible, everything is fast to the moon and it's all automated. Ansible setup also takes care docker installation and enable cgroup for you!

1. Make the ansible setup script to be executeable
```zsh
chmod +x ansible-setup.sh
```
2. Fill needed variables in [inventory file](./ansible/inventory)
2. Run the ansible setup script
```zsh
./ansible-setup.sh
```
3. If you just need to clone and deploy without installing the docker, you can run playbook ```clone and deploy```
```zsh
ansible-playbook ansible/playbooks/02-clone-deploy.yml
```

## 📝 NOTES
1. Use ```host.docker.internal``` as ```DOMSERVER_IP_ADDR``` in shell script if you want to run the judgehost in the same host as the domserver

2. If the judgehost is running on different host than the domserver, then you can't instantly run the shell script since the script expects you to run judgehost on the same host as the domserver.

3. If judgehost failed to start and the judgehost container logs said auth failed, then you need to change judgehost account password in domjudge jury interface and restart the judgehost container

4. To reset admin's password, you can execute the bellow command
```zsh
docker exec -it YOUR_DOMSERVER_CONTAINER_NAME /opt/domjudge/domserver/webapp/bin/console domjudge:reset-user-password admin
```

