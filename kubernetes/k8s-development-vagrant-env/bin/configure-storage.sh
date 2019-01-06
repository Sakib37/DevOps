#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# install ceph operator
kubectl apply -f manifests/storage/rook/cluster/ceph-operator.yaml | tee -a logs/manifests.log
sleep 60

# install rook cluster
kubectl apply -f manifests/storage/rook/cluster/rook-cluster.yaml | tee -a logs/manifests.log
sleep 30

# install ceph pool
kubectl apply -f manifests/storage/rook/cluster/ceph-pool.yaml | tee -a logs/manifests.log
#sleep 60



# install rook storage class into kubernetes
kubectl apply -f manifests/storage/rook/cluster/rook-storageclass.yaml | tee -a logs/manifests.log

# install rook tools
#kubectl apply -f manifests/storage/rook/cluster/rook-toolbox.yaml | tee -a logs/manifests.log

# install rook prometheus' monitoring stack
kubectl apply -f manifests/storage/rook/monitoring/prometheus/prometheus.yaml | tee -a logs/manifests.log
sleep 30

## Install Various file systems for the teams

#kubectl apply -f manifests/deployments/production/storage/ | tee -a logs/manifests.log
sleep 60


#kubectl delete -f manifests/storage/rook/monitoring/prometheus/prometheus.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-tools.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-storageclass.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-cluster.yaml
#kubectl delete -f manifests/storage/rook/cluster/ceph-pool.yaml
#kubectl delete -f manifests/storage/rook/cluster/ceph-operator.yaml