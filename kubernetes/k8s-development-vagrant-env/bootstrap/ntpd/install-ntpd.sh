#!/bin/bash

set -xe

# Install ntp

sudo -E -s -- <<EOF

apt-get update -qq --yes
apt-get install -qq --yes \
    ntp

echo "NTP Daemon installed successfully"

EOF

exit 0
