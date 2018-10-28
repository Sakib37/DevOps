#!/bin/bash

export KUBECONFIG=conf/kubeconfig/admin.kubeconfig


# install heapster authorization
kubectl apply -f manifests/telemetry/heapster/auth/ | tee -a logs/manifests.log

# install influxdb for heapster metrics storage
kubectl apply -f manifests/telemetry/heapster/core/influxdb.yaml | tee -a logs/manifests.log

# install grafana for heapster metrics visualization
kubectl apply -f manifests/telemetry/heapster/core/grafana.yaml | tee -a logs/manifests.log
sleep 60

# install heapster
kubectl apply -f manifests/telemetry/heapster/core/heapster.yaml | tee -a logs/manifests.log
sleep 30

# install metrics server for log collection
kubectl apply -f manifests/telemetry/metrics-server/metrics-server.yaml | tee -a logs/manifests.log

# install custom-metrics-server for log collection
kubectl apply -f manifests/telemetry/custom-metrics-server/custom-metrics-server.yaml | tee -a logs/manifests.log

# install kubernetes dashboard for log collection
kubectl apply -f manifests/telemetry/dashboard/ | tee -a logs/manifests.log
sleep 15

### Install backend-apps alert manager config
#kubectl create secret --namespace=backend-apps-commons generic alertmanager-backend-apps-alert-manager --from-file=alertmanager.yaml=manifests/deployments/production/monitoring/teams/backend-apps/alert-manager/config.yaml | tee -a logs/manifests.log
#
## install backend-apps alert manager
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/alert-manager/alert-manager.yaml | tee -a logs/manifests.log
#
## install backend-apps prometheus alerting rules
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/prometheus/alert-rules.yaml
#
## install backend-apps prometheus
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/prometheus/prometheus.yaml
#sleep 10
#
## install backend-apps service monitors
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/service-monitors/
#
## install backend-apps grafana
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/grafana/grafana.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/grafana/grafana-datasources.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/grafana/grafana-dashboards.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/backend-apps/grafana/grafana-dashboard-definitions.yaml
#
#
### Install product-intelligence alert manager config
#kubectl create secret --namespace=product-intelligence-commons generic alertmanager-product-intelligence-alert-manager --from-file=alertmanager.yaml=manifests/deployments/production/monitoring/teams/product-intelligence/alert-manager/config.yaml | tee -a logs/manifests.log
#
## install product-intelligence alert manager
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/alert-manager/alert-manager.yaml | tee -a logs/manifests.log
#
## install product-intelligence prometheus alerting rules
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/prometheus/alert-rules.yaml
#
## install product-intelligence prometheus
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/prometheus/prometheus.yaml
#sleep 10
#
## install product-intelligence service monitors
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/service-monitors/
#
## install product-intelligence grafana
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/grafana/grafana.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/grafana/grafana-datasources.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/grafana/grafana-dashboards.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/product-intelligence/grafana/grafana-dashboard-definitions.yaml
#
#
#
## install pcit node exporter
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/node-exporter/node-exporter.yaml
#
## install pcit kube state metrics
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/kube-state-metrics/kube-state-metrics.yaml
#
## Install pcit alert manager config
#kubectl create secret --namespace=pcit-commons generic alertmanager-pcit-alert-manager --from-file=alertmanager.yaml=manifests/deployments/production/monitoring/teams/pcit/alert-manager/config.yaml | tee -a logs/manifests.log
#
## install pcit alert manager
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/alert-manager/alert-manager.yaml | tee -a logs/manifests.log
#
## install pcit prometheus alerting rules
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/prometheus/alert-rules.yaml
#
## install pcit prometheus
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/prometheus/prometheus.yaml
#sleep 10
#
## install pcit service monitors
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/service-monitors/
#
## install pcit grafana
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/grafana/grafana.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/grafana/grafana-datasources.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/grafana/grafana-dashboards.yaml
#kubectl apply -f manifests/deployments/production/monitoring/teams/pcit/grafana/grafana-dashboard-definitions.yaml
