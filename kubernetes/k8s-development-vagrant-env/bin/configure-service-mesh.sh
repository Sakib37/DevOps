#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# install istio 0.8 development release (nightly builds)
# note: use this only for this vagrant development environment and not in production
# until 0.8 GA/Final is released. In the meantime, comment out the 0.7.1 version below
kubectl apply -f manifests/networking/istio/istio-0.8-dev.yaml | tee -a logs/manifests.log
sleep 120

# install istio service mesh for microservice management
kubectl apply -f manifests/networking/istio/core/istio.yaml | tee -a logs/manifests.log
sleep 60

# install istio service mesh initializers into kubernetes
kubectl apply -f manifests/networking/istio/initializer/istio-initializer.yaml | tee -a logs/manifests.log
sleep 30

# install istio service mesh addons (monitoring etc)
kubectl apply -f manifests/networking/istio/addons/ | tee -a logs/manifests.log
sleep 60


