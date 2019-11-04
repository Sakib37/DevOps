#!/bin/bash

set -xe

export ETCD_VERSION=3.4.3
export ETCD_DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
export ETCD_BINARY_VM_LOCATION=/vagrant/temp_downloaded/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz


cat > /etc/default/etcd <<"EOL"
export ETCD_HOME=/var/lib/etcd
export ETCD_USER=etcd
export ETCD_USER_ID=1300
export ETCD_GROUP=etcd
export ETCD_GROUP_ID=1300
export ETCD_DATA_DIR=/var/lib/etcd/data
export ETCD_WAL_DIR=/var/lib/etcd/wal
EOL

# add a line which sources /etc/default/etcd in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/etcd' /etc/environment || echo '. /etc/default/etcd' >> /etc/environment

# source the ubuntu global env file to make etcd variables available to this session
source /etc/environment

sudo -E -s -- <<EOF

# create the etcd users
groupadd -g ${ETCD_GROUP_ID} ${ETCD_GROUP} || echo group already exists
useradd -r -u ${ETCD_USER_ID} -g ${ETCD_GROUP_ID} -m -c "${ETCD_USER} role account" \
-d ${ETCD_HOME} -s /bin/bash ${ETCD_USER} || echo ${ETCD_USER} user already exists
usermod -aG root ${ETCD_USER}
usermod -aG sudo ${ETCD_USER}

# Download etcd
if ! [ -f ${ETCD_BINARY_VM_LOCATION} ]
then
    echo "Downloading etcd v${ETCD_VERSION} ..."
    wget -q ${ETCD_DOWNLOAD_URL} -O ${ETCD_BINARY_VM_LOCATION} &>/dev/null
fi

tar xzf ${ETCD_BINARY_VM_LOCATION} -C /usr/local/bin --strip-components 1 &>/dev/null

echo "Cleaning up extra directory"
rm -rf /usr/local/bin/README*.md
rm -rf /usr/local/bin/Documentation

chown -R ${ETCD_USER}:${ETCD_USER} /usr/local/bin/etcd*

usermod -aG vagrant ${ETCD_USER}

mkdir -p ${ETCD_DATA_DIR} ${ETCD_WAL_DIR}
chown -R ${ETCD_USER}:${ETCD_GROUP} ${ETCD_DATA_DIR} ${ETCD_WAL_DIR}

chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/ca/*-key.pem
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/etcd/*-key.pem

EOF

echo "etcd v${ETCD_VERSION} downloaded successfully"

exit 0
