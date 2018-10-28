#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install fluentd for log collection
kubectl apply -f manifests/logging/fluentd/fluentd-daemonset.yaml | tee -a logs/manifests.log

