#!/bin/bash


sudo -E -s -- <<"EOF"
systemctl daemon-reload

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