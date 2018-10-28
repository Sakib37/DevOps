#!/bin/bash

set -xe

sudo -E -s -- <<"EOF"

cp /vagrant/conf/ca-chain.pem /usr/local/share/ca-certificates/ca-chain.crt
update-ca-certificates
EOF
