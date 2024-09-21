#!/bin/bash

# make sure variables in inventory are set up correctly

if [ -z "$(ansible vps -m ping | grep SUCCESS)" ]; then 
    echo "Failed to ping to remote server"
    echo "Exiting..."
    exit 1
fi 

ansible-playbook ansible/playbooks/00-docker-instl.yml 
ansible-playbook ansible/playbooks/01-clone-deploy.yml
