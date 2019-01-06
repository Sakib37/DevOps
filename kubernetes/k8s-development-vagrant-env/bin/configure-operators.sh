#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install prometheus operator
kubectl apply -f manifests/operators/prometheus/prometheus-operator.yaml | tee -a logs/manifests.log

# install etcd operator
#./manifests/operators/etcd/rbac/create_role.sh
#kubectl apply -f manifests/operators/etcd/rbac/cluster-role.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/operators/etcd/rbac/cluster-role-binding.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/operators/etcd/etcd-operator.yaml | tee -a logs/manifests.log

# install vault operator
#kubectl apply -f manifests/operators/vault/vault-operator.yaml | tee -a logs/manifests.log

# install rook operator
#kubectl apply -f manifests/operators/rook/rook-operator.yaml | tee -a logs/manifests.log

kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
kubectl --namespace kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
helm repo add rook-stable https://charts.rook.io/stable
helm install --namespace rook-ceph-system rook-stable/rook-ceph --name rook-ceph

# install mysql operator
#kubectl apply -f manifests/operators/mysql/mysql-operator.yaml | tee -a logs/manifests.log

sleep 120
