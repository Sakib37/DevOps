#!/bin/bash


sudo -E -s -- <<"EOF"

source /etc/environment
systemctl daemon-reload

# start etcd

echo "starting up etcd"
systemctl enable etcd.service
systemctl start etcd.service
echo "done"

echo "Waiting for the ETCD service to be running ..."
sleep 5

echo "checking etcd status"
#etcdctl --cert=${CFSSL_TLS_GUEST_FOLDER}/etcd/k8s-server-1-client.pem --key=${CFSSL_TLS_GUEST_FOLDER}/etcd/k8s-server-1-client-key.pem member list
etcdctl member list
echo "done"


# start kubernetes apiserver
echo "starting up kubernetes apiserver"
systemctl enable kube-apiserver.service
systemctl start kube-apiserver.service
echo "done"

while ! nc -z localhost 6443;
do
    echo "Waiting for api-server to be ready" ;
    sleep 5;
done

# start kubernetes controller manager
echo "starting up kubernetes controller manager"
systemctl enable kube-controller-manager.service
systemctl start kube-controller-manager.service
echo "done"

# start kubernetes scheduler
echo "starting up kubernetes scheduler"
systemctl enable kube-scheduler.service
systemctl start kube-scheduler.service
echo "done"

# start docker runtime
echo "starting up docker"
systemctl enable docker.service
systemctl start docker.service
echo "done"

# start kubernetes kubelet
echo "starting up kubernetes kubelet"
systemctl enable kubelet.service
systemctl start kubelet.service
echo "done"


# start kubernetes kube-proxy
echo "starting up kubernetes kube-proxy"
systemctl enable kube-proxy.service
systemctl start kube-proxy.service
echo "done"

EOF