#!/bin/bash

set -xe

cat > /etc/default/kubernetes-platform <<"EOL"
export KUBERNETES_PLATFORM_VERSION=1.13.4
export KUBERNETES_PLATFORM_HOME=/var/lib/kubernetes
export KUBERNETES_PLATFORM_USER=kubernetes
export KUBERNETES_PLATFORM_USER_ID=1400
export KUBERNETES_PLATFORM_GROUP=kubernetes
export KUBERNETES_PLATFORM_GROUP_ID=1400
export KUBERNETES_PLATFORM_SERVER_PACKAGES_DOWNLOAD_URL=https://dl.k8s.io/v${KUBERNETES_PLATFORM_VERSION}/kubernetes-server-linux-amd64.tar.gz
export KUBERNETES_PLATFORM_NODE_PACKAGES_DOWNLOAD_URL=https://dl.k8s.io/v${KUBERNETES_PLATFORM_VERSION}/kubernetes-node-linux-amd64.tar.gz
export KUBERNETES_PLATFORM_CLIENT_PACKAGES_DOWNLOAD_URL=https://dl.k8s.io/v${KUBERNETES_PLATFORM_VERSION}/kubernetes-client-linux-amd64.tar.gz
export KUBERNETES_SERVER_BINARY_VM_LOCATION=/vagrant/temp_downloaded/kubernetes-server-linux-amd64.tar.gz
export KUBERNETES_NODE_BINARY_VM_LOCATION=/vagrant/temp_downloaded/kubernetes-node-linux-amd64.tar.gz
export KUBERNETES_CLIENT_BINARY_VM_LOCATION=/vagrant/temp_downloaded/kubernetes-client-linux-amd64.tar.gz
EOL

# add a line which sources /etc/default/kubernetes-platform in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/kubernetes-platform' /etc/environment || echo '. /etc/default/kubernetes-platform' >> /etc/environment

# Add kubectl bash completion in every node
cat > /home/vagrant/.bashrc <<EOL

# Kubectl bash completion
source <(kubectl completion bash)
EOL

# source the ubuntu global env file to make kubernetes-platform variables available to this session
source /etc/environment

sudo -E -s -- <<EOF

# create the kubernetes users
groupadd -g ${KUBERNETES_PLATFORM_GROUP_ID} ${KUBERNETES_PLATFORM_GROUP} || echo group already exists
useradd -r -u ${KUBERNETES_PLATFORM_USER_ID} -g ${KUBERNETES_PLATFORM_GROUP_ID} -m -c "${KUBERNETES_PLATFORM_USER} role account" \
-d ${KUBERNETES_PLATFORM_HOME} -s /bin/bash ${KUBERNETES_PLATFORM_USER} || echo ${KUBERNETES_PLATFORM_USER} user already exists


usermod -aG root ${KUBERNETES_PLATFORM_USER}
usermod -aG sudo ${KUBERNETES_PLATFORM_USER}
usermod -aG vagrant ${KUBERNETES_PLATFORM_USER}
usermod -aG ${KUBERNETES_PLATFORM_GROUP} vagrant



# Download the kubernetes platform
# Consider switching to direct download of binaries using direct links e.g.
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.7.5/bin/linux/amd64/kubeadm
# Also consider the ubuntu packages install using technique described in the following write-up
# https://kubernetes.io/docs/setup/independent/install-kubeadm/


##### kUBERNETES SERVER  ######
###############################
if ! [ -f ${KUBERNETES_SERVER_BINARY_VM_LOCATION} ]
then
    echo "Downloading Kubernetes server v${KUBERNETES_PLATFORM_VERSION} ..."
    wget -q ${KUBERNETES_PLATFORM_SERVER_PACKAGES_DOWNLOAD_URL} -O ${KUBERNETES_SERVER_BINARY_VM_LOCATION} &>/dev/null
fi
tar xzf ${KUBERNETES_SERVER_BINARY_VM_LOCATION} -C /usr/local/bin --strip-components 3 &>/dev/null
echo "Kubernetes server v${KUBERNETES_PLATFORM_VERSION} setup successfully"


##### kUBERNETES NODE  ######
###############################
if ! [ -f ${KUBERNETES_NODE_BINARY_VM_LOCATION} ]
then
    echo "Downloading Kubernetes node v${KUBERNETES_PLATFORM_VERSION} ..."
    wget -q ${KUBERNETES_PLATFORM_NODE_PACKAGES_DOWNLOAD_URL} -O ${KUBERNETES_NODE_BINARY_VM_LOCATION} &>/dev/null
fi
tar xzf ${KUBERNETES_NODE_BINARY_VM_LOCATION} -C /usr/local/bin --strip-components 3 &>/dev/null
echo "Kubernetes node v${KUBERNETES_PLATFORM_VERSION} setup successfully"


##### kUBERNETES CLIENT  ######
###############################
if ! [ -f ${KUBERNETES_CLIENT_BINARY_VM_LOCATION} ]
then
    echo "Downloading Kubernetes client v${KUBERNETES_PLATFORM_VERSION} ..."
    wget -q ${KUBERNETES_PLATFORM_CLIENT_PACKAGES_DOWNLOAD_URL} -O ${KUBERNETES_CLIENT_BINARY_VM_LOCATION} &>/dev/null
fi
tar xzf ${KUBERNETES_CLIENT_BINARY_VM_LOCATION} -C /usr/local/bin --strip-components 3 &>/dev/null
echo "Kubernetes client v${KUBERNETES_PLATFORM_VERSION} setup successfully"


echo "Cleaning up extracted directory"
rm -rf /usr/local/bin/*.docker_tag
rm -rf /usr/local/bin/kube*.tar
rm -rf /usr/local/bin/cloud-controller-manager.tar

chown -R ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_USER} /usr/local/bin/*kube*
chown -R ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_USER} /usr/local/bin/apiextensions-apiserver
chown -R ${KUBERNETES_PLATFORM_USER}:${KUBERNETES_PLATFORM_USER} /usr/local/bin/cloud-controller-manager


usermod -aG vagrant ${KUBERNETES_PLATFORM_USER}
usermod -aG ${KUBERNETES_PLATFORM_GROUP} vagrant
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/ca/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/kube-api/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/kubelet/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/aggregator/*-key.pem

EOF


echo "Kubernetes Platform v${KUBERNETES_PLATFORM_VERSION} downloaded successfully"

exit 0
