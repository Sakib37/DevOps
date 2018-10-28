#!/bin/bash

# start etcd across the master nodes
for one in $(vagrant hosts list | grep k8s-server | awk '{print $2}')
do
    echo "starting etcd server on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable etcd.service && systemctl start etcd.service'" ${one} | tee -a logs/${one}-services.log &
done

wait

echo "done starting up etcd"

# check etcd status
vagrant ssh -c "ETCDCTL_API=3 etcdctl --cert=/etc/tls/etcd/k8s-server-1-client.pem --key=/etc/tls/etcd/k8s-server-1-client-key.pem member list" k8s-server-1

wait

# start kubernetes apiservers across the master nodes
for one in $(vagrant hosts list | grep k8s-server | awk '{print $2}')
do
    echo "starting kubernetes apiserver on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable kube-apiserver.service && systemctl start kube-apiserver.service'" ${one} | tee -a logs/${one}-services.log &
    echo ""
done

wait

echo "done starting up kubernetes api servers"

# start kubernetes controller managers across the master nodes
for one in $(vagrant hosts list | grep k8s-server | awk '{print $2}')
do
    echo "starting kubernetes controller manager on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable kube-controller-manager.service && systemctl start kube-controller-manager.service'" ${one} | tee -a logs/${one}-services.log &
    echo ""
done

wait

echo "done starting up kubernetes controller managers"

# start kubernetes schedulers across the master nodes
for one in $(vagrant hosts list | grep k8s-server | awk '{print $2}')
do
    echo "starting kubernetes scheduler on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable kube-scheduler.service && systemctl start kube-scheduler.service'" ${one} | tee -a logs/${one}-services.log &
    echo ""
done

wait

echo "done starting up kubernetes schedulers"