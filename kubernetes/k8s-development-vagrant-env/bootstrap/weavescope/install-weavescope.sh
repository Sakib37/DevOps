#!/bin/bash

set -xe

cat > /etc/default/weavescope <<"EOL"
export WEAVE_SCOPE_VERSION=1.9.1
EOL

# add a line which sources /etc/default/weavescope in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/weavescope' /etc/environment || echo '. /etc/default/weavescope' >> /etc/environment

# source the ubuntu global env file to make weavescope variables available to this session
source /etc/environment

sudo -E -s -- <<EOF

# Install the weave scope

echo "Installing Weave Scope v${WEAVE_SCOPE_VERSION} ..."
curl -L git.io/scope -o /usr/local/bin/scope -#
chmod a+x /usr/local/bin/scope

#WEAVESCOPE_DOCKER_ARGS="--restart=always" scope launch

EOF

echo "Weave Scope v${WEAVE_SCOPE_VERSION} installed successfully"

exit 0
