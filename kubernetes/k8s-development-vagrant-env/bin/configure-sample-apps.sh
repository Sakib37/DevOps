#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# pcit
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=pcit-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=pcit-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=pcit-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=pcit-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=pcit-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=pcit-production --port=8080
#
## scoober
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=scoober-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=scoober-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=scoober-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=scoober-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=scoober-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=scoober-production --port=8080
#
## sysops
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=sysops-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=sysops-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=sysops-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=sysops-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=sysops-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=sysops-production --port=8080
#
## frontend
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=frontend-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=frontend-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=frontend-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=frontend-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=frontend-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=frontend-production --port=8080
#
## backend-apps
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=backend-apps-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=backend-apps-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=backend-apps-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=backend-apps-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=backend-apps-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=backend-apps-production --port=8080
#
## mobile-apps
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=mobile-apps-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=mobile-apps-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=mobile-apps-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=mobile-apps-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=mobile-apps-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=mobile-apps-production --port=8080
#
## product-intelligence
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=product-intelligence-commons --replicas=1 kuard
#kubectl expose deployment kuard --namespace=product-intelligence-commons --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=product-intelligence-staging --replicas=1 kuard
#kubectl expose deployment kuard --namespace=product-intelligence-staging --port=8080
#
#kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=product-intelligence-production --replicas=1 kuard
#kubectl expose deployment kuard --namespace=product-intelligence-production --port=8080

# staging
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=staging --replicas=1 kuard
kubectl expose deployment kuard --namespace=staging --port=8080

# production
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=production --replicas=1 kuard
kubectl expose deployment kuard --namespace=production --port=8080

# security-system
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=security-system --replicas=1 kuard
kubectl expose deployment kuard --namespace=security-system --port=8080

# kube-system
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=kube-system --replicas=1 kuard
kubectl expose deployment kuard --namespace=kube-system --port=8080

# istio-system
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=istio-system --replicas=1 kuard
kubectl expose deployment kuard --namespace=istio-system --port=8080

# default
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:2 --namespace=default --replicas=1 kuard
kubectl expose deployment kuard --namespace=default --port=8080
