#!/bin/bash

cat > /etc/default/k8s-system-env <<EOL
export CFSSL_TLS_GUEST_FOLDER=${1}
EOL

apt update; apt install tree -y

# add a line which sources /etc/default/k8s-system-env in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/k8s-system-env' /etc/environment || echo '. /etc/default/k8s-system-env' >> /etc/environment

# source the ubuntu global env file to make system variables available to this session
source /etc/environment