#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# install ceph operator
#kubectl apply -f manifests/storage/rook/cluster/ceph-operator.yaml | tee -a logs/manifests.log
sleep 30

# install rook cluster
echo "Waiting for rook-ceph-operator to be deployed completely. Be patient, it take 15-30 min ..."
while true
do
    desired=$(kubectl get daemonsets -n rook-ceph-system | grep rook-discover | awk '{print $2}')
    ready=$(kubectl get daemonsets -n rook-ceph-system | grep rook-discover | awk '{print $4}')

    if [ "${desired}" == "${ready}" ]
    then
        echo "rook-ceph-operator is ready"
        break
    fi

    sleep 5
done

kubectl apply -f manifests/storage/rook/cluster/rook-cluster.yaml | tee -a logs/manifests.log
sleep 30

echo "Waiting for rook-cluster to be ready. Be patient, it takes 15-30 min ..."
while true
do
    osd_available=$(kubectl get deployments -n rook-ceph | grep rook-ceph-osd-1 | awk '{print $4}')

    if [[ ${osd_available} == 1 ]]
    then
        echo "rook-cluster is ready"
        break
    fi

    sleep 10
done

sleep 5

# install ceph pool
kubectl apply -f manifests/storage/rook/cluster/ceph-pool.yaml | tee -a logs/manifests.log
#sleep 60

# install rook storage class into kubernetes
kubectl apply -f manifests/storage/rook/cluster/rook-storageclass.yaml | tee -a logs/manifests.log

# install rook tools
kubectl apply -f manifests/storage/rook/cluster/rook-toolbox.yaml | tee -a logs/manifests.log

# install rook prometheus' monitoring stack
#kubectl apply -f manifests/storage/rook/monitoring/prometheus/prometheus.yaml | tee -a logs/manifests.log
#sleep 30


#kubectl apply -f manifests/deployments/production/storage/ | tee -a logs/manifests.log
#sleep 60


#kubectl delete -f manifests/storage/rook/monitoring/prometheus/prometheus.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-tools.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-storageclass.yaml
#kubectl delete -f manifests/storage/rook/cluster/rook-cluster.yaml
#kubectl delete -f manifests/storage/rook/cluster/ceph-pool.yaml
#kubectl delete -f manifests/storage/rook/cluster/ceph-operator.yaml