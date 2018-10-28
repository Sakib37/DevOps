#!/bin/bash

# allow the kube api servers to call the kubelets to retrieve stuff like metrics and logs and execute commands in pods
vagrant ssh -c "kubectl apply -f /vagrant/manifests/core/api-to-kubelet-auth.yaml" k8s-server-1 | tee -a logs/manifests.log

# start docker runtime across the worker nodes
for one in $(vagrant hosts list | grep -E 'k8s-server|k8s-node' | awk '{print $2}')
do
    echo "starting docker runtime on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable docker.service && systemctl start docker.service'" ${one} | tee -a logs/${one}-services.log &
done

# start docker runtime across the master nodes
for one in $(vagrant hosts list | grep -E 'k8s-server|k8s-node' | awk '{print $2}')
do
    echo "starting docker runtime on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable docker.service && systemctl start docker.service'" ${one} | tee -a logs/${one}-services.log &
done

wait

echo "done starting up docker"

# start kubernetes kubelets across the worker nodes
for one in $(vagrant hosts list | grep -E 'k8s-server|k8s-node' | awk '{print $2}')
do
    echo "starting kubernetes kubelet on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable kubelet.service && systemctl start kubelet.service'" ${one} | tee -a logs/${one}-services.log &
done

wait

echo "done starting up kubernetes kubelets"


# start kubernetes kube proxy across the worker nodes
for one in $(vagrant hosts list |grep -E 'k8s-server|k8s-node' | awk '{print $2}')
do
    echo "starting kubernetes kube proxy on ${one}"
    vagrant ssh -c "sudo bash -c 'systemctl daemon-reload && systemctl enable kube-proxy.service && systemctl start kube-proxy.service'" ${one} | tee -a logs/${one}-services.log &
done

wait

echo "done starting up kubernetes kube-proxy"

# install weave net into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/weavenet/"' k8s-server-1 | tee -a logs/manifests.log
sleep 60

# install kube-dns into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/dns/"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# install fluentd into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/logging/fluentd/fluentd-daemonset.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 60

# install prometheus operator
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/prometheus/operator"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# install rook operator into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/operator/"' k8s-server-1 | tee -a logs/manifests.log
sleep 60

# install rook cluster into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/cluster/rook-cluster.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 90

# install rook storage class into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/cluster/rook-storageclass.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# install rook tools into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/cluster/rook-tools.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# install rook object storage into kubernetes
#vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/cluster/rook-object-store.yaml"' k8s-server-1 | tee -a logs/manifests.log
#sleep 30

# install rook shared filesystem into kubernetes
#vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/cluster/rook-file-system.yaml"' k8s-server-1 | tee -a logs/manifests.log
#sleep 30


# copy rook-rook-user secret to kube-system namespace
#vagrant ssh -c 'kubectl get secret rook-rook-user -o json | jq ".metadata.namespace = '"kube-system"'" | kubectl apply -f -' k8s-server-1 | tee -a logs/manifests.log
#sleep 30


# install heapster
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/heapster/auth/"' k8s-server-1 | tee -a logs/manifests.log
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/heapster/core/influxdb.yaml"' k8s-server-1 | tee -a logs/manifests.log
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/heapster/core/grafana.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 60
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/heapster/core/heapster.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# install rook monitoring into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/monitoring/prometheus/prometheus.yaml"' k8s-server-1 | tee -a logs/manifests.log
sleep 30

# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/monitoring/prometheus/prometheus-service.yaml"' k8s-server-1 | tee -a logs/manifests.log
#
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/storage/rook/monitoring/prometheus/service-monitor.yaml" -f "/vagrant/manifests/storage/rook/monitoring/prometheus/prometheus-service.yaml"' k8s-server-1 | tee -a logs/manifests.log
# sleep 30

# install metrics-server
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/metrics-server/metrics-server.yaml"' k8s-server-1 | tee -a logs/manifests.log

# install custom-metrics-server
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/custom-metrics-server/custom-metrics-server.yaml"' k8s-server-1 | tee -a logs/manifests.log

# install kube-dashboard into kubernetes
vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/telemetry/dashboard/"' k8s-server-1 | tee -a logs/manifests.log
sleep 15

# # install isto service mesh core into kubernetes
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/istio/core/istio.yaml"' k8s-server-1 | tee -a logs/manifests.log
# sleep 60
#
# # install isto service mesh initializers into kubernetes
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/istio/initializer/istio-initializer.yaml"' k8s-server-1 | tee -a logs/manifests.log
# sleep 30
#
# # install isto service mesh addons into kubernetes
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/istio/addons/"' k8s-server-1 | tee -a logs/manifests.log
# sleep 60
#
# # install ingress and egress rules
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/ingress/"' k8s-server-1 | tee -a logs/manifests.log
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/egress/"' k8s-server-1 | tee -a logs/manifests.log
#
# # install ngrok
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/networking/ngrok/"' k8s-server-1 | tee -a logs/manifests.log
#
# # install wrk
# vagrant ssh -c 'kubectl apply -f "/vagrant/manifests/compliance/wrk/"' k8s-server-1 | tee -a logs/manifests.log

# show status of all pods
vagrant ssh -c 'kubectl get pods --all-namespaces -o wide' k8s-server-1 | tee -a logs/manifests.log