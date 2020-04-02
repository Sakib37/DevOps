#!/bin/bash

set -xe

source /etc/environment

export POD_CIDR=${1}

sudo tee "/etc/default/kube-proxy.conf" > /dev/null <<EOL
KUBE_PROXY_POD_CIDR=${POD_CIDR}
KUBE_PROXY_NODE_NAME=$(hostname)
KUBERNETES_PLATFORM_USER=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_GROUP=${KUBERNETES_PLATFORM_GROUP}
KUBE_PROXY_CONFIGURATION_FILE=${KUBERNETES_PLATFORM_HOME}/kube-proxy-configuration.yaml
GOMAXPROCS=$(nproc)
EOL

# add a line which sources /etc/default/kube-proxy.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kube-proxy.conf' /etc/environment || echo '. /etc/default/kube-proxy.conf' >> /etc/environment

# source the ubuntu global env file to make kube-proxy variables available to this session
source /etc/environment

sudo chown ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} /etc/default/kube-proxy.conf

#
# kubeproxy config file is an alpha feature. So commenting it for now
#
#sudo tee ${KUBE_PROXY_CONFIGURATION_FILE} > /dev/null <<EOL
#apiVersion: kubeproxy.config.k8s.io/v1alpha1
#kind: KubeProxyConfiguration
#bindAddress: 0.0.0.0
#clientConnection:
#  acceptContentTypes: ""
#  burst: 10
#  contentType: application/vnd.kubernetes.protobuf
#  kubeconfig: "/vagrant/conf/kubeconfig/${KUBE_PROXY_NODE_NAME}/${KUBE_PROXY_NODE_NAME}-kube-proxy.kubeconfig"
#  qps: 5
#clusterCIDR: "${KUBE_PROXY_POD_CIDR}"
#configSyncPeriod: 15m0s
#conntrack:
#  max: 0
#  maxPerCore: 32768
#  min: 131072
#  tcpCloseWaitTimeout: 1h0m0s
#  tcpEstablishedTimeout: 24h0m0s
#enableProfiling: false
#healthzBindAddress: 0.0.0.0:10256
#hostnameOverride: ""
#iptables:
#  masqueradeAll: false
#  masqueradeBit: 14
#  minSyncPeriod: 0s
#  syncPeriod: 30s
#ipvs:
#  minSyncPeriod: 0s
#  scheduler: ""
#  syncPeriod: 30s
#metricsBindAddress: 127.0.0.1:10249
#mode: "iptables"
#nodePortAddresses: null
#oomScoreAdj: -999
#portRange: ""
#resourceContainer: /kube-proxy
#udpIdleTimeout: 250ms
#EOL

sudo tee /etc/systemd/system/kube-proxy.service > /dev/null <<"EOL"
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=/etc/default/kube-proxy.conf
ExecStart=/usr/local/bin/kube-proxy \
    --kubeconfig=/vagrant/conf/kubeconfig/${KUBE_PROXY_NODE_NAME}/${KUBE_PROXY_NODE_NAME}-kube-proxy.kubeconfig \
    --cluster-cidr="${KUBE_PROXY_POD_CIDR}" \
    --v=2

Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

#systemctl daemon-reload && systemctl enable kube-proxy.service && systemctl start kube-proxy.service

echo "Kubernetes Kube Proxy v${KUBERNETES_PLATFORM_VERSION} configured successfully"

exit 0
