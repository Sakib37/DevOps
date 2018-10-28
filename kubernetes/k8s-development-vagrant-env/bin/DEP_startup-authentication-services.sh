#!/bin/bash

# start dex on the k8s-auth nodes
for one in $(vagrant hosts list | grep k8s-auth | awk '{print $2}')
do
    echo "starting dex on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable dex.service && systemctl start dex.service'" ${one} | tee -a logs/${one}-services.log &
done

wait