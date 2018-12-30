#!/bin/bash

set -xe

source /etc/environment

export KUBERNETES_CLUSTER_NAME=${1}
export KUBERNETES_CLUSTER_CIDR=${2}
export KUBERNETES_SERVICE_CLUSTER_IP_RANGE=${3}
export KUBERNETES_SERVICE_CLOUD_PROVIDER=${4}
export KUBECONFIG_FOLDER=${5}

sudo -E -s <<"EOF"


# Note: As "CFSSL_TLS_GUEST_FOLDER" variable is not expanded in '/etc/systemd/system/kube-controller-manager.service' , the value
# of  "CFSSL_TLS_GUEST_FOLDER" must be set in '/etc/default/kube-controller-manager.conf'


cat > /etc/default/kube-controller-manager.conf << EOL
CFSSL_TLS_GUEST_FOLDER=${CFSSL_TLS_GUEST_FOLDER}
KUBERNETES_CLUSTER_NAME=${KUBERNETES_CLUSTER_NAME}
KUBERNETES_CLUSTER_CIDR=${KUBERNETES_CLUSTER_CIDR}
KUBERNETES_SERVICE_CLUSTER_IP_RANGE=${KUBERNETES_SERVICE_CLUSTER_IP_RANGE}
KUBERNETES_SERVICE_CLOUD_PROVIDER=${KUBERNETES_SERVICE_CLOUD_PROVIDER}
KUBERNETES_PLATFORM_USER=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_GROUP=${KUBERNETES_PLATFORM_GROUP}
KUBERNETES_NODE_NAME=$(hostname)
GOMAXPROCS=$(nproc)
EOL

# add a line which sources /etc/default/kube-controller-manager.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kube-controller-manager.conf' /etc/environment || echo '. /etc/default/kube-controller-manager.conf' >> /etc/environment

# source the ubuntu global env file to make etcd variables available to this session
source /etc/environment

chown ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} /etc/default/kube-controller-manager.conf

cat > /etc/systemd/system/kube-controller-manager.service <<"EOL"
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
User=kubernetes
EnvironmentFile=/etc/default/kube-controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager \
    --cloud-provider=${KUBERNETES_SERVICE_CLOUD_PROVIDER} \
    --bind-address=0.0.0.0 \
    --cluster-cidr=${KUBERNETES_CLUSTER_CIDR} \
    --cluster-name=${KUBERNETES_CLUSTER_NAME} \
    --cluster-signing-cert-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --cluster-signing-key-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem \
    --kubeconfig=/vagrant/conf/kubeconfig/${KUBERNETES_NODE_NAME}/${KUBERNETES_NODE_NAME}-kube-controller-manager.kubeconfig \
    --leader-elect=true \
    --root-ca-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --service-account-private-key-file=${CFSSL_TLS_GUEST_FOLDER}/service-accounts/service-accounts-key.pem \
    --authentication-kubeconfig=/vagrant/conf/kubeconfig/${KUBERNETES_NODE_NAME}/${KUBERNETES_NODE_NAME}-kube-controller-manager.kubeconfig \
    --authentication-skip-lookup=false \
    --service-cluster-ip-range=${KUBERNETES_SERVICE_CLUSTER_IP_RANGE} \
    --horizontal-pod-autoscaler-sync-period=10s \
    --use-service-account-credentials=true \
    --flex-volume-plugin-dir=/var/lib/kubelet/volumeplugins \
    --v=2

Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

#systemctl daemon-reload && systemctl enable kube-controller-manager.service && systemctl start kube-controller-manager.service

EOF

echo "Kubernetes Controller Manager v${KUBERNETES_PLATFORM_VERSION} configured successfully"

exit 0