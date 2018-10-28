#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig

# configure core/system namespaces
kubectl apply -f manifests/namespaces/global/default/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/default/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/default/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/default/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/kube-system/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/kube-system/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/kube-system/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/kube-system/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/istio-system/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/istio-system/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/istio-system/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/istio-system/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/rook-system/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook-system/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook-system/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook-system/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/rook/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/rook/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/production/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/production/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/production/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/production/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/staging/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/staging/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/staging/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/staging/tiller.yaml | tee -a logs/manifests.log

kubectl apply -f manifests/namespaces/global/security-system/namespace.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/security-system/limits.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/security-system/resourcequotas.yaml | tee -a logs/manifests.log
kubectl apply -f manifests/namespaces/global/security-system/tiller.yaml | tee -a logs/manifests.log

# configure team namespaces

#kubectl apply -f manifests/namespaces/teams/pcit/pcit-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/pcit/pcit-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/frontend/frontend-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/scoober/scoober-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-production/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-commons/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-commons/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-commons/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-commons/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-staging/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-staging/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-staging/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-staging/tiller.yaml | tee -a logs/manifests.log
#
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-production/namespace.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-production/limits.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-production/resourcequotas.yaml | tee -a logs/manifests.log
#kubectl apply -f manifests/namespaces/teams/sysops/sysops-production/tiller.yaml | tee -a logs/manifests.log

if [ "${KUPA_ENABLE_NETWORK_POLICIES}" = true ]
then
    # configure core/system network policies
    kubectl apply -f manifests/namespaces/global/default/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/kube-system/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/istio-system/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/rook-system/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/rook/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/production/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/staging/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/monitoring-core/firewall.yaml | tee -a logs/manifests.log
    kubectl apply -f manifests/namespaces/global/security-system/firewall.yaml | tee -a logs/manifests.log

    # configure team network policies
    #kubectl apply -f manifests/namespaces/teams/pcit/pcit-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/pcit/pcit-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/pcit/pcit-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/frontend/frontend-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/frontend/frontend-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/frontend/frontend-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/backend-apps/backend-apps-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/mobile-apps/mobile-apps-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/scoober/scoober-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/scoober/scoober-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/scoober/scoober-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/product-intelligence/product-intelligence-production/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/sysops/sysops-commons/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/sysops/sysops-staging/firewall.yaml | tee -a logs/manifests.log
    #kubectl apply -f manifests/namespaces/teams/sysops/sysops-production/firewall.yaml | tee -a logs/manifests.log
fi

kubectl get namespaces -o wide | tee -a logs/manifests.log
