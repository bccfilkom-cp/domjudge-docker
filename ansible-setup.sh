#!/bin/bash

# make sure variables in inventory are set up correctly

echo 'Checking remote server...';
if [ -z "$(ansible vps -m ping | grep SUCCESS)" ]; then 
    echo "Failed to ping to remote server"
    echo "Exiting..."
    exit 1
fi 

echo 'Remote server ready!'

echo 'Executing playbook docker-instl';
ansible-playbook ansible/playbooks/00-docker-instl.yml 

echo 'Executing playbook enable-cgroup';
ansible-playbook ansible/playbooks/01-enable-cgroup.yml

echo 'Executing playbook clone-deploy';
ansible-playbook ansible/playbooks/02-clone-deploy.yml
