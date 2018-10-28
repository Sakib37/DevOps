#!/bin/bash

set -xe



cat > /etc/default/weavenet <<EOL
export WEAVE_NET_VERSION=2.4.1
export WEAVE_NET_SEED=${1:-"k8s-server-1"}
EOL

# add a line which sources /etc/default/weavenet in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/weavenet' /etc/environment || echo '. /etc/default/weavenet' >> /etc/environment

# source the ubuntu global env file to make weavenet variables available to this session
source /etc/environment

sudo -E -s -- <<EOF

# Install the weave net

echo "Installing Weave net v${WEAVE_NET_VERSION} ..."
curl -L git.io/weave -o /usr/local/bin/weave -#
chmod a+x /usr/local/bin/weave
#weave launch ${WEAVE_NET_SEED}
#weave expose
EOF

echo "Weave Net v${WEAVE_NET_VERSION} downloaded successfully"

exit 0
