#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install global and common authorization policies
kubectl apply -f manifests/authorization/global/ | tee -a logs/manifests.log

# install cluster roles for pod security policy usage
kubectl apply -f manifests/authorization/podsecurity/ | tee -a logs/manifests.log

# install default authorizations
kubectl apply -f manifests/authorization/platform/default/ | tee -a logs/manifests.log

# install kube-system authorizations
kubectl apply -f manifests/authorization/platform/kube-system/ | tee -a logs/manifests.log

# install istio-system authorizations
kubectl apply -f manifests/authorization/platform/istio-system/ | tee -a logs/manifests.log

# install rook-system authorizations
kubectl apply -f manifests/authorization/platform/rook-system/ | tee -a logs/manifests.log

# install rook authorizations
kubectl apply -f manifests/authorization/platform/rook/ | tee -a logs/manifests.log

# install security-system authorizations
kubectl apply -f manifests/authorization/platform/security-system/ | tee -a logs/manifests.log

# install staging authorizations
kubectl apply -f manifests/authorization/platform/staging/ | tee -a logs/manifests.log

# install production authorizations
kubectl apply -f manifests/authorization/platform/production/ | tee -a logs/manifests.log

## install pcit authorizations
#kubectl apply -f manifests/authorization/teams/pcit/ | tee -a logs/manifests.log
#
## install backend-apps authorizations
#kubectl apply -f manifests/authorization/teams/backend-apps/ | tee -a logs/manifests.log
#
## install mobile-apps authorizations
#kubectl apply -f manifests/authorization/teams/mobile-apps/ | tee -a logs/manifests.log
#
## install product-intelligence authorizations
#kubectl apply -f manifests/authorization/teams/product-intelligence/ | tee -a logs/manifests.log
#
## install scoober authorizations
#kubectl apply -f manifests/authorization/teams/scoober/ | tee -a logs/manifests.log
#
## install sysops authorizations
#kubectl apply -f manifests/authorization/teams/sysops/ | tee -a logs/manifests.log
#
## install frontend authorizations
#kubectl apply -f manifests/authorization/teams/frontend/ | tee -a logs/manifests.log
