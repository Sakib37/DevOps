#!/bin/bash

set -xe

cat > /etc/default/runc <<"EOL"
export RUNC_VERSION=1.0.0-rc4
EOL

# add a line which sources /etc/default/runc in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/runc' /etc/environment || echo '. /etc/default/runc' >> /etc/environment

# source the ubuntu global env file to make runc variables available to this session
source /etc/environment

# Install the cri-o runtime

sudo -E -s -- <<EOF

wget -q https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
chmod +x runc.amd64
mv runc.amd64 /usr/local/bin/runc

EOF

echo "Runc v${RUNC_VERSION} downloaded successfully"

exit 0