#!/bin/bash

set -xe

export BINARY_LOCATION=/vagrant/temp_downloaded

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment

if ! [ -f ${BINARY_LOCATION}/cfssl ]
then
    go get -u github.com/cloudflare/cfssl/cmd/cfssl
    cp ${GOPATH}/bin/cfssl  ${BINARY_LOCATION}/
else
    cp ${BINARY_LOCATION}/cfssl ${GOPATH}/bin/
fi

if ! [ -f ${BINARY_LOCATION}/cfssljson ]
then
    go get -u github.com/cloudflare/cfssl/cmd/cfssljson
    cp ${GOPATH}/bin/cfssljson  ${BINARY_LOCATION}/

else
    cp ${BINARY_LOCATION}/cfssljson ${GOPATH}/bin/
fi

CFSSL_VERSION=`cfssl version | awk  'NR==1 {print $2}' `

echo "Cfssl v${CFSSL_VERSION} installed successfully"

exit 0
