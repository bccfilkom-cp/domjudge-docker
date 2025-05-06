<div align="center">
<img src="https://www.domjudge.org/DOMjudgelogo.svg" width="100px" style="background-color:white;">
<h1>DOMJudge Docker Deployment</h1>
</div>

DOMJudge Docker Deployment made easy for ubuntu distro.

## ⚙️ How to use

There are two ways how to setup domjudge docker   

#### 1. [✨ Basic Setup](#-basic-setup)   
#### 2. [🔥 Ansible Setup](#-ansible-setup)

### ✨ Basic Setup

Basic setup needs you to install the docker already in the VM that you intend to host as the domserver and judgehost. It expects you to already enable cgroupv2

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
With ansible, everything is fast to the moon and it's all automated. Ansible setup also takes care docker installation and enable cgroup for you! Note that ansible expects your VM OS to be ubuntu.

1. Make the ansible setup script to be executeable
```zsh
chmod +x ansible-setup.sh
```
2. Fill needed variables in [inventory files](./ansible/inventory) including [hosts](./ansible/inventory/hosts.yaml) and [vars](./ansible/inventory/vars.yaml)
2. Run the ansible setup script
```zsh
./ansible-setup.sh
```
3. If you just need to clone and deploy without installing the docker, you can run [deploy playbook](./ansible/playbooks/deploy.yml)
```zsh
cd ansible
ansible-playbook -e @inventory/vars.yaml playbooks/deploy.yml
```

### 💥 Spawn Judgehost Container
To spawn Judgehost containers in different host than the DOMserver host, you can look up [start-judgehost.sh](./start-judgehost.sh) shell script, fill the needed variables and execute it in your local machine or separate machine than the DOMserver machine.

## 📝 NOTES

Please read this notes for further information regarding to deploy DOMJudge docker.

1. Use ```host.docker.internal``` as ```DOMSERVER_IP_ADDR``` in shell script if you want to run the judgehost in the same host as the domserver

2. If the judgehost is running on different host than the domserver, then you can't instantly run the shell script since the script expects you to run judgehost on the same host as the domserver.

3. If judgehost failed to start and the judgehost container logs said auth failed, then you need to change judgehost account password in domjudge jury interface and restart the judgehost container

4. To reset admin's password, you can execute the bellow command
```zsh
docker exec -it domjudge-srv /opt/domjudge/domserver/webapp/bin/console domjudge:reset-user-password admin
```

## License

This project is licensed under the MIT License. See the [`LICENSE`](./LICENSE) file for details.

