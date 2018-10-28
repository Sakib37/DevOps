#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install the restrictive pod security policy
kubectl apply -f manifests/podsecurity/restrictive.yaml | tee -a logs/manifests.log

# install the permissive pod security policy
kubectl apply -f manifests/podsecurity/permissive.yaml | tee -a logs/manifests.log

# install the unprivileged pod security policy
kubectl apply -f manifests/podsecurity/unprivileged.yaml | tee -a logs/manifests.log
