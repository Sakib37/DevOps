#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install prometheus operator
kubectl apply -f manifests/operators/prometheus/prometheus-operator.yaml | tee -a logs/manifests.log

# install etcd operator
./manifests/operators/etcd/rbac/create_role.sh
kubectl apply -f manifests/operators/etcd/rbac/cluster-role.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/operators/etcd/rbac/cluster-role-binding.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/operators/etcd/etcd-operator.yaml | tee -a logs/manifests.log

# install vault operator
#kubectl apply -f manifests/operators/vault/vault-operator.yaml | tee -a logs/manifests.log

# install rook operator
kubectl apply -f manifests/operators/rook/rook-operator.yaml | tee -a logs/manifests.log

# install mysql operator
kubectl apply -f manifests/operators/mysql/mysql-operator.yaml | tee -a logs/manifests.log

sleep 120
