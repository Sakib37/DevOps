#!/bin/bash

export SSH_CONFIG_DIR=.vagrant/ssh-config
mkdir -p ${SSH_CONFIG_DIR}


# start kubernetes master services
for one in $(vagrant hosts list | grep k8s-server | awk '{print $2}')
do
    echo "generating ssh config for ${one}"
    vagrant ssh-config ${one} > ${SSH_CONFIG_DIR}/.${one}-ssh-config

    echo "starting kubernetes master services on ${one}"
    ssh -F ${SSH_CONFIG_DIR}/.${one}-ssh-config ${one} '/vagrant/bin/startup-kubernetes-masters.sh' | tee -a logs/${one}-services.log &
done

wait

echo "done starting kubernetes master services"

# start kubernetes worker services
for one in $(vagrant hosts list | grep k8s-node | awk '{print $2}')
do
   echo "generating ssh config for ${one}"
   vagrant ssh-config ${one} > ${SSH_CONFIG_DIR}/.${one}-ssh-config

   echo "starting kubernetes worker services on ${one}"
   ssh -F ${SSH_CONFIG_DIR}/.${one}-ssh-config ${one} '/vagrant/bin/startup-kubernetes-workers.sh' | tee -a logs/${one}-services.log &
done

wait

echo "done starting kubernetes worker services"

rm -rf ${SSH_CONFIG_DIR}

echo "waiting for kubernetes api refresh to succeed..."
sleep 10
echo "...kubernetes api refresh probably done"