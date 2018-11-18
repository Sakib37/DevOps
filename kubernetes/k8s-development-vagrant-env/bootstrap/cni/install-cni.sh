#!/bin/bash

set -xe

CNI_VERSION=0.6.0
CNI_DOWNLOAD_URL=https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-amd64-v${CNI_VERSION}.tgz
CNI_VM_LOCATION=/vagrant/temp_downloaded/cni-plugins-amd64-v${CNI_VERSION}.tgz

export POD_CIDR=${1}
export CNI_VERSION=${CNI_VERSION}

sudo -E -s -- <<EOF

cat > /etc/default/cni <<EOL
export CNI_VERSION=0.6.0
export CNI_POD_CIDR=${POD_CIDR}
EOL

# add a line which sources /etc/default/cni in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/cni' /etc/environment || echo '. /etc/default/cni' >> /etc/environment

# source the ubuntu global env file to make cni variables available to this session
source /etc/environment

# create directories
mkdir -p  "/etc/cni/net.d"  "/opt/cni/bin/"   "/var/run/kubernetes"


# Install the cni runtime
if ! [ -f ${CNI_VM_LOCATION} ]
then
    echo "Downloading cni ${CNI_VERSION} ..."
    wget -q ${CNI_DOWNLOAD_URL} -O ${CNI_VM_LOCATION} &>/dev/null
fi

tar -xvf ${CNI_VM_LOCATION} --strip-components=1 -C /opt/cni/bin/ &>/dev/null

cat > 10-bridge.conf <<EOL
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": false,
    "ipMasq": false,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOL

cat > 99-loopback.conf <<EOL
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOL
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/

echo "CNI v${CNI_VERSION} downloaded successfully"

EOF

exit 0