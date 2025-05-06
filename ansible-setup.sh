#!/bin/bash

# make sure variables in inventory are set up correctly
cd ansible 
echo 'Checking remote server...';
if [ -z "$(ansible all -m ping | grep SUCCESS)" ]; then 
    echo "Failed to ping to remote server";
    echo "Exiting...";
    exit 1;
fi 

echo -e "\033[1;35m>>> REMOTE SERVER READY! <<<\033[0m"
echo -e "\033[1;36m>>> Starting Provision Playbook <<<\033[0m"
ansible-playbook playbooks/provision.yml

echo -e "\033[1;36m>>> Starting Deploy Playbook <<<\033[0m"
ansible-playbook -e @inventory/vars.yaml playbooks/deploy.yml -v | tee >(grep "New password for admin")
