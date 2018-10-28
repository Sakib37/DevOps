#!/bin/bash

set -xe

sudo -E -s -- <<EOF
cat > /etc/default/openldap <<"EOL"
export OPENLDAP_VERSION=2.4.42
export OPENLDAP_HOME=/var/lib/openldap
export OPENLDAP_USER=openldap
export OPENLDAP_USER_ID=1800
export OPENLDAP_GROUP=openldap
export OPENLDAP_GROUP_ID=1800
EOL

# add a line which sources /etc/default/openldap in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/openldap' /etc/environment || echo '. /etc/default/openldap' >> /etc/environment

EOF


# source the ubuntu global env file to make dex variables available to this session
source /etc/environment

sudo -E -s -- <<"EOF"

mkdir -p ${OPENLDAP_HOME}

export DEBIAN_FRONTEND=noninteractive

echo -e "
slapd    slapd/internal/generated_adminpw    password   vagrant
slapd    slapd/password2    password    vagrant
slapd    slapd/internal/adminpw    password vagrant
slapd    slapd/password1    password    vagrant
" | sudo debconf-set-selections

apt-get install -y slapd ldap-utils

usermod -aG root openldap
usermod -aG sudo openldap
usermod -aG vagrant openldap

chown -R ${OPENLDAP_USER}:${OPENLDAP_GROUP} ${OPENLDAP_HOME}

EOF

echo "OpenLDAP successfully installed"

exit 0