# install rook operator
kubectl apply -f manifests/persistent-storage/rook-operator.yaml

# wait until the rok operator contianer is in running state
sleep 60

# wait until the rook operator container is in running state
kubectl create -f manifests/persistent-storage/rook-cluster.yaml
kubectl create -f manifests/persistent-storage/rook-tools.yaml
kubectl create -f manifests/persistent-storage/rook-storageclass.yaml

# install prometheus operator
kubectl apply -f manifests/storage/monitoring/prometheus-operator-0.13.yaml

# wait until the prometheus operator container is in running state
sleep 60

# install prometheus monitoring for rook storage
kubectl apply -f manifests/persistent-storage/monitoring/service-monitor.yaml
kubectl apply -f manifests/persistent-storage/monitoring/prometheus.yaml
kubectl apply -f manifests/persistent-storage/monitoring/prometheus-service.yaml