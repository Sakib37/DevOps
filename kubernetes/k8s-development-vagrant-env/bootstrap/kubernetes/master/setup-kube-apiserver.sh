#!/bin/bash

set -xe

source /etc/environment

export KUBERNETES_SERVER_IP=${1}
export KUBERNETES_SERVER_COUNT=${2}
export KUBERNETES_SERVICE_CLUSTER_IP_RANGE=${3}
export KUBERNETES_SERVICE_NODE_PORT_RANGE=${4}
export KUBERNETES_SERVICE_CLOUD_PROVIDER=${5}
export KUBERNETES_SERVICE_ENABLE_POD_SECURITY_POLICY=${6}
export KUBERNETES_SERVICE_ADMISSION_PLUGINS=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PersistentVolumeClaimResize,AlwaysPullImages,PodPreset
#
# if pod security policy is set as enabled through the config file then add PodSecurityPolicy to list of admission plugins
if [ "${KUBERNETES_SERVICE_ENABLE_POD_SECURITY_POLICY}" = true ]
then
    export KUBERNETES_SERVICE_ADMISSION_PLUGINS="${KUBERNETES_SERVICE_ADMISSION_PLUGINS},PodSecurityPolicy"
fi

sudo -E -s <<"EOF"

# Note: As "CFSSL_TLS_GUEST_FOLDER" variable is not expanded in '/etc/systemd/system/kube-apiserver.service' , the value
# of  "CFSSL_TLS_GUEST_FOLDER" must be set in '/etc/default/kube-apiserver.conf'

cat > /etc/default/kube-apiserver.conf << EOL
CFSSL_TLS_GUEST_FOLDER=${CFSSL_TLS_GUEST_FOLDER}
KUBERNETES_SERVER_NAME=$(hostname)
KUBERNETES_SERVER_IP=${KUBERNETES_SERVER_IP}
KUBERNETES_SERVER_COUNT=${KUBERNETES_SERVER_COUNT}
KUBERNETES_SERVICE_CLUSTER_IP_RANGE=${KUBERNETES_SERVICE_CLUSTER_IP_RANGE}
KUBERNETES_SERVICE_NODE_PORT_RANGE=${KUBERNETES_SERVICE_NODE_PORT_RANGE}
KUBERNETES_SERVICE_CLOUD_PROVIDER=${KUBERNETES_SERVICE_CLOUD_PROVIDER}
KUBERNETES_SERVICE_ENABLE_POD_SECURITY_POLICY=${KUBERNETES_SERVICE_ENABLE_POD_SECURITY_POLICY}
KUBERNETES_SERVICE_ADMISSION_PLUGINS=${KUBERNETES_SERVICE_ADMISSION_PLUGINS}
KUBERNETES_PLATFORM_USER=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_GROUP=${KUBERNETES_PLATFORM_USER}
KUBERNETES_PLATFORM_HOME=${KUBERNETES_PLATFORM_HOME}
ETCD_SERVERS=${ETCD_SERVERS}
GOMAXPROCS=$(nproc)
EOL

# add a line which sources /etc/default/kube-apiserver.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kube-apiserver.conf' /etc/environment || echo '. /etc/default/kube-apiserver.conf' >> /etc/environment

# source the ubuntu global env file to make etcd variables available to this session
source /etc/environment

chown ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} /etc/default/kube-apiserver.conf

# create kubernetes audit policy file
mkdir -p ${KUBERNETES_PLATFORM_HOME}/audit/logs

chown -R ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_GROUP} ${KUBERNETES_PLATFORM_HOME}/*

# NOTE: "ETCD_SERVERS" is already setup in /etc/environment by bootstrap/etcd/setup-etcd.sh.
#        "--etcd-servers" below is same as "ETCD_SERVERS" value

cat > /etc/systemd/system/kube-apiserver.service <<"EOL"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
User=kubernetes
EnvironmentFile=/etc/default/kube-apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver \
    --cloud-provider=${KUBERNETES_SERVICE_CLOUD_PROVIDER} \
    --enable-admission-plugins=${KUBERNETES_SERVICE_ADMISSION_PLUGINS} \
    --feature-gates=ExpandPersistentVolumes=true,TaintBasedEvictions=true,ExperimentalCriticalPodAnnotation=true \
    --advertise-address=${KUBERNETES_SERVER_IP} \
    --allow-privileged=true \
    --apiserver-count=${KUBERNETES_SERVER_COUNT} \
    --audit-log-maxage=1 \
    --audit-log-maxbackup=5 \
    --audit-log-maxsize=32 \
    --audit-log-path=${KUBERNETES_PLATFORM_HOME}/audit/logs/audit.log \
    --audit-policy-file=/vagrant/conf/audit-policy.yaml \
    --authorization-mode=Node,RBAC \
    --bind-address=0.0.0.0 \
    --client-ca-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --enable-swagger-ui=true \
    --etcd-cafile=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --etcd-certfile=${CFSSL_TLS_GUEST_FOLDER}/etcd/${KUBERNETES_SERVER_NAME}-client.pem \
    --etcd-keyfile=${CFSSL_TLS_GUEST_FOLDER}/etcd/${KUBERNETES_SERVER_NAME}-client-key.pem \
    --etcd-servers=${ETCD_SERVERS} \
    --event-ttl=15m \
    --experimental-encryption-provider-config=/vagrant/conf/data-encryption-config.yaml \
    --kubelet-certificate-authority=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --kubelet-client-certificate=${CFSSL_TLS_GUEST_FOLDER}/kubelet/${KUBERNETES_SERVER_NAME}-kubelet.pem \
    --kubelet-client-key=${CFSSL_TLS_GUEST_FOLDER}/kubelet/${KUBERNETES_SERVER_NAME}-kubelet-key.pem \
    --kubelet-https=true \
    --runtime-config=api/all,admissionregistration.k8s.io/v1beta1,admissionregistration.k8s.io/v1alpha1,settings.k8s.io/v1alpha1=true \
    --service-account-key-file=${CFSSL_TLS_GUEST_FOLDER}/service-accounts/service-accounts.pem \
    --service-cluster-ip-range=${KUBERNETES_SERVICE_CLUSTER_IP_RANGE} \
    --service-node-port-range=${KUBERNETES_SERVICE_NODE_PORT_RANGE} \
    --tls-cert-file=${CFSSL_TLS_GUEST_FOLDER}/kube-api/${KUBERNETES_SERVER_NAME}-apiserver.pem \
    --tls-private-key-file=${CFSSL_TLS_GUEST_FOLDER}/kube-api/${KUBERNETES_SERVER_NAME}-apiserver-key.pem \
    --requestheader-client-ca-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    --requestheader-allowed-names= \
    --requestheader-extra-headers-prefix=X-Remote-Extra- \
    --requestheader-group-headers=X-Remote-Group \
    --requestheader-username-headers=X-Remote-User \
    --proxy-client-cert-file=${CFSSL_TLS_GUEST_FOLDER}/aggregator/aggregator.pem \
    --proxy-client-key-file=${CFSSL_TLS_GUEST_FOLDER}/aggregator/aggregator-key.pem \
    --enable-aggregator-routing=true \
    --v=2

Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL


# Add the following flags if LDAP is used
#    --oidc-issuer-url=https://k8s-auth-1:5554 \
#    --oidc-client-id=pcit-k8s-vagrant \
#    --oidc-ca-file=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
#    --oidc-username-claim=email \
#    --oidc-groups-claim=groups \

#systemctl daemon-reload && systemctl enable kube-apiserver.service && systemctl start kube-apiserver.service

EOF

echo "Kubernetes API Server v${KUBERNETES_PLATFORM_VERSION} configured successfully"

exit 0
