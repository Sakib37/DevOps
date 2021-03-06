#!/bin/bash

set -xe

# Source already existing system environment variables
source /etc/environment


export ETCD_CLUSTER_SIZE=${2}
export ETCDCTL_CACERT=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem
export ETCDCTL_CERT=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-client.pem
export ETCDCTL_KEY=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-client-key.pem


# creating ETCD_SERVERS_ENDPOINT
ETCD_SERVERS_ENDPOINT=
ETCD_INITIAL_CLUSTER=

for (( i=1; i<=${ETCD_CLUSTER_SIZE}; i++))
do
    if [[ "${i}" -eq  ${ETCD_CLUSTER_SIZE} ]]; then
        NODE=https://k8s-server-${i}:2379
        INIT_CLUSTER_PEER=k8s-server-${i}=https://k8s-server-${i}:2380
    else
        NODE=https://k8s-server-${i}:2379,
        INIT_CLUSTER_PEER=k8s-server-${i}=https://k8s-server-${i}:2380,
    fi
    ETCD_SERVERS_ENDPOINT=${ETCD_SERVERS_ENDPOINT}${NODE}
    ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER}${INIT_CLUSTER_PEER}
done

# Append the new Environment variables in /etc/default/etcd
cat >> /etc/default/etcd <<EOL
export ETCDCTL_CACERT=${ETCDCTL_CACERT}
export ETCDCTL_CERT=${ETCDCTL_CERT}
export ETCDCTL_KEY=${ETCDCTL_KEY}
# The following flag is used by kube-apiserver to find ETCD endpoints
export ETCD_SERVERS=${ETCD_SERVERS_ENDPOINT}
EOL



# source the ubuntu global env file to make etcd variables available to this session
source /etc/environment

# In etcd server IP is unknow use the discovery mechanism to form the clsuter
# source: https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md#discovery
# Here it is not required as the hostname and IP of the etcd nodes is known.

sudo -E -s <<EOF

cat > /etc/default/etcd.conf << EOL
ETCD_NAME=$(hostname)
ETCD_INITIAL_ADVERTISE_PEER_URLS=https://$(hostname):2380
ETCD_LISTEN_PEER_URLS=https://0.0.0.0:2380
ETCD_LISTEN_CLIENT_URLS=https://0.0.0.0:2379
ETCD_ADVERTISE_CLIENT_URLS=https://$(hostname):2379,https://127.0.0.1:2379
ETCD_DISCOVERY_FALLBACK='exit'
ETCD_DATA_DIR=${ETCD_DATA_DIR}
ETCD_WAL_DIR=${ETCD_WAL_DIR}
ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER}
ETCD_CLIENT_CERT_AUTH=true
ETCD_TRUSTED_CA_FILE=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem
ETCD_CERT_FILE=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-client.pem
ETCD_KEY_FILE=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-client-key.pem
ETCD_PEER_CLIENT_CERT_AUTH=true
ETCD_PEER_TRUSTED_CA_FILE=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem
ETCD_PEER_CERT_FILE=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-peer.pem
ETCD_PEER_KEY_FILE=${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-peer-key.pem
ETCD_HEARTBEAT_INTERVAL=6000
ETCD_ELECTION_TIMEOUT=30000
ETCD_ENABLE_V2=false
ETCD_LOG_LEVEL=debug
GOMAXPROCS=$(nproc)
EOL

chown ${ETCD_USER}:${ETCD_GROUP} /etc/default/etcd.conf

cat > /etc/systemd/system/etcd.service << EOL
[Unit]
Description=Etcd Server
Documentation=https://github.com/coreos/etcd
After=network.target

[Service]
User=${ETCD_USER}
Type=notify
EnvironmentFile=/etc/default/etcd.conf
ExecStart=/usr/local/bin/etcd

Restart=always
RestartSec=10s
LimitNOFILE=40000
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

EOF

echo "etcd v${ETCD_VERSION} configured successfully"

exit 0
