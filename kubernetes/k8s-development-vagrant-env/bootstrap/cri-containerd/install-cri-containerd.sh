#!/bin/bash

set -xe

cat > /etc/default/cri-containerd-runtime <<"EOL"
export CRI_CONTAINERD_VERSION=1.0.0-beta.1
EOL

# add a line which sources /etc/default/cri-containerd-runtime in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/cri-containerd-runtime' /etc/environment || echo '. /etc/default/cri-containerd-runtime' >> /etc/environment

# source the ubuntu global env file to make cri-containerd variables available to this session
source /etc/environment


# Install the cri-containerd runtime

sudo -E -s -- <<EOF

# install dependencies
apt-get update -qq --yes
apt-get install -qq --yes socat

wget -q https://github.com/kubernetes-incubator/cri-containerd/releases/download/v${CRI_CONTAINERD_VERSION}/cri-containerd-${CRI_CONTAINERD_VERSION}.tar.gz

tar -xvf crio-amd64-v${CRIO_VERSION}.tar.gz -C /

rm -rf crio-amd64-v${CRIO_VERSION}.tar.gz

echo "Cri-Containerd runtime v${CRI_CONTAINERD_VERSION} downloaded successfully"

exit 0

EOF