#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# install cert manager
kubectl apply -f manifests/security/cert-manager/cert-manager.yaml | tee -a logs/manifests.log

# install vault etcd cluster
kubectl apply -f manifests/security/etcd/etcd.yaml | tee -a logs/manifests.log
sleep 60

# install vault cluster
kubectl apply -f manifests/security/vault/vault.yaml | tee -a logs/manifests.log

# install goldfish vault ui
kubectl apply -f manifests/security/goldfish/goldfish.yaml | tee -a logs/manifests.log
sleep 60