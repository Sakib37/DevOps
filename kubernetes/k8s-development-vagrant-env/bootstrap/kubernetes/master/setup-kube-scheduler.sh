#!/bin/bash

set -xe

source /etc/environment

sudo -E -s <<"EOF"

cat > /etc/default/kube-scheduler.conf << EOL
KUBERNETES_PLATFORM_USER=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_GROUP=${KUBERNETES_PLATFORM_GROUP}
KUBERNETES_NODE_NAME=$(hostname)
KUBE_SCHEDULER_CONFIGURATION=${KUBERNETES_PLATFORM_HOME}/kube-scheduler-configuration.yaml
GOMAXPROCS=$(nproc)
EOL

# add a line which sources /etc/default/kube-scheduler.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kube-scheduler.conf' /etc/environment || echo '. /etc/default/kube-scheduler.conf' >> /etc/environment

# source the ubuntu global env file to make etcd variables available to this session
source /etc/environment

chown ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} /etc/default/kube-scheduler.conf


cat > ${KUBE_SCHEDULER_CONFIGURATION} <<EOL
kind: KubeSchedulerConfiguration
apiVersion: componentconfig/v1alpha1
algorithmSource:
  provider: DefaultProvider
clientConnection:
  acceptContentTypes: ""
  burst: 100
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: "/vagrant/conf/kubeconfig/${KUBERNETES_NODE_NAME}/${KUBERNETES_NODE_NAME}-kube-scheduler.kubeconfig"
  qps: 50
disablePreemption: false
enableContentionProfiling: false
enableProfiling: false
failureDomains: kubernetes.io/hostname,failure-domain.beta.kubernetes.io/zone,failure-domain.beta.kubernetes.io/region
hardPodAffinitySymmetricWeight: 1
healthzBindAddress: 0.0.0.0:10251
leaderElection:
  leaderElect: true
  leaseDuration: 15s
  lockObjectName: kube-scheduler
  lockObjectNamespace: kube-system
  renewDeadline: 10s
  resourceLock: endpoints
  retryPeriod: 2s
metricsBindAddress: 0.0.0.0:10251
schedulerName: default-scheduler
EOL


cat > /etc/systemd/system/kube-scheduler.service <<"EOL"
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
User=kubernetes
EnvironmentFile=/etc/default/kube-scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler \
    --config=${KUBE_SCHEDULER_CONFIGURATION} \
    --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

#systemctl daemon-reload && systemctl enable kube-scheduler.service && systemctl start kube-scheduler.service

EOF

echo "Kubernetes Scheduler v${KUBERNETES_PLATFORM_VERSION} configured successfully"

exit 0
