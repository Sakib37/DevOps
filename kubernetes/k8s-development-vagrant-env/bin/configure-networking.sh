#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install weavenet for container networking but switch off the network policy controller (weave-npc)
# source: https://www.weave.works/blog/weave-net-kubernetes-integration/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" | tee -a logs/manifests.log
sleep 60

# install core-dns for cluster dns
kubectl apply -f manifests/networking/dns/core-dns.yaml | tee -a logs/manifests.log
sleep 30

# install kube-router in firewall mode to provide a complete implementation of kubernetes network policies
#kubectl apply -f manifests/networking/kube-router/ | tee -a logs/manifests.log
#sleep 30
