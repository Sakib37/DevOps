#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install weavenet for container networking but switch off the network policy controller (weave-npc)
kubectl apply -f manifests/networking/weavenet/ | tee -a logs/manifests.log
sleep 60

# install kubedns for cluster dns
kubectl apply -f manifests/networking/dns/ | tee -a logs/manifests.log
sleep 30

# install kube-router in firewall mode to provide a complete implementation of kubernetes network policies
#kubectl apply -f manifests/networking/kube-router/ | tee -a logs/manifests.log
sleep 30
