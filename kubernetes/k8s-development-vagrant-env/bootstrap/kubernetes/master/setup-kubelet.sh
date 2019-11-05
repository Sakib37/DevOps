#!/bin/bash

set -xe

source /etc/environment

export POD_CIDR=${1}
export KUBERNETES_SERVICE_CLOUD_PROVIDER=${2}
export KUBERNETES_CLUSTER_DNS=${3}
export KUBELET_NODE_NAME=$(hostname)



# Note: As "CFSSL_TLS_GUEST_FOLDER" variable is not expanded in '/etc/systemd/system/kubelet.service' , the value
# of  "CFSSL_TLS_GUEST_FOLDER" must be set in '/etc/default/kubelet.conf'

sudo tee "/etc/default/kubelet.conf" > /dev/null <<EOL
CFSSL_TLS_GUEST_FOLDER=${CFSSL_TLS_GUEST_FOLDER}
KUBELET_POD_CIDR=${POD_CIDR}
KUBELET_NODE_NAME=$(hostname)
KUBERNETES_SERVICE_CLOUD_PROVIDER=${KUBERNETES_SERVICE_CLOUD_PROVIDER}
KUBERNETES_CLUSTER_DNS=${KUBERNETES_CLUSTER_DNS}
KUBERNETES_PLATFORM_USER=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_GROUP=${KUBERNETES_PLATFORM_GROUP}
KUBELET_CONFIGURATION_FILE=${KUBERNETES_PLATFORM_HOME}/kubelet-configuration.yaml
GOMAXPROCS=$(nproc)
EOL


# add a line which sources /etc/default/kubelet.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kubelet.conf' /etc/environment || echo '. /etc/default/kubelet.conf' >> /etc/environment

# source the ubuntu global env file to make kubelet variables available to this session
source /etc/environment

sudo chown ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} /etc/default/kubelet.conf


# Check "https://github.com/kubernetes/kubernetes/issues/69665" for kubelet config file example

# NOTE: Environment variables must be expanded inside the ${KUBELET_CONFIGURATION_FILE}. Any ENV variable in
# ${KUBELET_CONFIGURATION_FILE} make kubelet to fail


sudo tee ${KUBELET_CONFIGURATION_FILE} > /dev/null <<EOL
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
nodeStatusUpdateFrequency: 10s
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "${CFSSL_TLS_GUEST_FOLDER}/kubelet/${KUBELET_NODE_NAME}-kubelet.pem"
tlsPrivateKeyFile: "${CFSSL_TLS_GUEST_FOLDER}/kubelet/${KUBELET_NODE_NAME}-kubelet-key.pem"
EOL

sudo tee /etc/systemd/system/kubelet.service  > /dev/null <<"EOL"
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=/etc/default/kubelet.conf
ExecStart=/usr/local/bin/kubelet \
  --config=${KUBELET_CONFIGURATION_FILE} \
  --cloud-provider=${KUBERNETES_SERVICE_CLOUD_PROVIDER} \
  --container-runtime=docker \
  --docker-endpoint=unix:///var/run/docker.sock \
  --container-runtime-endpoint=unix:///var/run/dockershim.sock \
  --image-pull-progress-deadline=4m \
  --image-service-endpoint=unix:///var/run/dockershim.sock \
  --kubeconfig=/vagrant/conf/kubeconfig/${KUBELET_NODE_NAME}/${KUBELET_NODE_NAME}-kubelet.kubeconfig \
  --network-plugin=cni \
  --cni-bin-dir=/opt/cni/bin \
  --register-node=true \
  --register-with-taints=node-role.kubernetes.io/master=true:NoSchedule \
  --node-labels=kubelet.kubernetes.io/role=master,node.kubernetes.io/master=true \
  --volume-plugin-dir=/var/lib/kubelet/volumeplugins \
  --v=2

Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

#systemctl daemon-reload && systemctl enable kube-scheduler.service && systemctl start kube-scheduler.service

echo "Kubernetes Kubelet v${KUBERNETES_PLATFORM_VERSION} configured successfully"

exit 0
