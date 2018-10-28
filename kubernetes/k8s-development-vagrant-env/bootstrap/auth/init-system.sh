#!/bin/bash

set -xe

sudo -E -s -- <<"EOF"

# add the vagrant user to the root group
usermod -aG root ${USER}

apt update --yes
apt install wget git build-essential --yes

EOF

echo "$(hostname) successfully initialized"

exit 0